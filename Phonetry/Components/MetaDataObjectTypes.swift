//
//  MetaDataObjectTypes.swift
//  Phonetry
//
//  Created by 김상민 on 3/4/24.
//

import Foundation
import AVFoundation


// 바코드 관련된 것만 넣기
struct MetaDataObjectTypes {
    static let usingTpyes: [AVMetadataObject.ObjectType] = [
        .upce,
        .code39,
        .code39Mod43,
        .code93,
        .code128,
        .ean8,
        .ean13,
        .aztec,
        .pdf417,
        .itf14,
        .dataMatrix,
        .interleaved2of5,
       // .qr // 제외하기
    ]
}
