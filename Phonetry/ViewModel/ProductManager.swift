//
//  ProductManager.swift
//  Phonetry
//
//  Created by 김상민 on 12/5/24.
//
// Food 정보를 저장하거나 가져올 수 있는 VM

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseDatabaseSwift

class ProductManager: ObservableObject {
    @Published var products: [ProductModel] = ProductModel.products
    private let dateFormatter = CustomDateFormatter()
    private var isListening: Bool = false
    private var productIDs: Set<UUID> = []
    
    init(text: String) {
        print("ProductManager is setted in \(text)")
    }
    
    var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    // (1): Realtime Database의 기본 경로를 저장하는 변수
    let ref: DatabaseReference? = Database.database().reference() // (1)
    
    // (2): Realtime Database의 데이터 구조는 기본적으로 JSON 형태이다.
    // 저장소와 데이터를 주고받을 때 JSON 형식의 데이터로 주고받기 때문에 Encoder, Decoder의 인스턴스가 필요하다.
    private let encoder = JSONEncoder() // (2)
    private let decoder = JSONDecoder() // (2)
    
    func listenToRealtimeDatabase(completion: @escaping (Bool) -> Void) {
        print("듣기 시작")
        if (!isListening) {
            print("최초실행 -> isListening = true로 설정")
            isListening = true
        } else {
            print("듣는 중이라 반환")
            completion(false)
            return
        }
        
        guard let currentUserID = currentUserID else {
            print("ProductManager: User ID not found")
            completion(false)
            return
        }
        
        guard let databasePath = ref?.child("storages").child("\(currentUserID)") else {
            completion(false)
            return
        }
        
        
        
        // Fetch initial data
        databasePath.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else {
                completion(false)
                return
            }
            
            self.products.removeAll()
            var newItems: [ProductModel] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let name = dict["foodName"] as? String,
                   let purchaseDate = dict["purchaseDate"] as? String,
                   let estimatedExpDate = dict["estimatedExpDate"] as? String,
                   let count = dict["count"] as? Int,
                   let description = dict["description"] as? String,
                   let id = UUID(uuidString: childSnapshot.key) {
                    
                    let item = ProductModel(id: UUID(uuidString: childSnapshot.key)!, productName: name, bestIfUsedByDateStart: purchaseDate, bestIfUsedByDateEnd: estimatedExpDate, count: count, description: description)
                    newItems.append(item)
                    self.productIDs.insert(id)
                }
            }
            
            self.products = newItems
            completion(true)
            
            // Start listening to real-time updates
            self.startListeningToUpdates(databasePath: databasePath)
        }
    }
    
    
    private func startListeningToUpdates(databasePath: DatabaseReference) {
        // (3): 데이터베이스를 실시간으로 '관찰'하여 데이터 변경 여부를 확인하여 실시간 데이터 읽기 쓰기를 할 수 있게된다.
        
        
        guard let currentUserID = currentUserID else {
            print("ProductManager: 유저 아이디 획득 실패")
            return
        }
        
        guard let databasePath = ref?.child("storages").child("\(currentUserID)") else {
            return
        }
        
        // 데이터베이스를 '관찰'하여 경로내 파일중 CUD(생성, 수정, 삭제)가 감지될 때 후행 클로저 내 코드들이 실행된다.
        
        // .childAdded: 경로에 있는 컨텐츠 중 추가된 아이템이 있는 경우 아이템을 읽어온다.
        databasePath
            .observe(.childAdded) { [weak self] snapshot, _ in
                print(".childAdded occured!")
                guard
                    let self = self,
                    let json = snapshot.value as? [String: Any]
                else {
                    return
                }
                do {
                    let productData = try JSONSerialization.data(withJSONObject: json)
                    let product = try self.decoder.decode(ProductModel.self, from: productData)
                    if !self.productIDs.contains(product.id) {
                        self.products.append(product)
                        self.productIDs.insert(product.id)
                        LocalNotificationHelper.shared.setAuthorization(productManager: self)
                    }
                    //                    self.removeDuplicates()
                } catch {
                    print("an error occurred in .childAdded", error)
                }
            }
        
        // .childChanged: 경로에 있는 컨텐츠 중 수정된 아이템이 있는경우 아이템을 읽어온다.
        databasePath
            .observe(.childChanged, with: { [weak self] snapshot in
                print(".childChanged occured!")
                guard
                    let self = self,
                    let json = snapshot.value as? [String: Any]
                else{
                    return
                }
                do{
                    let productData = try JSONSerialization.data(withJSONObject: json)
                    let product = try self.decoder.decode(ProductModel.self, from: productData)
                    
                    if let index = self.products.firstIndex(where: { $0.id == product.id }) {
                        self.products[index] = product
                        LocalNotificationHelper.shared.setAuthorization(productManager: self)
                    }
                    //                    self.removeDuplicates()
                } catch{
                    print("an error occurred in .childChanged", error)
                }
            })
        
        
        
        // .childRemoved: 경로에 있는 컨텐츠 중 삭제된 아이템이 있는 경우 아이템을 읽어온다.
        databasePath
            .observe(.childRemoved, with: { [weak self] snapshot in
                print(".childRemoved occured!")
                guard
                    let self = self,
                    let json = snapshot.value as? [String: Any]
                else{
                    return
                }
                do{
                    let productData = try JSONSerialization.data(withJSONObject: json)
                    let product = try self.decoder.decode(ProductModel.self, from: productData)
                    
                    self.products.removeAll { $0.id == product.id }
                    self.productIDs.remove(product.id)
                    LocalNotificationHelper.shared.setAuthorization(productManager: self)
                    //                    self.removeDuplicates()
                } catch{
                    print("an error occurred in .childRemoved", error)
                }
            })
    }
    
    func stopListening() {
        // (4): 데이터베이스를 실시간으로 '관찰'하는 것을 중지한다.
        guard let currentUserID = currentUserID else {
            print("ProductManager: 유저 아이디 획득 실패")
            return
        }
        
        guard let databasePath = ref?.child("storages").child("\(currentUserID)") else {
            return
        }
        
        databasePath.removeAllObservers()
    }
    
    func addNewProduct(product: ProductModel) {
        // (5): 데이터베이스에 Product 인스턴스를 추가하는 함수
        print("add 레츠고")
        
        guard let currentUserID = currentUserID else {
            print("ProductManager - add: 유저 아이디 획득 실패")
            return
        }
        
        self.ref?.child("storages").child("\(currentUserID)").child("\(product.id)").setValue([
            "foodId": product.id.uuidString,
            "foodName": product.productName,
            "purchaseDate": product.bestIfUsedByDateStart,
            "estimatedExpDate": product.bestIfUsedByDateEnd,
            "count": product.count,
            "description": product.description
        ])
    }
    
    
    func deleteProduct(id: String) {
        // (6): 데이터베이스에서 특정 경로의 데이터를 삭제하는 함수
        guard let currentUserID = currentUserID else {
            print("ProductManager - delete: 유저 아이디 획득 실패")
            return
        }
        
        ref?.child("storages/\(currentUserID)/\(id)").removeValue()
    }
    
    func editProduct(product: ProductModel) {
        // (7) 데이터베이스에서 특정 경로의 데이터를 수정하는 함수
        guard let currentUserID = currentUserID else {
            print("ProductManager - edit: 유저 아이디 획득 실패")
            return
        }
        
        let updates: [String : Any] = [
            "foodId": product.id.uuidString,
            "foodName": product.productName,
            "purchaseDate": product.bestIfUsedByDateStart,
            "estimatedExpDate": product.bestIfUsedByDateEnd,
            "count": product.count,
            "description": product.description
        ]
        
        let childUpdates = ["storages/\(currentUserID)/\(product.id)": updates]
        for (index, productItem) in products.enumerated() where productItem.id == product.id {
            products[index] = product
        }
        self.ref?.updateChildValues(childUpdates)
    }
    
    func fetchItems(completion: @escaping (Bool) -> Void) {
        print("fetch 레츠고")
        guard let ref = self.ref else {
            print("Reference ERROR - fetch: 경로 획득 실패")
            completion(false)
            return
        }
        
        guard let currentUserID = currentUserID else {
            print("ProductManager - fetch: 유저 아이디 획득 실패")
            completion(false)
            return
        }
        
        ref.child("storages/\(currentUserID)/").observeSingleEvent(of: .value) { snapshot in
            var newItems: [ProductModel] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let name = dict["foodName"] as? String,
                   let purchaseDate = dict["purchaseDate"] as? String,
                   let estimatedExpDate = dict["estimatedExpDate"] as? String,
                   let count = dict["count"] as? Int,
                   let description = dict["description"] as? String {
                    
                    let item = ProductModel(id: UUID(uuidString: childSnapshot.key)!, productName: name, bestIfUsedByDateStart: purchaseDate, bestIfUsedByDateEnd: estimatedExpDate, count: count, description: description)
                    newItems.append(item)
                }
                
                self.products = newItems
                self.removeDuplicates()
                completion(true)
                print("\(newItems.count) Items fetched!" )
            }
        }
    }
    
    func sortItemsByExpiration(items: [ProductModel]) -> [ProductModel] {
        return items.sorted { $0.daysUntilExpiration() < $1.daysUntilExpiration() }
    }
    
    func calculateExpiringItemsCount(items: [ProductModel]) -> Int {
        return items.filter { $0.daysUntilExpiration() <= 3 }.count
    }
    
    
    // DEPRECATED
    func removeDuplicates() {
        var uniqueProducts: [ProductModel] = []
        var seenIDs: Set<UUID> = []
        
        for product in products {
            if !seenIDs.contains(product.id) {
                uniqueProducts.append(product)
                seenIDs.insert(product.id)
            }
        }
        
        products = uniqueProducts
    }
    
}
