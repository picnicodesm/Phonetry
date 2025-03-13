//
//  ProductModel.swift
//  Phonetry
//
//  Created by 김상민 on 5/5/24.
//
// Model for showing ProductInfo

import Foundation

struct ProductModel: Codable,Identifiable {
    var id = UUID()
    var productName: String
    var bestIfUsedByDateStart: String
    var bestIfUsedByDateEnd: String
    var count: Int
    var description: String
    
    init(id: UUID, productName: String, bestIfUsedByDateStart: String, bestIfUsedByDateEnd: String, count: Int, description: String) {
        self.id = id
        self.productName = productName
        self.bestIfUsedByDateStart = bestIfUsedByDateStart
        self.bestIfUsedByDateEnd = bestIfUsedByDateEnd
        self.count = count
        self.description = description
    }
    
    init(productName: String, bestIfUsedByDateStart: String, bestIfUsedByDateEnd: String, count: Int, description: String) {
        self.id = UUID()
        self.productName = productName
        self.bestIfUsedByDateStart = bestIfUsedByDateStart
        self.bestIfUsedByDateEnd = bestIfUsedByDateEnd
        self.count = count
        self.description = description
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "foodId"
        case bestIfUsedByDateStart = "purchaseDate"
        case bestIfUsedByDateEnd = "estimatedExpDate"
        case productName = "foodName"
        case count = "count"
        case description = "description"
    }
    
    mutating func updateProduct(productName: String? = nil, bestIfUsedByDateStart: String? = nil, bestIfUsedByDateEnd: String? = nil, count: Int? = nil, description: String? = nil) {
        if let newProductName = productName {
            self.productName = newProductName
        }
        if let newStart = bestIfUsedByDateStart {
            self.bestIfUsedByDateStart = newStart
        }
        if let newEnd = bestIfUsedByDateEnd {
            self.bestIfUsedByDateEnd = newEnd
        }
        if let newCount = count {
            self.count = newCount
        }
        if let newDescription = description {
            self.description = newDescription
        }
    }
}

extension ProductModel {
    static var products: [ProductModel] = []
    
    static let mock: ProductModel = ProductModel(productName: "apple", bestIfUsedByDateStart: "2024-01-01", bestIfUsedByDateEnd: "2024-02-01", count: 4, description: "사과의 일반적인 소비기한은 3~5일 입니다. 현재 적용된 소비기한은 평균치인 4일 입니다.")
}

extension ProductModel {
    //    func daysUntilExpiration() -> Int {
    //        let dateFormatter = CustomDateFormatter()
    //
    //        let currentDate = Date()
    //        let calendar = Calendar.current
    //        let bestIfUsedByDateEndTemp = dateFormatter.getDateFromString(dateString: bestIfUsedByDateEnd)
    //
    //        guard let daysLeft = calendar.dateComponents([.day], from: currentDate, to: bestIfUsedByDateEndTemp).day else {
    //            print("Error calculating days : return -1")
    //            return -1
    //        }
    //
    //        return daysLeft
    //    }
    
    func daysUntilExpiration() -> Int {
        let dateFormatter = CustomDateFormatter()
        
        let currentDate = Date()
        let calendar = Calendar.current
        let bestIfUsedByDateEndTemp = dateFormatter.getDateFromString(dateString: bestIfUsedByDateEnd)
        
        // 현재 날짜와 bestIfUsedByDateEndTemp의 시작 부분을 가져옵니다.
        let startOfCurrentDate = calendar.startOfDay(for: currentDate)
        let startOfBestIfUsedByDateEndTemp = calendar.startOfDay(for: bestIfUsedByDateEndTemp)
        
        guard let daysLeft = calendar.dateComponents([.day], from: startOfCurrentDate, to: startOfBestIfUsedByDateEndTemp).day else {
            print("Error calculating days : return -1")
            return -1
        }
        
        return daysLeft
    }
    
}
