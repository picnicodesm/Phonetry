//
//  ImageClassificaionVM.swift
//  Phonetry
//
//  Created by 김상민 on 5/12/24.
//

import Foundation
import UIKit
import SwiftUI

class ImageClassificaionVM: ObservableObject {
    @Published var capturedImage: UIImage? = nil
    @Published var classificationresponse: ClassificaionResponse? = nil
    @Published var isGetResult: Bool = false
 
    func sendImage(errorAlarmPresented: Binding<Bool>){
        
        guard let image = capturedImage else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.9) else { return }
        
        let url = URL(string: "http://192.168.0.1:8000/api/v1/deeplearning/classify/")!

       
        // ----------------------------------------------------------------------------
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // 멀티파트 폼 데이터의 boundary 생성
        let boundary = "Boundary-\(UUID().uuidString)"

        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // 멀티파트 바디 구성
        var body = Data()

        // 이미지 부분
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        // 바디 종료 부분
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body
        
        let session = URLSession(configuration: .default)
        session.configuration.timeoutIntervalForRequest = TimeInterval(20)
        session.configuration.timeoutIntervalForResource = TimeInterval(20)
        let task = session.uploadTask(with: request, from: body) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "No error description")")
                errorAlarmPresented.wrappedValue = true
                return
            }
                        
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                print("HTTP ERROR!")
                errorAlarmPresented.wrappedValue = true
                return
            }

            if let mimeType = httpResponse.mimeType, mimeType == "application/json",
               let decodedResponse = try? JSONDecoder().decode(ClassificaionResponse.self, from: data) {
                DispatchQueue.main.async { // 메인 스레드에서 UI 업데이트
                    self.classificationresponse = decodedResponse
                    print(self.classificationresponse?.prediction ?? "optional nil")
                    self.isGetResult = true
                }
            }

        }

        task.resume()
    }
}
