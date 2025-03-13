//
//  ThemeColorManager.swift
//  Phonetry
//
//  Created by 김상민 on 5/16/24.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class ThemeColorManager {
    
    private let databaseRef = Database.database().reference()
    
    func saveThemeColor(_ themeColor: ThemeColor) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user")
            return
        }
        
        let themeColorDict: [String: Any] = [
            "red": themeColor.red,
            "green": themeColor.green,
            "blue": themeColor.blue
        ]
        
        let childUpdates = ["users/\(userId)/themeColor": themeColorDict]
        self.databaseRef.updateChildValues(childUpdates)
    }
    
    func loadThemeColor(completion: @escaping (ThemeColor?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user")
            completion(nil)
            return
        }
        
        databaseRef.child("users/\(userId)/themeColor")
            .observeSingleEvent(of: .value, with: { snapshot in
                if let value = snapshot.value as? [String: Any],
                   let red = value["red"] as? CGFloat,
                   let green = value["green"] as? CGFloat,
                   let blue = value["blue"] as? CGFloat {
                    let themeColor = ThemeColor(red: red, green: green, blue: blue)
                    completion(themeColor)
                } else {
                    print("경로 에러인가?")
                    completion(nil)
                    return
                }
            }
            )
        
    }
}
