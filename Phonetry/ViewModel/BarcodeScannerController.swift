//
//  BarcodeScanViewController.swift
//  Phonetry
//
//  Created by 김상민 on 3/4/24.
//

import Foundation
import UIKit
import AVFoundation
import SwiftUI

class BarcodeScannerController: UIViewController {
    var productManager: ProductManager!
    
    // Set up the camera and capture session
    let captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
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
    
    var delegate: AVCaptureMetadataOutputObjectsDelegate?
    var permissionDelegate: AVPermissionDelegate?
    
    typealias Scanner = GlobalConstants.Scanner
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        Task {
            if await isAuthorized {
                
                // Set up the capture session
                let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
                guard let captureDevice = captureDevice else { fatalError("There is no camera")}
                
                captureSession.beginConfiguration()
                
                // Set up the metadata input
                let input = try? AVCaptureDeviceInput(device: captureDevice)
                guard let input = input else { fatalError("Can't find input") }
                captureSession.addInput(input)
                
                // Set up the metadata output
                let captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession.addOutput(captureMetadataOutput)
                captureMetadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = MetaDataObjectTypes.usingTpyes
                
                
                // Set up the videoPreviewLayer
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                guard let videoPreviewLayer = videoPreviewLayer else { fatalError("Can't make a videoPreviewLayer") }
                
                let rect = UIScreen.main.bounds
                videoPreviewLayer.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
                videoPreviewLayer.videoGravity = .resizeAspectFill
                view.layer.addSublayer(videoPreviewLayer)
                
                // Set up the rectOfInterest - The specific section for scan. Not whole screen
                let rectOfInterest = CGRect(x: Scanner.offsetX, y: Scanner.offsetY, width: Scanner.width, height: Scanner.height)
                let rectConverted = videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: rectOfInterest) // 화면 크기에서 0,0,1,1비율로 바꿔줌
                captureMetadataOutput.rectOfInterest = rectConverted
                
                captureSession.commitConfiguration()
                
                // Start the capture session
                DispatchQueue.global(qos: .background).async {
                    self.captureSession.startRunning()
                }
            }
        }
    }
    
    func presentResultView(productInfo: ProductInfo, _ isPresent: Binding<Bool>) {
        let dateFormatter = CustomDateFormatter()
        let dateString = productInfo.bestIfUsedByDate
        guard let number = extractNumber(from: dateString) else {
            print("숫자를 추출할 수 없습니다.")
            return
        }
        
        // 현재 날짜
        let currentDate = Date()
            
        // 현재 날짜에 개월 수를 더한 날짜 계산
        guard let bestIfUseByDateEnd = addMonths(from: currentDate, months: number) else {
            print("날짜를 계산할 수 없습니다.")
            return
        }
        print("현재 날짜에서 \(number)개월을 더한 날짜는 \(bestIfUseByDateEnd)입니다.")
        
        let bestIfUsedByDateStartString = dateFormatter.getStringFromDate(date: Date())
        let bestIfUseByDateEndString = dateFormatter.getStringFromDate(date: bestIfUseByDateEnd)
        
        let product = ProductModel(productName: productInfo.productName,
                                   bestIfUsedByDateStart: bestIfUsedByDateStartString,
                                   bestIfUsedByDateEnd: bestIfUseByDateEndString,
                                   count: 1, description: "\(productInfo.productName)의 소비기한은 제조일로부터 \(number)개월 입니다.")

        let hostingController = UIHostingController(rootView: ResultView(product: product, isPresent: isPresent, switchTabDelegate: nil).environmentObject(productManager))
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }
    
    // 문자열에서 숫자를 추출하는 함수
    private func extractNumber(from string: String) -> Int? {
        // 정규표현식 패턴
        let pattern = #"(\d+)"#
        
        // 정규표현식을 사용하여 문자열에서 숫자 추출
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
            
            // 첫 번째 매치의 숫자 추출
            if let match = matches.first {
                let range = match.range(at: 0)
                if let swiftRange = Range(range, in: string) {
                    let numberString = string[swiftRange]
                    return Int(numberString)
                }
            }
        }
        
        return nil
    }

    // 현재 날짜에서 일정 개월 수를 더한 날짜를 반환하는 함수
    private func addMonths(from date: Date, months: Int) -> Date? {
        return Calendar.current.date(byAdding: .month, value: months, to: date)
    }
    
}

protocol AVPermissionDelegate {
    func checkPermission(granted: Bool)
    // 권한을 확인해서 needPermission변수를 변경
}
