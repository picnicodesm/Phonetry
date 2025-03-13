//
//  CameraController.swift
//  Phonetry
//
//  Created by 김상민 on 5/11/24.
//

import Foundation
import UIKit
import AVFoundation
import SwiftUI
import Firebase

class CameraController: UIViewController {
    var productManager: ProductManager!
    var classificationManager: ImageClassificaionVM!
    
    // Set up the camera and capture session
    let captureSession = AVCaptureSession()
    var photoOutput = AVCapturePhotoOutput()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var photoCaptureCompletionBlock: ((UIImage?) -> Void)!
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            // Determine if the user previously authorized camera access.
            var isAuthorized = status == AVAuthorizationStatus.authorized
            
            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            } else if status == .denied || status == .restricted {
                self.permissionDelegate?.checkPermission(granted: false)
            }
            return isAuthorized
        }
    }
    
    var flag: Bool = false // 두 번 실행되는 것을 막기 위함
    
    var delegate: AVCapturePhotoCaptureDelegate?
    var permissionDelegate: AVPermissionDelegate?
    var switchTabDelegate: SwitchTabDelegate?
    
    typealias Scanner = GlobalConstants.Scanner
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        async {
            if await isAuthorized {
                // Set up the capture session
                let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
                guard let captureDevice = captureDevice else { fatalError("There is no camera")}
                
                captureSession.beginConfiguration()
                
                // Set up the metadata input
                let input = try? AVCaptureDeviceInput(device: captureDevice)
                guard let input = input else { fatalError("Can't find input") }
                captureSession.addInput(input)
                
                // Set up the  output
                captureSession.addOutput(photoOutput)
                photoOutput.isHighResolutionCaptureEnabled = true
                photoOutput.maxPhotoQualityPrioritization = .quality
                
                // Set up the videoPreviewLayer
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                guard let videoPreviewLayer = self.videoPreviewLayer else { fatalError("Can't make a videoPreviewLayer") }
                
                let rect = UIScreen.main.bounds
                videoPreviewLayer.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.width)
                videoPreviewLayer.videoGravity = .resizeAspectFill
                view.layer.addSublayer(videoPreviewLayer)
                
                captureSession.commitConfiguration()
                
                // Start the capture session
                DispatchQueue.global(qos: .background).async {
                    self.captureSession.startRunning()
                }
            }
        }
    }
    
    func takePicture(flag: Bool, completion: @escaping (Bool) -> Void) {
        self.flag = flag
        async {
            if self.flag == false {
                let settings = AVCapturePhotoSettings()
                photoOutput.capturePhoto(with: settings, delegate: self)
                self.flag = true
                completion(false)
            }
        }
    }
    
    func presentResultView(classificationResult: String, _ isPresent: Binding<Bool>, completion: @escaping (Bool) -> Void) {
        let dateFormatter = CustomDateFormatter()
        let ref = Database.database().reference()
        
        // expDate 값 가져오기
        getExpDate(ref: ref, name: classificationResult) { expDate, description in
            // 현재 날짜와 expDate 더하기
            let expiryDate = dateFormatter.getFormattedDate(from: self.calculateExpiryDate(expDate: expDate))
            print("The expiry date for the \(classificationResult) is: \(expiryDate)")
            
            let bestIfUsedByDateStartString = dateFormatter.getStringFromDate(date: Date())
            let bestIfUseByDateEndString = dateFormatter.getStringFromDate(date: expiryDate)
            
            let product = ProductModel(productName: classificationResult,
                                       bestIfUsedByDateStart: bestIfUsedByDateStartString,
                                       bestIfUsedByDateEnd: bestIfUseByDateEndString,
                                       count: 1,
                                       description: description)
            
            let hostingController = UIHostingController(rootView: ResultView(product: product, isPresent: isPresent, switchTabDelegate: self.switchTabDelegate).environmentObject(self.productManager))
            hostingController.modalPresentationStyle = .fullScreen
            self.present(hostingController, animated: true)
            completion(false)
        }
    }
    
    func getExpDate(ref: DatabaseReference, name: String, completion: @escaping (Int, String) -> Void) {
        ref.child("foods/\(name)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                print("데이터를 읽어오는 과정에서 에러가 발생했습니다.")
                return
            }
            
            if let expDate = value["expDate"] as? Int,
               let description = value["description"] as? String {
                print("expDate: \(expDate), description: \(description) setted!")
                
                completion(expDate, description)
                
            } else {
                print("expDate 또는 description 값을 찾을 수 없습니다.")
                return
            }
        })
        
    }
    
    func calculateExpiryDate(expDate: Int) -> Date {
        // 현재 날짜 가져오기
        let today = Date()
        
        // expDate 더하기
        let expiryDate = Calendar.current.date(byAdding: .day, value: expDate, to: today)!
        
        return expiryDate
    }
    
    
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("찰칵!")
        if let error = error {
            print(error)
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("error 발생")
            photoCaptureCompletionBlock(nil)
            return
        }
        
        let image = UIImage(data: imageData)
        let cropImage = cropToSquare(image: image)
        photoCaptureCompletionBlock(cropImage)
    }
    
    func cropToSquare(image: UIImage?) -> UIImage? {
        guard let image = image else {
            print("error: 이미지 없음")
            return nil
        }
        
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        let rect = UIScreen.main.bounds
        let cameraOffset: CGFloat = 40
        
        let previewWidth = rect.width
        let previewHeight = rect.height
        
        // 프리뷰와 이미지의 비율 계산
        let heightRatio = originalHeight / previewHeight
        
        // 화면에서의 오프셋을 이미지의 오프셋으로 변환
        let offsetY = ((previewHeight - previewWidth) / 2 - cameraOffset) * heightRatio
        
        let cropSize = min(originalWidth, originalHeight)
        //        print("\n\n cropSize: \(cropSize)\n originalWidth: \(originalWidth)\n originalHeight: \(originalHeight)\n rect.height: \(rect.height)\n y: \((rect.height - rect.width) / 2 - cameraOffset)\n offsetY: \(offsetY)\n\n")
        
        let cropRect = CGRect(
            x: offsetY, // x, y 좌표계가 뒤집혀져 있는 것 같다.
            y: 0,
            width: cropSize - 1, // 1081로 나와서 -1을 해줌
            height: cropSize
        )
        
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            print("cgimage error")
            return image
        }
        
        //        print(cgImage.width, cgImage.height)
        
        return UIImage(cgImage: cgImage, scale: image.imageRendererFormat.scale, orientation: image.imageOrientation)
    }
}

protocol SwitchTabDelegate {
    func switchTab()
    func testSwitchTab()
}
