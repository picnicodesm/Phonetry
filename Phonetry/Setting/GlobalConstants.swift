//
//  GlobalConstants.swift
//  Phonetry
//
//  Created by 김상민 on 2/20/24.
//

import Foundation
import UIKit

struct GlobalConstants {
    static let gridItem: CGFloat = 121
    static let gridSpacing: CGFloat = 10
    static let sectionPadding: CGFloat = 10
    static let storageHeightInMainView: CGFloat = 300
    static let storageHeight: CGFloat = 500
    static let listIconBoxLenght: CGFloat = 42
    static let gridIconBoxLenght: CGFloat = 87
    static let cornerRadius: CGFloat = 10
    static let spacing: CGFloat = 10
    static let detailViewThumbnailLenght: CGFloat = 224
    
    struct FontSize {
        static let sectionHeader: CGFloat = 20
        static let itemTitle: CGFloat = 12
        static let largeItemTitle: CGFloat = 17
        static let dateTitle: CGFloat = 15
        static let listImageIcon: CGFloat = 30
        static let gridImageIcon: CGFloat = 50
        static let detailImageIcon: CGFloat = 100
    }
    
    struct Scanner {
        static let width: CGFloat = 300
        static let height: CGFloat = 300
        static let offsetX: CGFloat = (UIScreen.main.bounds.width - width) / 2
        static let offsetY: CGFloat = (UIScreen.main.bounds.height - height) / 2
    }
}
