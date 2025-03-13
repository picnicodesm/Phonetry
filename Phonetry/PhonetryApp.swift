//
//  PhonetryApp.swift
//  Phonetry
//
//  Created by 김상민 on 2/18/24.
//

import SwiftUI
import FirebaseCore
import UserNotifications

//MARK: - delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Notificaton 설정
        // 앱 실행 시 사용자에게 알림 허용 권한을 받음
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Foreground(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
    }
}

//MARK: - main
@main
struct PhonetryApp: App {
    
    let navBarAppearence = UINavigationBarAppearance()
    let scrollNavBarAppearance = UINavigationBarAppearance()
    let tabBarAppearance = UITabBarAppearance()
    let scrollTabBarAppearance = UITabBarAppearance()
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authVM = AuthenticationVM()
    @StateObject var productManager = ProductManager(text: "PhonetryApp")
    @State private var isColorLoaded = false // 색상 로딩 상태
    @State private var isProductsLoaded = false // products 로딩 상태
    @State private var isLoadFinish = false //
    @State private var loadingText = "상태 정보 불러오는 중..."
    @State private var backgroundColor = Colors.background
    
    
    init() {
        navBarAppearence.backgroundColor = UIColor(Colors.background)
        scrollNavBarAppearance.backgroundColor = UIColor(Colors.background.opacity(Constants.navBarBackgroundOpacityWhenScrolling))
        
        UINavigationBar.appearance().standardAppearance = scrollNavBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearence
        
        tabBarAppearance.backgroundColor = .white
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            if authVM.checkLoginAlready() {
                if isLoadFinish {
                        MainTabView()
                            .environmentObject(authVM)  // Setting -> Logout에 사용
                            .environmentObject(productManager)
                    } else {
                        LoadingView(text: $loadingText, backgroundColor: $backgroundColor, duration: 0.5)
                            .onAppear {
                                loadThemeColor()
                            }
                    } // storage  정보
            } else {
                StartView()
                    .environmentObject(authVM)
            }
        }
        
    }
    
    //MARK: - Functions
    private func loadThemeColor() {
        let colorManager = ThemeColorManager()
        colorManager.loadThemeColor { themeColor in
            guard let themeColor = themeColor else {
                print("Background color load failed")
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Colors.background = Color(red: themeColor.red, green: themeColor.green, blue: themeColor.blue)
                updateNavBarAppearance()
//                updateTabBarAppearance()
                backgroundColor = Colors.background
                isColorLoaded = true // 색상 로딩 완료
                loadingText = "Storage 가져오는 중..."
                loadProducts()
            }
        }
    }
    
    private func loadProducts() {
        productManager.listenToRealtimeDatabase() { isLoad in
            print("product load: \(isLoad)")
            if isLoad {
                LocalNotificationHelper.shared.setAuthorization(productManager: productManager)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isProductsLoaded = isLoad
                isLoadFinish = isLoad
                }
            }
        }
    }
    
    
    private func updateNavBarAppearance() {
        navBarAppearence.backgroundColor = UIColor(Colors.background)
        scrollNavBarAppearance.backgroundColor = UIColor(Colors.background.opacity(Constants.navBarBackgroundOpacityWhenScrolling))
        
        UINavigationBar.appearance().standardAppearance = scrollNavBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearence
    }
    
    private func updateTabBarAppearance() {
        tabBarAppearance.backgroundColor = UIColor(Colors.background)
        scrollTabBarAppearance.backgroundColor = UIColor(Colors.background.opacity(Constants.navBarBackgroundOpacityWhenScrolling))
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .red
//        scrollTabBarAppearance.stackedLayoutAppearance.normal.iconColor = .red <- 이건 동작 안함
        
        UITabBar.appearance().standardAppearance = scrollTabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    //MARK: - Structure
    struct Constants {
        static let navBarBackgroundOpacityWhenScrolling: CGFloat = 0.7
    }
}

