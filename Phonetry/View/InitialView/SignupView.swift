//
//  SignupView.swift
//  Phonetry
//
//  Created by 김상민 on 2/18/24.
//

import SwiftUI

// Email형식만 맞으면 됨
// 비밀번호는 6자리 이상

struct SignupView: View {
    @Environment(\.presentationMode) var presentation
    
    @State private var emailString: String = ""
    @State private var password: String = ""
    @State private var confirmpw: String = ""
    @State private var isEmailTypeError: Bool = false // true로 설정하기
    @State private var isPasswordCountError: Bool = true
    @State private var isConfirmpwEqualError: Bool = true
    
    @EnvironmentObject var authVM: AuthenticationVM
    
    var body: some View {
        ZStack {
            Colors.background
            signupContents
                .foregroundColor(Colors.defaultTextColor)
        }
        .ignoresSafeArea()
        .navigationTitle("")
        .navigationBarHidden(true)
    }
    
    private var signupContents: some View {
        VStack {
            Spacer()
            signupCard
            Spacer()
        }
    }
    
    private var signupCard: some View {
        RoundedRectangle(cornerRadius: Constants.cornerRadius)
            .fill(.white)
            .overlay(
                cardContents
                    .padding()
            )
            .aspectRatio(Constants.aspectRatio, contentMode: .fit)
            .padding()
    }
    
    private var cardContents: some View {
        VStack {
            Text("Sign up")
                .font(.system(size: Constants.Fonts.title, weight: .bold))
            
            VStack(alignment: .leading, spacing: 0) {
                // Email
                TextFieldForm(prompt: "User Email", placement: "Example.example.com", isSecure: false, text: $emailString)
                    .onChange(of: emailString) { value in
                        // 이메일 형식: ㅁㅁ @ ㅁㅁㅁ.com
                    }
                Text("이메일 형식에 맞게 입력해주세요.")
                    .font(.system(size: 12))
                    .foregroundColor(!emailString.isEmpty && isEmailTypeError ? .red : .clear)
                    .offset(y: 3)
                
                // Password
                TextFieldForm(prompt: "Password", placement: "Enter Password", isSecure: true, text: $password)
                    .onChange(of: password) { value in
                        isPasswordCountError = value.count < 6 ? true : false
                    }
                Text("비밀번호는 6자리 이상 입력해주세요.")
                    .font(.system(size: 12))
                    .foregroundColor(!password.isEmpty && isPasswordCountError ? .red : .clear)
                    .offset(y: 3)
                
                // Confirm Password
                TextFieldForm(prompt: "Confirm Password", placement: "Confirm Password", isSecure: true, text: $confirmpw)
                    .onChange(of: confirmpw) { value in
                        isConfirmpwEqualError = password != confirmpw ? true : false
                    }
                Text("비밀번호가 일치하기 않습니다.")
                    .font(.system(size: 12))
                    .foregroundColor(!confirmpw.isEmpty && isConfirmpwEqualError ? .red : .clear)
                    .offset(y: 3)
                
                Spacer()
                    .frame(height: 30)
                
                // Button
                buttonSection
                    .offset(y: Constants.offsetYDown)
            }
        }
    }
    
    // MARK: - Text Fields    
    private struct TextFieldForm: View {
        var prompt: String
        var placement: String
        var isSecure: Bool
        @Binding var text: String
        
        var body: some View {
            Text(prompt)
                .padding(Constants.Insets.promptInsets)
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
    
    // MARK: - Button Section
    private var buttonSection: some View {
        VStack(spacing: Constants.spacing) {
            submitButton
            backButton
        }
    }
    
    private var submitButton: some View {
        Button {
            authVM.registerUser(email: emailString, password: password) { isSuccess in
                if isSuccess {
                    presentation.wrappedValue.dismiss()
                } else {
                    print("회원가입 제대로 안됨")
                }
                // 가입한 걸로 로그인하라고 안내메시지?
            }
        } label: {
            Text("Submit")
                .font(.system(size: Constants.Fonts.buttonTitle, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.verticalPadding)
        }
        .buttonStyle(.borderedProminent)
        .tint(Colors.background)
        .disabled(!isEmailTypeError && !isPasswordCountError && !isConfirmpwEqualError ? false : true)
    }
    
    private struct SignupButton: View {
        var imageName: String
        var text: String
        
        var body: some View {
            Button(action: {}, label: {
                HStack {
                    Image(systemName: imageName)
                    Text(text)
                }
                .font(.system(size: Constants.Fonts.secondButtonTitle))
                .foregroundColor(.black)
                .padding(.vertical, Constants.verticalPadding)
                .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
            .tint(Colors.subButtonBackground)
        }
    }
    
    private var backButton: some View {
        Button{
            presentation.wrappedValue.dismiss()
        } label: {
            Text("Cancel")
                .font(.system(size: Constants.Fonts.buttonTitle, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.verticalPadding)
        }
        .buttonStyle(.borderedProminent)
        .tint(Colors.background)
    }
    
    // MARK: - Constants
    private struct Constants {
        static let cornerRadius: CGFloat = 20
        static let borderCornerRadius: CGFloat = 10
        static let aspectRatio: CGFloat = 3/5
        static let offsetYDown: CGFloat = 0
        static let offsetYUp: CGFloat = -16
        static let spacing: CGFloat = 8
        static let verticalPadding: CGFloat = 12
        
        struct Insets {
            static let promptInsets: EdgeInsets =
            EdgeInsets(top: 20, leading: 0, bottom: 6, trailing: 0)
        }
        
        struct Fonts {
            static let title: CGFloat = 30
            static let buttonTitle: CGFloat = 20
            static let secondButtonTitle: CGFloat = 16
        }
    }
    
}


#Preview {
    SignupView()
        .environmentObject(AuthenticationVM())
}
