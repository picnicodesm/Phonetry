//
//  SettingView.swift
//  Phonetry
//
//  Created by 김상민 on 2/21/24.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var authVM: AuthenticationVM
    @EnvironmentObject var productManager: ProductManager
    @Environment(\.presentationMode) var presentation
    
    @State private var alarmPresent: Bool = false
    @State var isPresent: Bool = false
    
    @Binding var tag: Int?
    @Binding var index: Int
    
    let notificationHelper = LocalNotificationHelper.shared
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 40)
            
            Text("Setting For Users")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                NavigationLink (destination: NotificationView()) {
                    HStack{
                        Text("Notification")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                        .frame(maxWidth: .infinity, maxHeight: 60, alignment: .leading)
                        .padding(.horizontal)
                }
                Divider()
//                NavigationLink (destination: ThemeView(tag: $tag, index: $index)) { // navigation icon을 두 번째로 누를 때 에러 발생
                    HStack{
                        Text("Theme")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                        .frame(maxWidth: .infinity, maxHeight: 60, alignment: .leading)
                        .padding(.horizontal)
                        .background(.white)
                        .onTapGesture {
                            isPresent = true
                        }
                        .fullScreenCover(isPresented: $isPresent) {
                            ThemeView(tag: $tag, index: $index)
                        }
//                }
                Divider()
                Text("Log Out")
                    .frame(maxWidth: .infinity, maxHeight: 60, alignment: .leading)
                    .padding(.horizontal)
                    .background(.white)
                    .onTapGesture {
                        alarmPresent = true
                    }
                    .alert(Text("로그아웃"), isPresented: $alarmPresent) {
                        Button("네") {
                            alarmPresent = false
                            authVM.logout()
                        }
                        Button("아니요", role: .cancel) {
                            alarmPresent = false
                        }
                    } message: {
                        Text("로그아웃 하시겠습니까?")
                    }
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: GlobalConstants.cornerRadius))
            .padding(.horizontal)
   
            Spacer()
            
            closeButton
            
            Spacer()
                .frame(height: 20)
        }
        .navigationTitle("setting")
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .background(Colors.systemGroupedBackgroundLight)
        .foregroundColor(Colors.defaultTextColor)
        .onDisappear {
            notificationHelper.setAuthorization(productManager: productManager)
        }
    }
    
    private var closeButton: some View {
        Button{
            presentation.wrappedValue.dismiss()
        } label: {
            Text("Back")
                .font(.system(size: Constants.FontSize.ButtonTitle, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.verticalPadding)
        }
        .padding(.horizontal)
        .buttonStyle(.borderedProminent)
        .tint(Colors.background)
    }
    
    // MARK: - Constants
    private struct Constants {
        //        static let cornerRadius: CGFloat = 20
        //        static let borderCornerRadius: CGFloat = 10
        static let verticalPadding: CGFloat = 10
        //        static let offsetY: CGFloat = 16
        //        static let aspectRatio: CGFloat = 0.85
        
        //        struct Insets {
        //            static let promptInsets: EdgeInsets =
        //            EdgeInsets(top: 20, leading: 0, bottom: 6, trailing: 0)
        //        }
        
        struct FontSize {
            //            static let title: CGFloat = 30
            static let ButtonTitle: CGFloat = 20
        }
    }
}

#Preview {
    SettingView(tag: .constant(nil), index: .constant(3))
}
