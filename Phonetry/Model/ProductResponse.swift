//
//  FoodData.swift
//  Phonetry
//
//  Created by 김상민 on 3/30/24.
//

import Foundation

// MARK: - Empty
struct ProductResponse: Codable {
    let service: Service

    enum CodingKeys: String, CodingKey {
        case service = "C005"
    }
}

// MARK: - ServiceID
struct Service: Codable {
    let totalCount: String
    let productInfoRow: [ProductInfo]
    let result: Result

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case productInfoRow = "row"
        case result = "RESULT"
    }
}

// MARK: - Result
struct Result: Codable {
    let msg, code: String

    enum CodingKeys: String, CodingKey {
        case msg = "MSG"
        case code = "CODE"
    }
}

// MARK: - ProductInfo
struct ProductInfo: Codable {
//    let clsbizDt, siteAddr, prdlstReportNo, prmsDt: String
//    let prdlstNm, barCD, pogDaycnt, prdlstDcnm: String
//    let bsshNm, endDt, indutyNm: String
//    let id = UUID()
    let productName: String
    let bestIfUsedByDate: String

    enum CodingKeys: String, CodingKey {
        case productName = "PRDLST_NM"
        case bestIfUsedByDate = "POG_DAYCNT"
//        case clsbizDt = "CLSBIZ_DT"
//        case siteAddr = "SITE_ADDR"
//        case prdlstReportNo = "PRDLST_REPORT_NO"
//        case prmsDt = "PRMS_DT"
//        case barCD = "BAR_CD"
//        case prdlstDcnm = "PRDLST_DCNM"
//        case bsshNm = "BSSH_NM"
//        case endDt = "END_DT"
//        case indutyNm = "INDUTY_NM"
    }
}
/*
 
 {
     "C005": {
         "total_count": "1",
         "row": [
             {
                 "CLSBIZ_DT": "",
                 "SITE_ADDR": "전라남도 순천시 서면 산단1길 16",
                 "PRDLST_REPORT_NO": "195505090011",
                 "PRMS_DT": "19950728",
                 "PRDLST_NM": "매일맛있는진간장골드",
                 "BAR_CD": "8801791000055",
                 "POG_DAYCNT": "실온보관 2년",
                 "PRDLST_DCNM": "혼합간장",
                 "BSSH_NM": "매일식품주식회사",
                 "END_DT": "",
                 "INDUTY_NM": "식품제조가공업"
             }
         ],
         "RESULT": {
             "MSG": "정상처리되었습니다.",
             "CODE": "INFO-000"
         }
     }
 }
 
 */
