//
//  ResultView.swift
//  Phonetry
//
//  Created by 김상민 on 5/5/24.
//
// 스캔 또는 딥러닝 결과를 보여주는 뷰. 이 떄의 사진은 그냥 이미지로 해야 함.

import SwiftUI

/*
 페이지 초기화할 때 해야할 것
 - 이미지 가져오기
 - 음식 이름, 저장일자, 소비기한(계산해서 초기화), 수량
 
 1. Scan 결과를 받아올 때 -> 제품 이름, 소비기한: "제조일로부터 18개월" 또는 "제조일로부터 18개월까지" 를 받음
 2. Database에서 읽어올 때 -> 제품 id를 입력받아서 거기서 정보들을 가져옴
 */

struct ResultView: View {
    @Environment(\.presentationMode) var presentation
    
    @State private var bestIfUsedByDateStart = Date()
    @State private var bestIfUsedByDateEnd = Date()
    @State private var count: Int = 1
    
    @Binding var isPresent: Bool
    var switchTabDelegate: SwitchTabDelegate?
    
    private var product: ProductModel
    private let dateFormatter = CustomDateFormatter()
    
    @EnvironmentObject var productManager: ProductManager
    
    
    init(product: ProductModel, isPresent: Binding<Bool>, switchTabDelegate: SwitchTabDelegate?) {
        self.product = product
        self._isPresent = isPresent
        self.switchTabDelegate = switchTabDelegate
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {
                Spacer()
                
                thumbnail
                
                contents
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Colors.systemGroupedBackgroundLight)
        .navigationTitle(product.productName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            self.bestIfUsedByDateStart = Date()
            self.bestIfUsedByDateEnd = dateFormatter.getDateFromString(dateString: product.bestIfUsedByDateEnd)
            self.isPresent = false
            self.count = count
        }
        .overlay(alignment: .bottom) {
            buttonSection
        }
    }
    
    private var thumbnail: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(Colors.background)
            .aspectRatio(1, contentMode: .fill)
            .frame(width: GlobalConstants.detailViewThumbnailLenght, height: GlobalConstants.detailViewThumbnailLenght)
            .overlay {
                Text("\(RepresentImage.getEmoji(for: product.productName))")
                    .font(Font.system(size: GlobalConstants.FontSize.detailImageIcon))
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
        } label: {
            Image(systemName: "plus.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
        }
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
//            switchTabDelegate?.switchTab()
            switchTabDelegate?.testSwitchTab()
        } label: {
            Text("Back")
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
            var productTemp = product
            let bestIfUsedByDateStartString = dateFormatter.getStringFromDate(date: bestIfUsedByDateStart)
            let bestIfUsedByDateEndString = dateFormatter.getStringFromDate(date: bestIfUsedByDateEnd)
            productTemp.updateProduct(bestIfUsedByDateStart: bestIfUsedByDateStartString, bestIfUsedByDateEnd: bestIfUsedByDateEndString, count: count)
            
            productManager.addNewProduct(product: productTemp)
            presentation.wrappedValue.dismiss()
//            switchTabDelegate?.switchTab()
            switchTabDelegate?.testSwitchTab()
        } label: {
            Text("Save")
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
    private struct Constants {
        static let verticalPadding: CGFloat = 10

        struct FontSize {
            static let ButtonTitle: CGFloat = 20
        }
    }
}

#Preview {
    ResultView(product: ProductModel.mock, isPresent: .constant(false), switchTabDelegate: .none)
}
