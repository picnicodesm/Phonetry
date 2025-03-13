//
//  BarcodeScanner.swift
//  Phonetry
//
//  Created by 김상민 on 3/4/24.
//

import SwiftUI
import AVFoundation

struct BarcodeScanner: UIViewControllerRepresentable {

    @Binding var result: String
    @Binding var needPermission: Bool
    @Binding var runCamera: Bool
    @Binding var isFirstTimeTurnOnTheCamera: Bool
    @Binding var captured: Bool
    @Binding var errorAlarmPresented: Bool

    
    @State private var resultViewPresent: Bool = false
    @State private var productResponse: ProductResponse?
    
    @EnvironmentObject var productManager: ProductManager
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<BarcodeScanner>) -> UIViewController {
        // Create a QR code scanner
        let scannerViewController = BarcodeScannerController()
        scannerViewController.delegate = context.coordinator
        scannerViewController.permissionDelegate = context.coordinator
        scannerViewController.productManager = productManager
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<BarcodeScanner>) {
        // Update the view controller
        guard let scannerViewController = uiViewController as? BarcodeScannerController else { return }
        if captured {
            scannerViewController.captureSession.stopRunning()
        }
        
        if runCamera && !isFirstTimeTurnOnTheCamera { // 처음이 아닌 경우에만 카메라를 실행하도록
            captured = false
            DispatchQueue.global(qos: .background).async {
                scannerViewController.captureSession.startRunning()
            }
        }
        
        if resultViewPresent {
            if let productResponse = productResponse {
                scannerViewController.presentResultView(productInfo: productResponse.service.productInfoRow[0], $resultViewPresent)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator($result, $needPermission, $runCamera, $isFirstTimeTurnOnTheCamera, $captured, $productResponse, $resultViewPresent, $errorAlarmPresented)
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate, AVPermissionDelegate{
        @Binding var scanResult: String
        @Binding var needPermission: Bool
        @Binding var runCamera: Bool
        @Binding var isFirstTimeTurnOnTheCamera: Bool
        @Binding var captured: Bool
        @Binding var productResponse: ProductResponse?
        @Binding var resultViewPresent: Bool
        @Binding var errorAlarmPresented: Bool
        private var apiKey: String {
                guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
                    fatalError("API_KEY not found in Info.plist")
                }

            return apiKey
        }
        
        init(_ scanResult: Binding<String>, _ needPermission: Binding<Bool>, _ runCamera: Binding<Bool>, _ isFirstTimeTurnOnTheCamera: Binding<Bool>, _ captured: Binding<Bool>, _ productResponse: Binding<ProductResponse?>, _ resultViewPresent: Binding<Bool>, _ errorAlarmPresented: Binding<Bool>) {
            self._scanResult = scanResult
            self._needPermission = needPermission
            self._runCamera = runCamera
            self._isFirstTimeTurnOnTheCamera = isFirstTimeTurnOnTheCamera
            self._captured = captured
            self._productResponse = productResponse
            self._resultViewPresent = resultViewPresent
            self._errorAlarmPresented = errorAlarmPresented
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            // Check if the metadata object contains a Bar code
            if metadataObjects.count == 0 {
                return
            }
            
            // Get the first metadata object
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            // Check if the Bar code contains a valid code
            if MetaDataObjectTypes.usingTpyes.contains(metadataObj.type) , let codeNumber = metadataObj.stringValue {
                // Handle
                scanResult = codeNumber
                
                if runCamera { // If the cammera is running
                    print("api 호출")
                    runCamera = false
                    isFirstTimeTurnOnTheCamera = false
                    captured = true
                    startLoad(barcodeNum: codeNumber)
                }
            }
        }
        
        func startLoad(barcodeNum: String) {
            let urlString = "https://openapi.foodsafetykorea.go.kr/api/\(apiKey)/C005/json/1/1/BAR_CD=\(barcodeNum)"
            
            guard let url = URL(string: urlString) else {
                print("URL을 가져오는 과정에서 에러가 발생했습니다.")
                self.errorAlarmPresented = true
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if error != nil {
                    print("ERROR: \(error?.localizedDescription)")
                    self.errorAlarmPresented = true
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                    print("HTTP ERROR!")
                    self.errorAlarmPresented = true
                    return
                }
                
                if let mimeType = httpResponse.mimeType, mimeType == "application/json",
                    let data = data,
                    let _ = String(data: data, encoding: .utf8) {
                    self.productResponse = try? JSONDecoder().decode(ProductResponse.self, from: data)
                }
 
                if self.productResponse != nil {
                    self.resultViewPresent = true
                } else {
                    print("error oocured!")
                    self.errorAlarmPresented = true
                }
            }
            
            task.resume()
        }
        
        func checkPermission(granted: Bool) {
            if granted {
                needPermission = false
            } else {
                needPermission = true
            }
        }
    }
}
