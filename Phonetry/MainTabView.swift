//
//  MainTabView.swift
//  Phonetry
//
//  Created by 김상민 on 3/31/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var index: Int = 0
    @State private var flag: Bool = false
    
    @EnvironmentObject var productManager: ProductManager
    @StateObject private var tabBarThemeColorVM = TabBarThemeColorVM()
    
    var body: some View {
//        NavigationView {
            TabView(selection: $index) {
                MainView()
                    .tabItem {
                        VStack {
                            Image(systemName: "house.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("Home")
                                .font(.system(size: 10))
                                .fontWeight(.semibold)
                        }
                    }
                    .tag(0)
                    .environmentObject(productManager)
                StorageView()
                    .tabItem {
                        VStack {
                            Image(systemName: "archivebox.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("Storage")
                                .font(.system(size: 10))
                                .fontWeight(.semibold)
                        }
                    }
                    .tag(1)
                    .environmentObject(productManager)
                    .environmentObject(tabBarThemeColorVM)
                CameraView(index: $index)
                    .tabItem {
                        VStack {
                            Image(systemName: "camera.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("Camera")
                                .font(.system(size: 10))
                                .fontWeight(.semibold)
                        }
                    }
                    .tag(2)
                    .environmentObject(productManager)
                ProfileView(index: $index)
                    .environmentObject(tabBarThemeColorVM) // 없어도 될 것
                    .environmentObject(productManager)
                    .tabItem {
                        VStack {
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("Profile")
                                .font(.system(size: 10))
                                .fontWeight(.semibold)
                        }
                    }.tag(3)
            }
            .tint(tabBarThemeColorVM.themeColor)
            .onAppear {
                print("탭뷰 나타남")
            }
            .onDisappear {
                print("Tabview 사라짐")
                //                productManager.stopListening()
            }
//        }
        .accentColor(Colors.background)
    }
    
    // MARK: - Constants
    struct Constants {
        static let navBarBackgroundOpacityWhenScrolling: CGFloat = 0.7
    }
}


#Preview {
    MainTabView()
}
