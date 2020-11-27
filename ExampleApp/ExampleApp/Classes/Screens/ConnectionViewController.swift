//
//  ConnectionViewController.swift
//  ExampleApp
//
//  Created by Kirill Budevich on 11/18/20.
//

import UIKit
import SafeGateSDK

class ConnectionViewController: UIViewController {
    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var connectButton: Button!
    @IBOutlet private var goMeasureButton: Button!
    @IBOutlet private var goHeatMapButton: Button!
    
    private let temperatureMeter = TemperatureMeter()

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideButtons()
        setInfo()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let injectable as TemperatureMeterInjectable:
            injectable.inject(temperatureMeter: temperatureMeter)
        default:
            break
        }
    }
}

private extension ConnectionViewController {
    var camera: ThermalCamera? { temperatureMeter.thermalCamera }
    var isConnected: Bool { camera != nil }
    
    @IBAction func connectButtonTapped() {
        connectButton.showActivity()
        temperatureMeter.estabilishConnectionWithFirstThermalCamera(timeout: 10) { [weak self] result in
            self?.connectButton.hideActivity()
            self?.hideButtons()

            switch result {
            case .success:
                self?.setInfo()
            case .failure(let error):
                self?.setInfo(with: error)
            }
        }
    }
    
    func hideButtons() {
        connectButton.isHidden = isConnected
        [goMeasureButton, goHeatMapButton].forEach { $0?.isHidden = !isConnected }
    }
    
    func setInfo(with error: Error? = nil) {
        if let error = error {
            infoLabel.text = Text.error(error.localizedDescription)
        } else {
            infoLabel.text = isConnected
                ? Text.connected(camera: camera?.name ?? camera?.id.uuidString ?? "")
                : Text.plsConnect
        }
    }
}

private struct Text {
    static let plsConnect = "Please turn on Bluetooth on iOS device and connect to Thermal Camera"
    
    static func connected(camera: String) -> String { "Connected to\n\(camera)" }
    static func error(_ message: String) -> String { "Error:\n\(message)" }
}
