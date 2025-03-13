//
//  ThemeView.swift
//  Phonetry
//
//  Created by 김상민 on 4/7/24.
//

import SwiftUI

struct ThemeView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var tabBarThemeColorVM: TabBarThemeColorVM
    
    @State private var selectedColor: Color = Colors.background
    @Binding var tag: Int?
    @Binding var index: Int
    
    private let colorManager = ThemeColorManager()
    private let baseColor = Color("background")
    private let warmColor = Color(red: 241/255, green: 170/255, blue: 60/255)
    private let coolColor = Color(red: 118/255, green: 194/255, blue: 242/255)
    
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 40)
            
            HStack(spacing: 40) {
                VStack {
                    Circle()
                        .fill(baseColor)
                        .frame(width: 72)
                        .onTapGesture {
                            self.selectedColor = baseColor
                        }
                    Text("Base")
                        .font(.system(size: 20, weight: .semibold))
                }
                
                VStack {
                    Circle()
                        .fill(warmColor)
                        .frame(width: 72)
                        .onTapGesture {
                            self.selectedColor = warmColor
                        }
                    Text("warm")
                        .font(.system(size: 20, weight: .semibold))
                }
                
                VStack {
                    Circle()
                        .fill(coolColor)
                        .frame(width: 72)
                        .onTapGesture {
                            self.selectedColor = coolColor
                        }
                    Text("Cool")
                        .font(.system(size: 20, weight: .semibold))
                }
            }
            .padding()
            
            HStack {
                Text("Choose Color")
                Spacer()
                ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                Spacer()
                Spacer()
            }
            .padding()
            .foregroundColor(.white)
            .font(.system(size: 24, weight: .semibold))
            .frame(maxWidth: .infinity, maxHeight: 60)
            .background(.black)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            
            Spacer()
                .frame(height: 60)
            
            Circle()
                .fill(selectedColor)
                .frame(width: 144)
            
            Text("Current")
                .font(.system(size: 24, weight: .semibold))
            
            Spacer()
            
            buttonSection
        }
        .navigationTitle("Theme")
        .navigationBarTitleDisplayMode(.inline)
        .background(Colors.systemGroupedBackgroundLight)
        .foregroundColor(Colors.defaultTextColor)
    }
    
    private var buttonSection: some View {
        HStack(spacing: 0) {
            saveButton
            closeButton
        }
    }
    
    private var closeButton: some View {
        Button{
            presentation.wrappedValue.dismiss()
        } label: {
            Text("뒤로가기")
                .font(.system(size: Constants.FontSize.ButtonTitle, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.verticalPadding)
        }
        .padding(.horizontal)
        .buttonStyle(.borderedProminent)
        .tint(Colors.background)
    }
    
    private var saveButton: some View {
        Button{
            Colors.background = selectedColor
            tabBarThemeColorVM.themeColor = Colors.background
            
            print("\(selectedColor)")
            let navBarAppearence = UINavigationBarAppearance()
            let scrollNavBarAppearance = UINavigationBarAppearance()
            
            navBarAppearence.backgroundColor = UIColor(Colors.background)
            scrollNavBarAppearance.backgroundColor = UIColor(Colors.background.opacity(Constants.navBarBackgroundOpacityWhenScrolling))
   
            UINavigationBar.appearance().standardAppearance = scrollNavBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearence
         
            
            // database에 저장
            guard let themeColorRGB = selectedColor.getRGB() else {
                print("변환 실패")
                return
            }
            let themeColor = ThemeColor(red: themeColorRGB.red, green: themeColorRGB.green, blue: themeColorRGB.blue)
            colorManager.saveThemeColor(themeColor)
            
            self.index = 0
            presentation.wrappedValue.dismiss()
            tag = nil
        } label: {
            Text("저장")
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
    struct Constants {
        static let navBarBackgroundOpacityWhenScrolling: CGFloat = 0.7
        static let verticalPadding: CGFloat = 10
        
        struct FontSize {
            static let ButtonTitle: CGFloat = 20
        }
    }
}

#Preview {
    ThemeView(tag: .constant(nil), index: .constant(3))
}

