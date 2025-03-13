//
//  StartView.swift
//  Phonetry
//
//  Created by 김상민 on 2/18/24.
//

import SwiftUI

struct StartView: View {
    enum Destination {
        case login
        case signUp
    }
    
    @State var tag: Int? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.background
                VStack {
                    appImage
                        .padding(EdgeInsets(top: 60, leading: 0, bottom: 0, trailing: 0))
                    loginSection
                        .padding(Constants.Insets.loginFormInsets)
                    Spacer()
                }
            }
            .ignoresSafeArea()
        }
        .navigationViewStyle(.stack)
    }
    
    private var appImage: some View {
        // change to custom image
        Image(systemName: "house")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(Constants.scaleEffect)
            .foregroundStyle(.white)
    }
    
    // MARK: - Login Section
    private var loginSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ButtonForm<LoginView>(prompt: "이미 회원이신가요?", title: "Login") { LoginView() }
            ButtonForm<SignupView>(prompt: "처음 사용하시나요?", title: "Sign up") { SignupView() }
        }
    }
    
    private struct ButtonForm<DestinationView: View> : View {
        let prompt: String
        let title: String
        let destination: DestinationView
        
        init(prompt: String, title: String, @ViewBuilder destination: () -> DestinationView) {
            self.prompt = prompt
            self.title = title
            self.destination = destination()
        }
        
        var body: some View {
            Text(prompt)
                .padding(Constants.Insets.promptInsets)
                .font(.system(size: Constants.Fonts.prompt))
                .foregroundStyle(.white)
            
            NavigationLink(destination: destination ){
                Rectangle()
                    .fill(.white)
                    .frame(maxWidth: .infinity, minHeight: Constants.buttonHeight, maxHeight: Constants.buttonHeight)
                    .cornerRadius(10)
                    .overlay(
                        Text(title)
                            .foregroundColor(Colors.defaultTextColor)
                            .font(.system(size: Constants.Fonts.buttonTitle))
                    )
            }
        }
    }
    
    // MARK: Move to homepage
    private var visitHomepageButton: some View {
        Button(action: {}, label: {
            Text("Phonetry homepage")
                .font(.system(size: Constants.Fonts.buttonTitle))
                .tint(.white)
        })
    }
    // MARK: - Constants
    private struct Constants {
        static let scaleEffect: CGFloat = 0.6
        static let verticalPadding: CGFloat = 9
        static let buttonHeight: CGFloat = 64
        
        struct Insets {
            static let loginFormInsets: EdgeInsets =
            EdgeInsets(top: 40, leading: 40, bottom: 50, trailing: 40)
            static let promptInsets: EdgeInsets =
            EdgeInsets(top: 20, leading: 0, bottom: 5, trailing: 0)
        }
        
        struct Fonts {
            static let prompt: CGFloat = 15
            static let buttonTitle: CGFloat = 20
        }
    }
    
}

#Preview {
    StartView()
}
