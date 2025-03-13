//
//  StorageView.swift
//  Phonetry
//
//  Created by 김상민 on 2/20/24.
//

import SwiftUI
import UIKit

struct StorageView: View {
    @State var searchText: String = ""
    @State var isList: Bool = true
    
    @EnvironmentObject var productManager: ProductManager
    @State var showingProducts: [ProductModel] = []
    
    let rows = [GridItem(.fixed(GlobalConstants.gridItem), spacing: GlobalConstants.gridSpacing), GridItem(.fixed(GlobalConstants.gridItem))]
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                VStack {
                    searchSection
                        .padding(.top, 10)
                    if isList {
                        ListContents(items: searchText == "" ? productManager.products : showingProducts)
                            .environmentObject(productManager)
                    } else {
                        GridCard(items: searchText == "" ? productManager.products : showingProducts, gridItem: rows, geo: geo, isMainView: false)
                            .environmentObject(productManager)
                    }
                }
            }
            .toolbar(.visible, for: .tabBar)
            .padding(.horizontal)
            .navigationTitle("Storage")
            .background(Colors.systemGroupedBackgroundLight)
        }
        .foregroundColor(.black)
//        .toolbar(.visible, for: .tabBar)
    }
    
    private var largeTitleIcon: some View {
        Button {
            isList.toggle()
        } label: {
            Image(systemName: "list.bullet")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
                .scaleEffect(0.6)
                .foregroundColor(.white)
                .background(Colors.background)
        }
    }
    
    private var searchSection: some View {
        HStack {
            searchBar
            Menu {
                Button("List") {
                    isList = true
                }
                Button("Grid") {
                    isList = false
                }
            } label: {
                Image(systemName: "flag.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 36)
                    .tint(Color(UIColor.systemGray3))
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("", text: $searchText)
                .placeholder("Search", when: searchText.isEmpty)
                .font(Font.system(size: 21))
                .onChange(of: searchText) { newValue in
                    filterProducts()
                }
        }
        .padding(7)
        .background(Colors.searchBarBackground)
        .cornerRadius(10)
    }
    
    private func filterProducts() {
        if searchText.isEmpty {
            showingProducts = productManager.products
        } else {
            showingProducts = productManager.products.filter { $0.productName.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

#Preview {
    StorageView(showingProducts: ProductModel.products)
}
