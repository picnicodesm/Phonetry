//
//  ScannerOverlayView.swift
//  Phonetry
//
//  Created by 김상민 on 3/4/24.
//

import SwiftUI

struct ScannerOverlayView: View {
    typealias ScanBox = GlobalConstants.Scanner
    
    @Binding var isScan: Bool // true: scan, false: take picture
    @Binding var cameraCaptured: Bool
    
    let opacity: CGFloat = 0.5
    let horizontalSpacing: CGFloat = 80
    let selectionBoxPositionY: CGFloat = 280
    let guideLineWidth: CGFloat = 8
    var freeSpace: CGFloat { return guideLineWidth / 2 }
    let lineLength: CGFloat = ScanBox.width / 5
    var unSelectedColor: Color { return isScan ? .black : .white }
        
    var body: some View {
        ZStack {
            if isScan {
                guideLine
                    .zIndex(1)
                    .foregroundColor(.white)
                VStack(spacing: 0) {
                    blindRect
                    blindRectMiddle
                    blindRect
                }
            }
            selectionBox
        }
        .ignoresSafeArea()
    }
    
    private var blindRect: some View {
        Rectangle()
            .fill(.black.opacity(opacity))
    }
    
    private var blindRectMiddle: some View {
        HStack(spacing: ScanBox.width) {
            blindRect
                .frame(width: ScanBox.offsetX)
            blindRect
                .frame(width: ScanBox.offsetX)
        }
        .frame(height: ScanBox.height)
    }
    
    private struct TypeButton: View {
        let touchableWidth: CGFloat = 80
        let touchableHeight: CGFloat = 80
        let text: String
        let imageString: String
        
        var body: some View {
            VStack {
                Image(systemName: imageString)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text(text)
            }
            .frame(width: touchableWidth, height: touchableHeight)
        }
    }
    
    private var selectionBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke()
                .frame(width: ScanBox.width, height: ScanBox.height / 3)
                .overlay {
                    HStack(spacing: horizontalSpacing) {
                        TypeButton(text: "스캔", imageString: "barcode.viewfinder")
                            .foregroundStyle(isScan ? .blue : unSelectedColor)
                            .onTapGesture {
                                isScan = true
                            }
                        
                        TypeButton(text: "촬영", imageString: "camera.viewfinder")
                            .foregroundStyle(isScan ? unSelectedColor : .blue)
                            .onTapGesture {
                                isScan = false
                                cameraCaptured = false // 필요 없을지도?
                            }
                    }
                }
                .offset(x: 0, y : selectionBoxPositionY)
                .foregroundColor(isScan ? .black : .white)
        }
    }
    
    @ViewBuilder
    private var guideLineSegment: some View {
        Path { path in
            path.move(to: CGPoint(x: ScanBox.offsetX - freeSpace, y: ScanBox.offsetY))
            path.addLine(to: CGPoint(x: ScanBox.offsetX, y: ScanBox.offsetY))
            path.addLine(to: CGPoint(x: ScanBox.offsetX + lineLength, y: ScanBox.offsetY))
        }
        .stroke(style: StrokeStyle(lineWidth: guideLineWidth))
        
        Path { path in
            path.move(to: CGPoint(x: ScanBox.offsetX + ScanBox.width + freeSpace, y: ScanBox.offsetY))
            path.addLine(to: CGPoint(x: ScanBox.offsetX + ScanBox.width, y: ScanBox.offsetY))
            path.addLine(to: CGPoint(x: ScanBox.offsetX + ScanBox.width - lineLength, y: ScanBox.offsetY))
        }
        .stroke(style: StrokeStyle(lineWidth: guideLineWidth))
    }
    
    @ViewBuilder
    private var guideLine: some View {
        guideLineSegment
        guideLineSegment
            .rotationEffect(.degrees(90))
        guideLineSegment
            .rotationEffect(.degrees(180))
        guideLineSegment
            .rotationEffect(.degrees(270))
    }
}

#Preview {
    ScannerOverlayView(isScan: .constant(false), cameraCaptured: .constant(false))
}
