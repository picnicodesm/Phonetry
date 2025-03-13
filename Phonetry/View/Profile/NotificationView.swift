//
//  NotificationView.swift
//  Phonetry
//
//  Created by 김상민 on 4/7/24.
//

// Notification, Date

import SwiftUI

struct NotificationView: View {
    @Environment(\.presentationMode) var presentation
    let notificationHelper = LocalNotificationHelper.shared
    //    let notificationHelper = LocalNotificationHelper()
    @State private var isNotificationEnabled: Bool = false
    
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 40)
            
            HStack(spacing: 0) {
                Text(isNotificationEnabled ? "알림 끄기" : "알림 켜기")
                    .frame(maxWidth: .infinity, maxHeight: 60, alignment: .leading)
                    .padding(.horizontal)
                Spacer()
                Image(systemName: "chevron.right")
                Spacer()
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: GlobalConstants.cornerRadius))
            .padding(.horizontal)
            .onTapGesture {
                guard let settingURL = URL(string: UIApplication.openSettingsURLString),
                      UIApplication.shared.canOpenURL(settingURL)
                else { return }
                UIApplication.shared.open(settingURL, options: [:])
                presentation.wrappedValue.dismiss()
            }
            
            Spacer()
        }
        .navigationTitle("Notification")
        .navigationBarTitleDisplayMode(.inline)
        .background(Colors.systemGroupedBackgroundLight)
        .foregroundColor(Colors.defaultTextColor)
        .onAppear {
            notificationHelper.isNotificationAuthorized { isEnabled in
                self.isNotificationEnabled = isEnabled
            }
        }
        .onDisappear {
            notificationHelper.isNotificationAuthorized { isEnabled in
                notificationHelper.setNotificationInFireBase()
            }
        }
    }
}

#Preview {
    NotificationView()
}
