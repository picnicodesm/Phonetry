//
//  TestView.swift
//  Phonetry
//
//  Created by 김상민 on 2/26/24.
//

import SwiftUI

struct TestView: View {
    
    @Binding var text: String
    @Binding var backgroundColor: Color
    var duration: TimeInterval
    @State private var icons1: [String] = ["🍎", "🥦", "🥕", "🐉", "🍆", "🍇", "🍋", "🍈"]
    @State private var icons2: [String] = ["🍊", "🍍", "🥔", "🍓", "🍠", "🍅", "🍉", "📦"]
    
    @State private var animateIcons1: [Bool] = Array(repeating: false, count: 8)
    @State private var animateIcons2: [Bool] = Array(repeating: false, count: 8)
    
    @State private var drawingHeight = true
    
    var body: some View {
        
        VStack {
            Spacer()
            HStack {
                ForEach(icons1.indices, id: \.self) { index in
                    Text("\(icons1[index])")
                        .offset(y: animateIcons1[index] ? -50 : 0)
                        .animation(
                            Animation.easeOut(duration: duration)
                                .repeatForever(autoreverses: true)
                                .delay(0.2 + Double(index) * 0.1), // 순차적으로 애니메이션 적용
                            value: animateIcons1[index]
                        )
                }
            }
            Spacer().frame(height: 50)
            ProgressView("\(text)")
                .font(.system(size: 20, weight: .bold))
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
                .frame(maxWidth: .infinity)
            Spacer().frame(height: 50)
            HStack {
                ForEach(icons2.indices, id: \.self) { index in
                    Text("\(icons2[index])")
                        .offset(y: animateIcons2[index] ? 50 : 0)
                        .animation(
                            Animation.easeOut(duration: duration)
                                .repeatForever(autoreverses: true)
                                .delay(0.2 + Double(index) * 0.1), // 순차적으로 애니메이션 적용
                            value: animateIcons2[index]
                        )
                }
            }
            Spacer()
        }
        .background(backgroundColor.animation(.easeIn))
        .ignoresSafeArea()
        .onAppear {
            // 애니메이션 트리거
            for index in icons1.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2 + 0.1) {
                    animateIcons1[index] = true
                }
            }
            
            for index in icons2.indices.reversed() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double((index + icons2.count - 1) % icons2.count) * 0.2 + 0.1) {
                    animateIcons2[index] = true
                }
            }
        }
    }
    
    func icon(icon: String, low: CGFloat = 0.0, high: CGFloat = 50) -> some View {
        Text("\(icon)")
        
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView(text: .constant("testView"), backgroundColor: .constant(Color.background), duration: 1)
    }
}
