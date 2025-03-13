//
//  ListCard.swift
//  Phonetry
//
//  Created by 김상민 on 2/20/24.
//

import SwiftUI

struct ListContents: View {
    var items: [ProductModel]
    @EnvironmentObject var productManager: ProductManager
    
    var body: some View {
//        VStack(alignment: .leading) { // 타입별로 있었는데 없어져서 필요 없어짐
            listCard
//        }
    }
    
    // MARK: - LIST CARD
    private var listCard: some View {
        ScrollView(showsIndicators: false) {
           LazyVStack(spacing: 0) {
                ForEach(items, id: \.id) { item in
                    ListItem(item: item)
                        .environmentObject(productManager)
                }
            }
        }
        .frame(height: GlobalConstants.storageHeight)
        .padding(.horizontal)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: GlobalConstants.cornerRadius))
        
    }
    // MARK: - LIST ITEM
    private struct ListItem: View {
        @EnvironmentObject var productManager: ProductManager
        @EnvironmentObject var tabBarThemeColorVM: TabBarThemeColorVM
//        @State private var alarmPresented: Bool = false
        @StateObject private var alarmVM: ListItemAlarmVM = ListItemAlarmVM()
        
        var item: ProductModel
        
        var body:some View {
            NavigationLink(destination: DetailView(product: item).environmentObject(productManager)) {
                HStack {
                    foodImage
                    foodInfo
                    Spacer()
                    deleteButton
                        .alert(Text("삭제"), isPresented: $alarmVM.alarmPresented) {
                            Button("네") {
                                productManager.deleteProduct(id: item.id.uuidString)
                                alarmVM.alarmPresented = false
                            }
                            Button("아니요", role: .cancel) {
                                alarmVM.alarmPresented = false
                            }
                        } message: {
                            Text("정말 지우시겠습니까?")
                        }
                }
                .frame(height: 62)
            }
        }
        
        private var foodImage: some View {
            RoundedRectangle(cornerRadius: GlobalConstants.cornerRadius)
                .fill(tabBarThemeColorVM.themeColor)
                .aspectRatio(1, contentMode: .fill)
                .frame(width: GlobalConstants.listIconBoxLenght, height: GlobalConstants.listIconBoxLenght)
                .overlay {
                    Text("\(RepresentImage.getEmoji(for: item.productName))")
                        .font(Font.system(size: GlobalConstants.FontSize.listImageIcon))
                }
        }
        
        private var foodInfo: some View {
            VStack(alignment: .leading) {
                Text(item.productName) // -> item.name
                    .font(.system(size:GlobalConstants.FontSize.largeItemTitle))
                    .fontWeight(.bold)
                Text("\(item.daysUntilExpiration())일 남았어요!") // -> 남은 일자
                    .font(.system(size: GlobalConstants.FontSize.dateTitle))
                    .fontWeight(.medium)
                    .remainedDateColor(remain: item.daysUntilExpiration())
            }
            .foregroundColor(.black)
        }
        
        private var deleteButton: some View {
            Button(action: {
                alarmVM.alarmPresented = true
            }, label: {
                Image(systemName: "trash.fill")
                    .resizable()
                    .frame(width: 25, height: 22)
            })
            .buttonStyle(PlainButtonStyle())
        }
    }
}


