//
//  MeasuringViewController.swift
//  ExampleApp
//
//  Created by Kirill Budevich on 11/18/20.
//

import UIKit
import AVKit
import SafeGateSDK

class MeasuringViewController: UIViewController {
    @IBOutlet var faceView: FaceView! {
        didSet {
            faceView.previewLayer = previewLayer
        }
    }
    @IBOutlet var previewView: UIView!
    @IBOutlet var checkButton: Button!
    @IBOutlet var detectButton: Button!
    @IBOutlet var messageLabel: UILabel!
    
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private var face: Detection.Face? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.drawContours()
            }
        }
    }
    
    private let formatter = MeasurementFormatter()
    
    private let detection = Detection()
    internal var temperatureMeter: TemperatureMeter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPreview()
        messageLabel.text = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        previewLayer.frame = previewView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        previewLayer.session?.startRunning()
    }
}

extension MeasuringViewController: TemperatureMeterInjectable { }

// MARK: - Camera Preview

extension MeasuringViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        detection.detectFace(at: sampleBuffer, metadata: .init(cameraPosition: .front,
                                                               interfaceOrientation: .portrait)) { [weak self] in
            switch $0 {
            case .success(let face):
                self?.face = face
            case .failure(let error):
                self?.logError(error)
            }
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        face = nil
    }
}

private extension MeasuringViewController {
    func setupPreview() {
        previewLayer.videoGravity = .resizeAspectFill
        previewView.layer.insertSublayer(previewLayer, at: 0)
        
        do {
            let queue = DispatchQueue(label: "videooutput.serial.queue", qos: .userInitiated)
            previewLayer.session = createVideoSession(input: try createVideoInput(),
                                                      output: createVideoOutput(queue: queue))
        } catch {
            fatalError("Cannot create video session with error \(error)")
        }
    }
    
    func createVideoInput() throws -> AVCaptureDeviceInput {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            fatalError("Camera device doesn't exist.")
        }
                
        return try AVCaptureDeviceInput(device: camera)
    }
    
    func createVideoOutput(queue: DispatchQueue) -> AVCaptureVideoDataOutput {
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [
            (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA,
        ]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: queue)
        
        return output
    }
    
    func createVideoSession(input: AVCaptureDeviceInput, output: AVCaptureVideoDataOutput) -> AVCaptureSession {
        let session = AVCaptureSession()
        session.beginConfiguration()
        
        session.sessionPreset = .hd1280x720
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        session.commitConfiguration()
        
        return session
    }
}

// MARK: - Detection&Checking

extension MeasuringViewController {
    var logError: (Error) -> Void {
        return { [weak self] error in
            self?.setMessage("Error: \(error.localizedDescription)")
        }
    }
    
    func drawContours() {
        faceView.drawBoundingBox(face?.normalizedBoundingBox)
        faceView.drawContours(face?.normalizedContours)
    }
    
    @IBAction func checkTemperature() {
        checkButton.showActivity()
        DispatchQueue.main.async { [weak self] in
            self?.temperatureMeter.measure { result in
                guard let self = self else { return }
                do {
                    let temperatures = try self.temperatureMeter.rotatePixelsTemperatures(result.get(), by: .pi)
                    let estimated = try self.temperatureMeter.getEstimatedForeheadTemperature(from: temperatures)
                    self.setMessage("Temperature - \(self.formatter.string(from: estimated))")
                } catch {
                    self.logError(error)
                }
                self.checkButton.hideActivity()
            }
        }
    }
    
    @IBAction func deteckMask() {
        guard let face = face else {
            setMessage("Not found Face")
            return
        }
        
        detectButton.showActivity()
        detection.detectMask(at: face) { [weak self] result in
            DispatchQueue.main.async {
                self?.detectButton.hideActivity()
            }
            switch result {
            case .success(let mask):
                self?.setMessage("Mask: \(mask)")
            case .failure(let error):
                self?.logError(error)
            }
        }
    }
}

private extension MeasuringViewController {
    func setMessage(_ message: String) {
        print("Message - \(message)")
        DispatchQueue.main.async { [weak self] in
            self?.messageLabel.text = message
        }
    }
}
