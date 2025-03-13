//
//  CameraView.swift
//  Phonetry
//
//  Created by 김상민 on 2/20/24.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @Binding var index: Int
    @State private var result: String = "barcode results"
    @State private var needPermission: Bool = true
    @State private var alarmPresented: Bool = false // permission에 관한 알람
    @State private var runCamera: Bool = true
    @State private var isFirstTimeTurnOnTheCamera: Bool = true
    @State private var captured: Bool = false
    @State private var isPresented: Bool = false
    @State private var isScan: Bool = true // true: scan, false: take picture
    @State private var cameraCaptured: Bool = false
    @State private var errorAlarmPresented: Bool = false // 스캔 또는 촬영 시 에러가 날 경우 알림을 위한 변수
    @State private var tabbarHidden: Bool = true
    
    @StateObject var classificationVM = ImageClassificaionVM()
    @EnvironmentObject var productManager: ProductManager
    
    private let rect = UIScreen.main.bounds
    private var cameraHeight: CGFloat {
        return rect.width
    }
    private let cameraOffset: CGFloat = 40
    
    var body: some View {
        ZStack {
            if !needPermission {
                if isScan {
                    BarcodeScanner(result: $result, needPermission: $needPermission, runCamera: $runCamera, isFirstTimeTurnOnTheCamera: $isFirstTimeTurnOnTheCamera, captured: $captured, errorAlarmPresented: $errorAlarmPresented)
                        .onAppear {
                            if !isFirstTimeTurnOnTheCamera {
                                runCamera = true // 두 번째부터 실행
                            }
                        }
                        .environmentObject(productManager)
                } else {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(.black)
                            .frame(width: rect.width, height: (rect.height - cameraHeight) / 2 - cameraOffset)
                        PhotoCamera(needPermission: $needPermission, runCamera: $runCamera, isFirstTimeTurnOnTheCamera: $isFirstTimeTurnOnTheCamera, captured: $cameraCaptured, index: $index, isScan: $isScan, classificationVM: classificationVM) { newImage in
                            self.classificationVM.capturedImage = newImage
                        }
                        Rectangle()
                            .fill(.black)
                            .frame(width: rect.width, height: (rect.height - cameraHeight) / 2 + cameraOffset)
                    }
            
                    Button(action: {cameraCaptured = true}) {
                        Text("Take Picture")
                    }
                    .padding()
                    .background(Color(.black).opacity(0.5))
                    .tint(Colors.background)
                    .offset(y: 100)
                    .buttonBorderShape(.roundedRectangle)
                }
                ScannerOverlayView(isScan: $isScan, cameraCaptured: $cameraCaptured)
                
            } else {
                permissionAlertView
            }
        }
        .ignoresSafeArea()
        .toolbar(tabbarHidden ? .hidden : .visible, for: .tabBar)
        .overlay(alignment: .topLeading) {
            Button {
                self.index = 0
            } label: {
                Image(systemName: "arrow.left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                    .foregroundColor(.white)
            }.padding()
        }
        .onAppear {
            needPermission = false
//            TabBarModifier.hideTabBar()
            tabbarHidden = true
        }
        .onDisappear {
//            TabBarModifier.showTabBar()
            tabbarHidden = false
        }
        .alert(Text("권한"), isPresented: $alarmPresented) {
            Button("설정으로 이동하기") {
                guard let settingURL = URL(string: UIApplication.openSettingsURLString),
                      UIApplication.shared.canOpenURL(settingURL)
                else { return }
                UIApplication.shared.open(settingURL, options: [:])
            }
            Button("cancel", role: .cancel) {
                alarmPresented = false
                self.index = 0
            }
        } message: {
            Text("This is Test Alart")
        }
        .alert(Text("ERROR"), isPresented: $errorAlarmPresented) {
            Button("닫기") {
                errorAlarmPresented = false
                runCamera = true
            }
        } message: {
            Text("없는 상품이거나 서버에 연결할 수 없습니다.")
        }
        .onChange(of: needPermission) { newValue in
            if newValue {
                alarmPresented = true
            }
        }
        .onChange(of: classificationVM.capturedImage) { newImage in
            classificationVM.sendImage(errorAlarmPresented: $errorAlarmPresented)
        }
//        .hiddenTabBar()
    }
    
    private var permissionAlertView: some View {
        Rectangle()
            .fill(.black)
            .overlay {
                Text("카메라 권한이 필요합니다.")
                    .foregroundStyle(.white)
                    .onTapGesture {
                        self.index = 0
                    }
            }
    }
}



#Preview {
    CameraView(index: .constant(0)).environmentObject(ProductManager(text: "preview"))
}


