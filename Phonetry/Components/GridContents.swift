//
//  GridContents.swift
//  Phonetry
//
//  Created by 김상민 on 2/20/24.
//

import SwiftUI

struct GridContents: View {
//    var items: [String] // TODO: - change to items
    var items: [ProductModel]
    var gridItem: [GridItem]
    var geo: GeometryProxy
    
    var body: some View {
//        VStack(alignment: .leading) {
            GridCard(items: items, gridItem: gridItem, geo: geo, isMainView: false)
//        }
    }
}

// MARK: - GRID CARD
struct GridCard: View {
    @EnvironmentObject var productManager: ProductManager
    
    var items: [ProductModel]
    var gridItem: [GridItem]
    var geo: GeometryProxy
    var isMainView: Bool
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: gridItem, spacing: 0) {
                ForEach(items, id: \.id) { item in
                    GridFoodItem(item: item, geo: geo).environmentObject(productManager)
                }
            }
        }
        .frame(height: isMainView ? GlobalConstants.storageHeightInMainView : GlobalConstants.storageHeight)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: GlobalConstants.cornerRadius))
    }
    
    // MARK: - GRID FOOD ITEM
    private struct GridFoodItem: View {
        @EnvironmentObject var productManager: ProductManager
        @EnvironmentObject var tabBarThemeColorVM: TabBarThemeColorVM
        
        let item: ProductModel
        let geo: GeometryProxy
        @State private var remainDate: Int = 0
        
        var body: some View {
            NavigationLink(destination: DetailView(product: item).environmentObject(productManager)) {
                    VStack {
                        foodImage
                        foodName
                        remainingDate
                    }
                    .frame(width: geo.size.width / 3 - GlobalConstants.gridSpacing, height: GlobalConstants.gridItem)
                    .tint(.black)
                    .buttonStyle(PlainButtonStyle())
                    .onAppear {
                        self.remainDate = item.daysUntilExpiration()
                    }
            }
        }
        
        var foodImage: some View {
            RoundedRectangle(cornerRadius: GlobalConstants.cornerRadius)
                .fill(Colors.background)
                .aspectRatio(1, contentMode: .fill)
                .frame(width: GlobalConstants.gridIconBoxLenght, height: GlobalConstants.gridIconBoxLenght)
                .overlay {
                    Text("\(RepresentImage.getEmoji(for: item.productName))")
                        .font(Font.system(size: GlobalConstants.FontSize.gridImageIcon))
                }
        }
        
        var foodName: some View {
            Text("\(item.productName)")
                .font(.system(size: GlobalConstants.FontSize.itemTitle))
                .fontWeight(.semibold)
        }
        
        var remainingDate: some View {
            Text("D-\(remainDate)")
                .font(.system(size: GlobalConstants.FontSize.dateTitle))
                .fontWeight(.bold)
                .remainedDateColor(remain: remainDate)
        }
    }
}


