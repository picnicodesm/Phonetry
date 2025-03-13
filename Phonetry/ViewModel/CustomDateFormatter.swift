//
//  CustomDateFormatter.swift
//  Phonetry
//
//  Created by 김상민 on 5/15/24.
//

import Foundation

class CustomDateFormatter {
    
    private let dateFormatter: DateFormatter
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 모든 환경에서 일관된 날짜 파싱을 보장합니다.
    }
    
    func getStringFromDate(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func getDateFromString(dateString: String) -> Date {
        guard let date = dateFormatter.date(from: dateString) else {
            fatalError("Invalid date string: \(dateString)")
        }
        return date
    }
    
    func getFormattedDate(from date: Date) -> Date {
        let dateString = getStringFromDate(date: date)
        return getDateFromString(dateString: dateString)
    }

}
