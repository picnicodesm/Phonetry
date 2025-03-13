//
//  LoginView.swift
//  Phonetry
//
//  Created by 김상민 on 2/18/24.
//

import SwiftUI

// Order of variable :  Section -> Large -> small


struct LoginView: View {
    @State var emailString: String = ""
    @State var password: String = ""
    @State private var showModal: Bool = false
    
    @EnvironmentObject var authVM: AuthenticationVM


    var body: some View {
        ZStack {
            Colors.background
            loginContents
                .foregroundColor(Colors.defaultTextColor)
        }
        .ignoresSafeArea()
        .navigationTitle("")
        .navigationBarHidden(true)
    }
    
    private var loginContents: some View {
        VStack {
            Spacer()
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .fill(.white)
                .overlay(
                    cardContents
                        .padding()
                )
                .aspectRatio(Constants.aspectRatio, contentMode: .fit)
                .padding()
            Spacer()
        }
    }
    
    // MARK: - TextFields
    private var cardContents: some View {
        VStack {
            Text("Log in")
                .font(.system(size: Constants.FontSize.title, weight: .bold))
            
            VStack(alignment: .leading, spacing: 0) {
                TextFieldForm(prompt: "Username", placement: "Enter Your Email", isSecure: false, text: $emailString)
                TextFieldForm(prompt: "Password", placement: "Enter Your Password", isSecure: true, text: $password)
                Spacer()
                buttonSection.offset(y: Constants.offsetY)
                Spacer()
            }
        }
    }
    
    private struct TextFieldForm: View {
        var prompt: String
        var placement: String
        var isSecure: Bool
        @Binding var text: String
        
        var body: some View {
            Text(prompt)
                .padding(Constants.Insets.promptInsets)
                .foregroundColor(Colors.defaultTextColor)
            ZStack {
                if isSecure {
                    SecureField("", text: $text)
                        .placeholder(placement, when: text.isEmpty)
                } else {
                    TextField("", text: $text)
                        .placeholder(placement, when: text.isEmpty)
                }
            }
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: Constants.borderCornerRadius)
                    .stroke(Colors.borderLine)
            }
            
        }
    }
    
    // MARK: - ButtonSection
    private var buttonSection: some View {
        VStack(spacing: 0) {
            loginButton
            signupText
        }
    }
    
    private var loginButton: some View {
        Button{
            authVM.login(email: emailString, password: password)
        } label: {
            Text("Log in")
                .font(.system(size: Constants.FontSize.ButtonTitle, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.verticalPadding)
        }
        .buttonStyle(.borderedProminent)
        .tint(Colors.background)
    }
    
    private var signupText: some View {
        Text("or sign up")
            .onTapGesture { showModal = true } // move to Sign up View
            .frame(maxWidth: .infinity)
            .padding(.vertical, Constants.verticalPadding)
            .fullScreenCover(isPresented: $showModal) {
                SignupView()
            }
    }
 
    // MARK: - Constants
    private struct Constants {
        static let cornerRadius: CGFloat = 20
        static let borderCornerRadius: CGFloat = 10
        static let verticalPadding: CGFloat = 10
        static let offsetY: CGFloat = 16
        static let aspectRatio: CGFloat = 0.85

        struct Insets {
            static let promptInsets: EdgeInsets =
            EdgeInsets(top: 20, leading: 0, bottom: 6, trailing: 0)
        }
        
        struct FontSize {
            static let title: CGFloat = 30
            static let ButtonTitle: CGFloat = 20
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationVM())
}
