//
//  LiDARDetection.swift
//  LiWake
//
//  Created by Qiandao Liu on 11/1/24.
//

import Foundation
import ARKit

class LiDARDetection: NSObject, ARSessionDelegate {
    private var session: ARSession
    private var benchmarkDepthData: CVPixelBuffer? // 基准深度图数据
    private let comparisonThreshold: Float = 0.3 // 深度差异阈值，用于判断是否有人在床上
    private let samplingInterval: TimeInterval = 1.0 // 深度图采集频率，单位秒
    
    private var timer: Timer? // 采集频率
    
    init(session: ARSession) {
        self.session = session
        super.init()
        self.session.delegate = self
        configureSession()
    }
    
    private func configureSession() {
        // 配置 AR 会话以启用深度图采集
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .automatic
        if type(of: configuration).supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics = .sceneDepth
        }
        session.run(configuration)
    }
    
    // 采集基准深度图，用户在不在床时调用
    func captureBenchmarkDepthData() {
        guard let frame = session.currentFrame else {
            print("Failed to capture benchmark depth data")
            return
        }
        benchmarkDepthData = frame.sceneDepth?.depthMap
        print("Benchmark depth data captured")
    }
    
    // 开始定时采集深度图并判断用户是否在床上
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: samplingInterval, repeats: true) { [weak self] _ in
            self?.checkPresenceOnBed()
        }
    }
    
    // 停止监控
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    // 对比当前深度图和基准深度图，判断是否有显著差异
    private func checkPresenceOnBed() {
        guard let benchmarkData = benchmarkDepthData,
              let currentFrame = session.currentFrame,
              let currentDepthData = currentFrame.sceneDepth?.depthMap else {
            print("Depth data is not available for comparison")
            return
        }
        
        // 计算深度图差异
        let presenceDetected = compareDepthData(benchmarkData, currentDepthData)
        if presenceDetected {
            print("User detected on bed")
        } else {
            print("Bed is empty")
        }
    }
    
    // 对比深度图数据，判断深度差异是否超过阈值
    private func compareDepthData(_ benchmarkData: CVPixelBuffer, _ currentData: CVPixelBuffer) -> Bool {
        CVPixelBufferLockBaseAddress(benchmarkData, .readOnly)
        CVPixelBufferLockBaseAddress(currentData, .readOnly)
        
        defer {
            CVPixelBufferUnlockBaseAddress(benchmarkData, .readOnly)
            CVPixelBufferUnlockBaseAddress(currentData, .readOnly)
        }
        
        let width = CVPixelBufferGetWidth(benchmarkData)
        let height = CVPixelBufferGetHeight(benchmarkData)
        
        guard width == CVPixelBufferGetWidth(currentData), height == CVPixelBufferGetHeight(currentData) else {
            print("Depth data dimensions do not match")
            return false
        }
        
        let benchmarkPointer = CVPixelBufferGetBaseAddressOfPlane(benchmarkData, 0)
        let currentPointer = CVPixelBufferGetBaseAddressOfPlane(currentData, 0)
        
        let benchmarkBuffer = benchmarkPointer?.assumingMemoryBound(to: Float32.self)
        let currentBuffer = currentPointer?.assumingMemoryBound(to: Float32.self)
        
        var totalDifference: Float = 0.0
        var count: Int = 0
        
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                let benchmarkDepth = benchmarkBuffer?[index] ?? 0.0
                let currentDepth = currentBuffer?[index] ?? 0.0
                
                let difference = abs(currentDepth - benchmarkDepth)
                totalDifference += difference
                count += 1
            }
        }
        
        // 计算平均深度差异
        let averageDifference = totalDifference / Float(count)
        
        // 判断是否有用户在床上
        return averageDifference > comparisonThreshold
    }
}
