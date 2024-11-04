//
//  DepthInstructionView.swift
//  LiWake
//
//  Created by Qiandao Liu on 11/3/24.
//

import SwiftUI

struct DepthInstructionView: View {
    @State private var navigateToDetection = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                
                ZStack {
                    // 指示图片
                    Image(systemName: "ipad")
                        .resizable()
                        .frame(width: width * 0.5, height: height * 0.5) // 占宽度的40%
                        .position(x: width * 0.5, y: height * 0.4)

                    // 提示文字
                    Text("请将 iPad 竖直放置在床头柜上，背面朝向床，距离床大约 1 - 1.5 英尺。")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .position(x: width * 0.5, y: height * 0.8)


                    // 按钮
                    Button(action: {
                        navigateToDetection = true
                    }) {
                        Text("知道了")
                            .font(.headline)
                            .padding()
                            .frame(width: width * 0.1)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .position(x: width * 0.9, y: height * 0.9) // 按钮位于右下角
                }
                .navigationDestination(isPresented: $navigateToDetection) {
                    DetectionView()
                }
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    DepthInstructionView()
}
