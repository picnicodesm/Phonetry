//
//  RepresentImage.swift
//  Phonetry
//
//  Created by 김상민 on 5/17/24.
//

import Foundation

enum RepresentImage: String {
    case 🍎 = "apple"
    case 🥦 = "broccoli"
    case 🥕 = "carrot"
    case 🐉 = "dragonfruit"
    case 🍆 = "eggplant"
    case 🍇 = "grape"
    case 🍋 = "lemon"
    case 🍈 = "melon"
    case 🍊 = "orange"
    case 🍍 = "pineapple"
    case 🥔 = "potato"
    case 🍓 = "strawberry"
    case 🍠 = "sweetpotato"
    case 🍅 = "tomato"
    case 🍉 = "watermelon"
    case 📦 = "others"

    static func getEmoji(for name: String) -> RepresentImage {
        guard let emoji = RepresentImage(rawValue: name) else {
            return .📦
        }
        return emoji
    }
}
