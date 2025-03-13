//
//  DetailView.swift
//  Phonetry
//
//  Created by 김상민 on 2/21/24.
//

import SwiftUI

/*
 페이지 초기화할 때 해야할 것
 - 이미지 가져오기
 - 음식 이름, 저장일자, 소비기한(계산해서 초기화), 카테고리
 
1. Scan 결과를 받아올 때 -> 제품 이름, 소비기한: "제조일로부터 18개월" 또는 "제조일로부터 18개월까지" 를 받음
2. Database에서 읽어올 때 -> 제품 id를 입력받아서 거기서 정보들을 가져옴
 */

struct DetailView: View {
    @Environment(\.presentationMode) var presentation
    
    @State private var bestIfUsedByDateStart = Date()
    @State private var bestIfUsedByDateEnd = Date()
    @State private var count: Int = 1
    @State private var tabbarHidden: Bool = true
    private var isEnabled: Bool {
        if (self.bestIfUsedByDateStart != dateFormatter.getDateFromString(dateString: product.bestIfUsedByDateStart)) ||
            (self.bestIfUsedByDateEnd != dateFormatter.getDateFromString(dateString: product.bestIfUsedByDateEnd)) ||
            (self.count != product.count) {
            return true
        } else {
            return false
        }
    }
    
    private var product: ProductModel
    
    @EnvironmentObject var productManager: ProductManager
    let dateFormatter = CustomDateFormatter()
    
    init(product: ProductModel) {
        self.product = product
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    Spacer()
                    
                    thumbnail
                    
                    contents
                }
                
            }
            
            buttonSection
        }

        .padding()
        .frame(maxWidth: .infinity)
        .background(Colors.systemGroupedBackgroundLight)
        .navigationTitle(product.productName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // 데이터 읽어온 값 저장
//            TabBarModifier.hideTabBar()
            self.bestIfUsedByDateStart = dateFormatter.getDateFromString(dateString: product.bestIfUsedByDateStart)
            self.bestIfUsedByDateEnd = dateFormatter.getDateFromString(dateString: product.bestIfUsedByDateEnd)
            self.count = product.count
            tabbarHidden = true
        }
        .onDisappear {
//            TabBarModifier.showTabBar()
            tabbarHidden = false
        }
//        .hiddenTabBar()
        .toolbar(tabbarHidden ? .hidden : .visible, for: .tabBar)
    }
    
    // MARK: - Components
    
    private var thumbnail: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(Colors.background)
            .aspectRatio(1, contentMode: .fill)
            .frame(width: GlobalConstants.detailViewThumbnailLenght, height: GlobalConstants.detailViewThumbnailLenght)
            .overlay {
                Text("\(RepresentImage.getEmoji(for: product.productName))")
                    .font(Font.system(size: 100))
            }
    }
    
    private var contents: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(product.productName)")
                .font(.system(size: 24))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("저장일자")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                    DatePicker("", selection: $bestIfUsedByDateStart, displayedComponents: .date)
                        .labelsHidden()
                        .colorScheme(.light)
                }
                
                VStack(alignment: .leading) {
                    Text("소비기한")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                    DatePicker("", selection: $bestIfUsedByDateEnd, displayedComponents: .date)
                        .labelsHidden()
                        .colorScheme(.light)
                }
            }
            
            VStack(alignment: .leading) {
                Text("수량")
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                counter
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("설명")
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                Text("\(product.description)")
                    .font(.system(size: 12))
            }
        }
        .foregroundColor(.black)
    }
    
    private var counter: some View {
        HStack {
            minusButton
            
            Text("\(self.count)")
                .frame(width: 30, height: 30)
            
            plusButton
        }
    }
    
    private var minusButton: some View {
        Button {
            if self.count > 1 {
                self.count -= 1
            }
            print("minus touched!")
        } label: {
            Image(systemName: "minus.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
        }
    }
    
    private var plusButton: some View {
        Button {
            self.count += 1
            print("plus touched!")
        } label: {
            Image(systemName: "plus.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
        }
    }
    
    private var buttonSection: some View {
        HStack(spacing: 0) {
            editButton
        }
    }
    
    private var editButton: some View {
        Button{
            let purchaseDateString = dateFormatter.getStringFromDate(date: bestIfUsedByDateStart)
            let estimatedDateString = dateFormatter.getStringFromDate(date: bestIfUsedByDateEnd)
            let productTemp = ProductModel(id: product.id, productName: product.productName, bestIfUsedByDateStart: purchaseDateString, bestIfUsedByDateEnd: estimatedDateString, count: count, description: product.description)
            
            productManager.editProduct(product: productTemp)
            presentation.wrappedValue.dismiss()
        } label: {
            Text("Edit")
                .font(.system(size: Constants.FontSize.ButtonTitle, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.verticalPadding)
        }
        .padding(.horizontal)
        .buttonStyle(.borderedProminent)
        .tint(Colors.background)
        .disabled(!isEnabled)
    }
    
    // MARK: - Constants
    private struct Constants {
        static let verticalPadding: CGFloat = 10

        struct FontSize {
            static let ButtonTitle: CGFloat = 20
        }
    }
}

#Preview {
    DetailView(product: ProductModel.mock)
}

