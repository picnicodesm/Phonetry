//
//  LoadingView.swift
//  Phonetry
//
//  Created by 김상민 on 5/18/24.
//

import SwiftUI

struct LoadingView: View {
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
                icon(icon: "🍎").animation(animation.speed(1.5).delay(1), value: drawingHeight)
                icon(icon: "🥦").animation(animation.speed(1.5).delay(1.1), value: drawingHeight)
                icon(icon: "🥕").animation(animation.speed(1.5).delay(1.2), value: drawingHeight)
                icon(icon: "🐉").animation(animation.speed(1.5).delay(1.3), value: drawingHeight)
                icon(icon: "🍆").animation(animation.speed(1.5).delay(1.4), value: drawingHeight)
                icon(icon: "🍇").animation(animation.speed(1.5).delay(1.5), value: drawingHeight)
                icon(icon: "🍋").animation(animation.speed(1.5).delay(1.6), value: drawingHeight)
                icon(icon: "🍈").animation(animation.speed(1.5).delay(1.7), value: drawingHeight)
            }
            Spacer().frame(height: 50)
            ProgressView("\(text)")
                .font(.system(size: 20, weight: .bold))
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
                .frame(maxWidth: .infinity)
            Spacer().frame(height: 50)
            HStack {
                icon(icon: "🍊").animation(animation.speed(1.5).delay(1.7), value: drawingHeight)
                icon(icon: "🍍").animation(animation.speed(1.5).delay(1.6), value: drawingHeight)
                icon(icon: "🥔").animation(animation.speed(1.5).delay(1.5), value: drawingHeight)
                icon(icon: "🍓").animation(animation.speed(1.5).delay(1.4), value: drawingHeight)
                icon(icon: "🍠").animation(animation.speed(1.5).delay(1.3), value: drawingHeight)
                icon(icon: "🍅").animation(animation.speed(1.5).delay(1.2), value: drawingHeight)
                icon(icon: "🍉").animation(animation.speed(1.5).delay(1.1), value: drawingHeight)
                icon(icon: "📦").animation(animation.speed(1.5).delay(1), value: drawingHeight)
            }
            Spacer()
        }
        .background(backgroundColor.animation(.easeIn))
        .ignoresSafeArea()
        .onAppear {
            drawingHeight.toggle()
        }
    }
    
    func icon(icon: String, low: CGFloat = 0.0, high: CGFloat = 50) -> some View {
        Text("\(icon)")
            .offset(y: drawingHeight ? -1 * high : low)
            
    }
    
    var animation: Animation {
        return .linear(duration: 1).repeatForever()
    }
}

#Preview {
    LoadingView(text: .constant("테스트중..."), backgroundColor: .constant(Colors.background), duration: 1)
}
