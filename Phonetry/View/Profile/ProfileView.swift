//
//  ProfileView.swift
//  Phonetry
//
//  Created by 김상민 on 2/20/24.
//

import SwiftUI

// 투명도 값을 변화시키는 애니메이션을 만들어서 그 값을 호스팅뷰에 바인딩하고 그 투명도로 설정하는 함수는 update에 넣어

struct ProfileView: View {
    
    @State private var tag: Int?
    @State private var isShow: Bool = true
    
    @Binding var index: Int
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    profileSection
                        .aspectRatio(1.5, contentMode: .fit)
                        .padding()
                    
                    Divider()
                    
                    buttonSection
                        .padding()
                }
                .padding(.vertical)
            }
            .overlay {
                NavigationLink(destination: SettingView(tag: $tag, index: $index), tag: 1, selection: $tag) {}
            }
            .navigationTitle("Profile")
            .background(Colors.systemGroupedBackgroundLight)
            .navigationBarLargeTitleItems(trailing: largeTitleIcon, isShow: $isShow)
            .toolbar(.visible, for: .tabBar)
            .onAppear {
                tag = nil
                isShow = true
            }
            .onDisappear {
                isShow = false
            }
        }
    }
    
    private var largeTitleIcon: some View {
        Image(systemName: "gearshape.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 40)
            .scaleEffect(0.8)
            .foregroundColor(.white)
            .onTapGesture {
                self.tag = 1
                self.isShow = false
            }
    }
    
    // MARK: - Profile Section
    private var profileSection: some View {
        VStack(spacing: 0) {
            profileImage
            profileName
            detailButton
        }
    }
    
    private var profileImage: some View {
        Image(systemName: "person.fill")
            .resizable()
            .scaleEffect(0.8)
            .background(.green)
            .frame(width: 160)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(Circle())
            .foregroundColor(.black)
    }
    
    private var profileName: some View {
        Text("User Name")
            .font(.system(size: 30))
            .fontWeight(.semibold)
            .foregroundColor(.black)
    }
    
    private var detailButton: some View {
        HStack {
            Text("Detail")
                .fontWeight(.medium)
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
        }
        .font(.system(size: 18))
        .foregroundColor(.gray)
    }
    
    // MARK: - Button Section
    private var buttonSection: some View {
        HStack(spacing: 30) {
            CustomButton(imageString: "heart.fill", title: "Wishlist") {}
            CustomButton(imageString: "archivebox.fill", title: "Storage") {
                self.index = 1
            }
            CustomButton(imageString: "light.beacon.min.fill", title: "Hurry") {}
        }
    }
    
    private struct CustomButton: View {
        var imageString: String
        var title: String
        var buttonAction: () -> Void
        
        var body: some View {
            Button {
                buttonAction()
            } label: {
                VStack {
                    buttonImage
                    buttonTitle
                }
            }.buttonStyle(PlainButtonStyle())
        }
        
        var buttonImage: some View {
            Circle()
                .fill(Colors.searchBarBackground)
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 94)
                .overlay (
                    Image(systemName: imageString)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 40)
                        .foregroundColor(.white)
                )
        }
        
        var buttonTitle: some View {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.black)
        }
    }
}

#Preview {
    ProfileView(index: .constant(3))
}
