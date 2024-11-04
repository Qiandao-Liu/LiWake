//
//  LiDARDetection.swift
//  LiWake
//
//  Created by Qiandao Liu on 11/1/24.
//

import ARKit
import UIKit
import RealityKit

class LiDARDetection: NSObject, ARSessionDelegate {
    private var arView: ARView?
    private var depthImage: UIImage?
    
    init(arView: ARView) {
        self.arView = arView
        super.init()
        setupARSession()
    }
    
    private func setupARSession() {
        guard let arView = arView else { return }
        
        let configuration = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics = .sceneDepth
        }
        
        arView.session.delegate = self
        arView.session.run(configuration)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        depthImage = frame.depthMapTransformedImage(
            orientation: self.orientation,
            viewPort: arView?.bounds ?? CGRect.zero
        )
    }
    
    var orientation: UIInterfaceOrientation {
        guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
            return .portrait
        }
        return orientation
    }
    
    func getCurrentDepthImage() -> UIImage? {
        return depthImage
    }
}

extension ARFrame {
    func depthMapTransformedImage(orientation: UIInterfaceOrientation, viewPort: CGRect) -> UIImage? {
        guard let pixelBuffer = self.sceneDepth?.depthMap else { return nil }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        return UIImage(ciImage: screenTransformed(ciImage: ciImage, orientation: orientation, viewPort: viewPort))
    }

    func screenTransformed(ciImage: CIImage, orientation: UIInterfaceOrientation, viewPort: CGRect) -> CIImage {
        let transform = screenTransform(orientation: orientation, viewPortSize: viewPort.size, captureSize: ciImage.extent.size)
        return ciImage.transformed(by: transform).cropped(to: viewPort)
    }

    func screenTransform(orientation: UIInterfaceOrientation, viewPortSize: CGSize, captureSize: CGSize) -> CGAffineTransform {
        let normalizeTransform = CGAffineTransform(scaleX: 1.0 / captureSize.width, y: 1.0 / captureSize.height)
        let flipTransform = (orientation.isPortrait) ? CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -1, y: -1) : .identity
        let displayTransform = self.displayTransform(for: orientation, viewportSize: viewPortSize)
        let toViewPortTransform = CGAffineTransform(scaleX: viewPortSize.width, y: viewPortSize.height)
        return normalizeTransform.concatenating(flipTransform).concatenating(displayTransform).concatenating(toViewPortTransform)
    }
}
