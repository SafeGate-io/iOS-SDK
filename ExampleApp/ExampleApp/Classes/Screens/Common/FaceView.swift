//
//  FaceView.swift
//  ExampleApp
//
//  Created by Kirill Budevich on 11/23/20.
//

import AVKit
import UIKit
import SafeGateSDK

typealias Contours = Detection.Contours
class FaceView: UIView {
    private let drawLayer: (face: LandmarkLayer, eyes: LandmarkLayer, boudingBox: CALayer) = {
        let face = LandmarkLayer(radius: 4, color: .black)
        let eyes = LandmarkLayer(radius: 4, color: .black)
        let box = CAShapeLayer()
        return (face, eyes, box)
    }()
    
    var color: UIColor = .green {
        didSet {
            applyColor(color)
        }
    }
    
    private var drawLayers: [CALayer] {
        [drawLayer.face, drawLayer.eyes, drawLayer.boudingBox]
    }
    
    weak var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        drawLayers.forEach { $0.frame = bounds }
    }
    
    func drawBoundingBox(_ box: CGRect?) {
        removeBox()
        
        guard let converter = previewLayer,
              let box = box else { return }
        
        let convertedRect = converter
            .layerRectConverted(fromMetadataOutputRect: box)
            .intersection(drawLayer.boudingBox.frame)
        drawLayer.boudingBox.addRectangle(convertedRect, color: color, width: 4)
    }
    
    func drawContours(_ contours: Contours?) {
        removeContours()
        
        guard let contours = contours else { return }
        
        let convert = previewLayer?.layerPointConverted(fromCaptureDevicePoint:)
        
        drawLayer.face.draw(landmark: contours.face.compactMap { convert?($0) })
        drawLayer.eyes.draw(landmark: contours.eyes.left.compactMap { convert?($0) })
        drawLayer.eyes.draw(landmark: contours.eyes.right.compactMap { convert?($0) })
    }
    
    func removeBox() {
        drawLayer.boudingBox.removeAllSublayers()
    }
    
    func removeContours() {
        drawLayers
            .compactMap { $0 as? LandmarkLayer }
            .forEach { $0.clean() }
    }
}

private extension FaceView {
    func setup() {
        drawLayers.reversed().forEach { layer.addSublayer($0) }
        applyColor(color)
    }
    
    func applyColor(_ color: UIColor) {
        drawLayer.face.color = color
        drawLayer.eyes.color = color
        drawLayer.boudingBox.sublayers?
            .compactMap { $0 as? CAShapeLayer }
            .forEach { $0.strokeColor = color.cgColor }
    }
}

private extension CALayer {
    func removeAllSublayers() {
        sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    func addCircle(atPoint point: CGPoint, color: UIColor, radius: CGFloat) {
        let divisor: CGFloat = 2.0
        let xCoord = point.x - radius / divisor
        let yCoord = point.y - radius / divisor
        let circleRect = CGRect(x: xCoord, y: yCoord, width: radius, height: radius)
        let layer = CAShapeLayer()
        layer.frame = circleRect
        layer.cornerRadius = radius / divisor
        layer.opacity = 0.7
        layer.backgroundColor = color.cgColor
        addSublayer(layer)
    }
    
    func addRectangle(_ rect: CGRect, color: UIColor, width: CGFloat) {
        let path = UIBezierPath(rect: rect)
        path.usesEvenOddFillRule = true
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.strokeColor = color.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = width
        layer.fillRule = .evenOdd
        addSublayer(layer)
    }
}

class LandmarkLayer: CAShapeLayer {
    var radius: CGFloat
    var color: UIColor
    
    init(radius: CGFloat, color: UIColor) {
        self.radius = radius
        self.color = color
        
        super.init()
    }
    
    required init?(coder: NSCoder) {
        radius = 1
        color = .black
        
        super.init(coder: coder)
    }
    
    func draw(landmark points: [CGPoint]) {
        points.forEach { addCircle(atPoint: $0, color: color, radius: radius) }
    }
    
    func clean() {
        removeAllSublayers()
    }
}
