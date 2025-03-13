//
//  BarcodeScanner.swift
//  Phonetry
//
//  Created by 김상민 on 3/4/24.
//

import SwiftUI
import AVFoundation

struct PhotoCamera: UIViewControllerRepresentable {
    @Binding var needPermission: Bool
    @Binding var runCamera: Bool
    @Binding var isFirstTimeTurnOnTheCamera: Bool
    @Binding var captured: Bool
    @Binding var index: Int
    @Binding var isScan: Bool
    
    @State private var resultViewPresent: Bool = true // 여기선 쓸모 없는 변수(Scan에서 쓰임)
    
    @EnvironmentObject var productManager: ProductManager
    @ObservedObject var classificationVM: ImageClassificaionVM
    
    var captureImage: ((UIImage?) -> Void)
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PhotoCamera>) -> UIViewController {
        let cameraViewController = CameraController()
        cameraViewController.delegate = context.coordinator
        cameraViewController.permissionDelegate = context.coordinator
        cameraViewController.switchTabDelegate = context.coordinator
        context.coordinator.cameraViewController = cameraViewController // 없어도 되려나?
        cameraViewController.photoCaptureCompletionBlock = captureImage
        cameraViewController.productManager = productManager
        cameraViewController.classificationManager = classificationVM
        return cameraViewController
    }
    
    // 업데이트를 하는거에 너무 많은걸 넣으면 안좋은거같다.
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<PhotoCamera>) {
        guard let cameraViewController = uiViewController as? CameraController else { return }
        if captured {
            cameraViewController.takePicture(flag: false) { flag in
                DispatchQueue.main.async {
                    captured = flag
                }
            }
        } // 이 함수가 반복됨
        
//        if runCamera && !isFirstTimeTurnOnTheCamera { // 처음이 아닌 경우에만 카메라를 실행하도록
//            DispatchQueue.main.async {
//                captured = false
//            }
//            DispatchQueue.global(qos: .background).async {
//                cameraViewController.captureSession.startRunning()
//            }
//        }
        
        if classificationVM.isGetResult {
            if let foodName = classificationVM.classificationresponse?.prediction {
                cameraViewController.presentResultView(classificationResult: foodName, $resultViewPresent) { newState in // newState는 무조건 false가 반환. 다음 촬영을 위해 상태를 바꿔주는 것
                    DispatchQueue.main.async {
                        classificationVM.isGetResult = newState
                        captured = newState
                    }
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator($needPermission, $runCamera, $isFirstTimeTurnOnTheCamera, $captured, $resultViewPresent, parent: self)
    }
    
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate, AVPermissionDelegate, SwitchTabDelegate{
        @Binding var needPermission: Bool
        @Binding var runCamera: Bool
        @Binding var isFirstTimeTurnOnTheCamera: Bool
        @Binding var captured: Bool
        @Binding var resultViewPresent: Bool
        
        var cameraViewController: CameraController?
        var parent: PhotoCamera
        
        init(_ needPermission: Binding<Bool>, _ runCamera: Binding<Bool>, _ isFirstTimeTurnOnTheCamera: Binding<Bool>, _ captured: Binding<Bool>, _ resultViewPresent: Binding<Bool>, parent: PhotoCamera) {
            self._needPermission = needPermission
            self._runCamera = runCamera
            self._isFirstTimeTurnOnTheCamera = isFirstTimeTurnOnTheCamera
            self._captured = captured
            self._resultViewPresent = resultViewPresent
            self.parent = parent
        }
        
        func checkPermission(granted: Bool) {
            if granted {
                needPermission = false
            } else {
                needPermission = true
            }
        }
        
        func switchTab() {
            parent.index = 0
            parent.isScan = true
        }
        
        func testSwitchTab() {
            parent.isScan = true
        }
    }
}

