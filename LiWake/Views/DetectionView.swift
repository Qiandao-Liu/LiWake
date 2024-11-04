//
//  DetectionView.swift
//  LiWake
//
//  Created by Qiandao Liu on 11/2/24.
//

import SwiftUI
import RealityKit

struct DetectionView: UIViewControllerRepresentable {
    @Binding var isReady: Bool
    
    func makeUIViewController(context: Context) -> DetectionViewController {
        let controller = DetectionViewController()
//        controller.onReady = {
//            isReady = true
//        }
        return controller
    }

    func updateUIViewController(_ uiViewController: DetectionViewController, context: Context) {}
}

class DetectionViewController: UIViewController {
    var arView: ARView!
    var imageView: UIImageView!
    var lidarDetection: LiDARDetection?
    var showInstruction: Binding<Bool>?

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

struct DetectionViewWrapper: View {
    @State private var isReady = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height

                ZStack {
                    DetectionView(isReady: $isReady)
                        .edgesIgnoringSafeArea(.all) // 全屏显示深度图

                    // “放好了”按钮
                    if !isReady {
                        Button(action: {
                            isReady = true
                        }) {
                            Text("放好了")
                                .font(.headline)
                                .padding()
                                .frame(width: width * 0.1)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .position(x: width * 0.9, y: height * 0.9) // 右下角
                    }
                }
            }
        }
        .navigationDestination(isPresented: $isReady) {
            NightmodeView()
        }
    }
}

#Preview(traits: .landscapeRight) {
    DetectionViewWrapper()
}
