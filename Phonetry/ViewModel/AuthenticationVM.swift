//
//  AuthenticationVM.swift
//  Phonetry
//
//  Created by 김상민 on 3/31/24.
//

import Foundation
import Firebase

class AuthenticationVM: ObservableObject {
    @Published private var email: String?
    @Published private var password: String?
    @Published private var currentUser: Firebase.User?
    
    init() {
        currentUser = Auth.auth().currentUser
    }
    
    func checkLoginAlready() -> Bool {
        guard currentUser != nil else { return false }
        return true
    }
    
    func registerUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let user = result?.user else {
                print("AuthenticationVM: 유저를 찾을 수 없습니다.")
                return
            }
            
            let userId = user.uid
            
            let ref = Database.database().reference()
            
            // 데이터베이스에 등록
            ref.child("users").child("\(userId)").setValue([
                "notificationEnabled": false,
                "userId": userId,
                "themeColor": "base"
                ])
            
            completion(true)
        }
    }
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("Error : \(error.localizedDescription)")
                return
            }
            
            self?.currentUser = result?.user
            
            if let user = self?.currentUser {
                print(user.uid)
            }
        }
    }
    
    func logout() {
        currentUser = nil
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
