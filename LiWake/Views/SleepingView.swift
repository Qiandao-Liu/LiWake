//
//  SleepingView.swift
//  LiWake
//
//  Created by Qiandao Liu on 11/2/24.
//

import SwiftUI
import RealityKit

struct SleepingView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SleepingViewController {
        return SleepingViewController()
    }

    func updateUIViewController(_ uiViewController: SleepingViewController, context: Context) {}
}

class SleepingViewController: UIViewController {
    var arView: ARView!
    var imageView: UIImageView!
    var lidarDetection: LiDARDetection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView = ARView(frame: self.view.frame)
        view.addSubview(arView)
        
        imageView = UIImageView(frame: self.view.frame)
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        lidarDetection = LiDARDetection(arView: arView)
        
        // 使用计时器定期更新深度图
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let depthImage = self.lidarDetection?.getCurrentDepthImage() {
                self.imageView.image = depthImage
            }
        }
    }
}


struct DepthInstructionView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Image(systemName: "photo")  // 示例图片，请替换为实际说明图
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            Text("请将iPad放在床头柜上，背面朝向床，距离1-1.5英尺。")
                .font(.headline)
                .padding()
            Button("确认") {
                isPresented = false
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

#Preview(traits: .landscapeRight) {
    SleepingView()
}
