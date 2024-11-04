//
//  DetectionView.swift
//  LiWake
//
//  Created by Qiandao Liu on 11/2/24.
//

import SwiftUI
import RealityKit

struct DetectionView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DetectionViewController {
        let controller = DetectionViewController()
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

#Preview(traits: .landscapeRight) {
    DetectionView()
}
