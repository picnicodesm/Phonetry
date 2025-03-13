//
//  LocalNotificationHelper.swift
//  Phonetry
//
//  Created by 김상민 on 5/12/24.
//

import Foundation
import NotificationCenter
import FirebaseDatabase
import Firebase
import SwiftUI

class LocalNotificationHelper {
    static let shared = LocalNotificationHelper()
    let ref: DatabaseReference = Database.database().reference()
    var productManger: ProductManager!
    
    var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    @Published var notificationSettings: UNNotificationSettings?
    
    init() { }
    
    func setAuthorization(productManager: ProductManager) {
        LocalNotificationHelper.shared.productManger = productManager
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound] // 필요한 알림 권한을 설정
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                if granted {
                    print("알림 허용됨")
                    print("count: \(self.productManger.products.count)")
                    
                    self.calculateExpiringItems { title, body in
                        self.pushNotification(title: title, body: body, seconds: 60, identifier: "얼마남지않은음식")
                    }
                    
                } else {
                    print("알림 거부됨")
                }
            }
        )
        
        self.setNotificationInFireBase()
    }
    
    // 현재 알림 설정을 가져오는 함수
    func getNotificationSettings(completion: @escaping (UNNotificationSettings) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationSettings = settings
                completion(settings)
            }
        }
    }
    
    // 사용자가 권한을 허용했는지 확인하는 함수
    func isNotificationAuthorized(completion: @escaping (Bool) -> Void) {
        getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                completion(true)
            case .denied, .notDetermined, .ephemeral:
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    }
    
    func setNotificationInFireBase() {
        isNotificationAuthorized { isAuthorized in
            guard let currentUserID = self.currentUserID else {
                print("ProductManager: 유저 아이디 획득 실패")
                return
            }
            // firebase에 저장
            self.ref.child("users/\(currentUserID)/notificationEnabled").setValue(isAuthorized)
        }
    }
    
    func calculateExpiringItems(completion: @escaping (String, String) -> Void) {
        let count = productManger.calculateExpiringItemsCount(items: productManger.products)
        let title = "소비기한 알리미"
        let body = "3일 이하로 남은 음식이 \(count)개 있어요!, product: \(productManger.products.count)"
        
        completion(title, body)
    }
    
    func pushNotification(title: String, body: String, seconds: Double, identifier: String) {
        print("Notification Setted")
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests() // 기존 알림 요청 제거
        
        // 알림 내용, 설정
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = body
        
        var dateComponents = DateComponents()
        dateComponents.hour = 08  // 원하는 시간 (예: 오전 9시)
        dateComponents.minute = 30
        
        // 조건(시간, 반복)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: true)
        
        // 요청
        let request = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)
        
        // 알림 등록
        center.add(request) { error in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
}

