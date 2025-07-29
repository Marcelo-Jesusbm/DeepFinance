//
//  SparklineView.swift
//  DeepFinance
//
//  Created by Marcelo Jesus on 29/07/25.
//

import SwiftUI


struct SparklineView: View {
    let data: [Double]
    
    private let color: Color
    
    init(data: [Double]) {
        self.data = data
        let priceChange = (data.last ?? 0) - (data.first ?? 0)
        self.color = priceChange >= 0 ? .theme.green : .theme.red
    }
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                for index in data.indices {
                    let xPosition = geometry.size.width / CGFloat(data.count) * CGFloat(index + 1)
                    
                    let yAxis = (data.max() ?? 0) - (data.min() ?? 0)
                    let yPosition = (1 - CGFloat((data[index] - (data.min() ?? 0)) / yAxis)) * geometry.size.height
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    }
                    path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                }
            }
            .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
        .frame(height: 50)
    }
}
