//
//  MainView.swift
//  Phonetry
//
//  Created by 김상민 on 2/19/24.
//

import SwiftUI

// make full screen and adding padding

struct MainView: View {
    let rows = [
        GridItem(.fixed(GlobalConstants.gridItem), spacing: GlobalConstants.gridSpacing),
        GridItem(.fixed(GlobalConstants.gridItem))
    ]
    let spacer: some View = Rectangle().fill(.clear).frame(height: 30)

    @EnvironmentObject var productManger: ProductManager
    @State private var tabbarHidden: Bool = false
    
    var body: some View {
        NavigationView {
            contents
                .foregroundColor(.black)
                .background(Colors.systemGroupedBackgroundLight)
                .navigationTitle("Home")
//                .toolbar(tabbarHidden ? .hidden : .visible, for: .tabBar)
                .onAppear {
                    print("main appear")
                    tabbarHidden = false
                }
                .onDisappear {
                    print("main disappaer")
                    tabbarHidden = true
                }
        }
        
    }
    
    private var largeTitleIcon: some View {
        Image(systemName: "person.crop.circle")
            .font(.largeTitle)
            .foregroundColor(.black)
            .aspectRatio(contentMode: .fit)
            .frame(height: 40)
            .background(Color("background"))
    }
    
    
    private var contents: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    storageSectionHeader
                        .foregroundColor(.black)
//                    Button {
//                        print("\n\n현재 products: \(productManger.products.count), id들:")
//                        for item in productManger.products {
//                            print("id: \(item.id)")
//                        }
//                    } label: {
//                        Text("현재 제품 확인")
//                    }

                    GridCard(items: productManger.sortItemsByExpiration(items: productManger.products), gridItem: rows, geo: geo, isMainView: true)
                        .environmentObject(productManger)
                    spacer
                    MockImage(geo: geo)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var storageSectionHeader: some View {
        Text("My Storage")
            .font(.system(size: GlobalConstants.FontSize.sectionHeader))
            .fontWeight(.semibold)
            .padding(.top, GlobalConstants.sectionPadding)
    }
    
    private struct MockImage:  View {
        var geo: GeometryProxy
        
        var body: some View {
            Rectangle()
                .fill(.green)
                .frame(width: geo.size.width, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: GlobalConstants.cornerRadius))
                .overlay {
                    VStack(spacing: 10) {
                        Text("소비기한 표시제가\n 시행됩니다.")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Image(systemName: "apple.logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geo.size.width / 2, height: geo.size.width / 2)
                    }
                }
        }
    }
}

#Preview {
    MainView().environmentObject(ProductManager(text: "preview"))
}
