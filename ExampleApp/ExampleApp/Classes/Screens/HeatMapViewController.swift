//
//  HeatMapViewController.swift
//  ExampleApp
//
//  Created by Kirill Budevich on 11/18/20.
//

import UIKit
import SafeGateSDK

class HeatMapViewController: UIViewController {
    
    @IBOutlet var palleteSegmentedControl: UISegmentedControl!
    @IBOutlet var blurSlider: TitledSlider!
    @IBOutlet var pixelSizeSlider: TitledSlider!
    @IBOutlet var heatMapImageView: UIImageView!
    @IBOutlet var drawButton: Button!
    
    private let drawer = HeatMapDrawer(pallete: HeatMapDrawer.Pallete.default())
    private let palletes: [Pallete] = {
        let range = Temperature.deciKelvin(2931.5)...Temperature.deciKelvin(3151.5)
        return [("Monochrome", .monochrome(range)), ("TwoColored", .twoColored(range)), ("FiveColored", .fiveColored(range))]
    }()
    
    internal var temperatureMeter: TemperatureMeter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPalletes()
        setupSliders()
    }
}

extension HeatMapViewController: TemperatureMeterInjectable { }

private extension HeatMapViewController {
    @IBAction func drawButtonTapped(_ sender: UIButton) {
        clearHeatMap()
        drawButton.showActivity()
        let pixelSize = self.pixelSize
        let blur = self.blurValue
        temperatureMeter.measure { [weak self] result in
            guard let self = self else { return }
            defer { self.drawButton.hideActivity() }
            
            do {
                let temperatures = try self.temperatureMeter.rotatePixelsTemperatures(try result.get(), by: .pi)
                let heatMap = self.drawer.drawHeatMap(for: temperatures, pixelSize: pixelSize, applyBlur: blur)
                self.heatMapImageView.image = heatMap
            } catch {
                print(error)
            }
        }
    }
    
    typealias Pallete = (name: String, pallete: HeatMapDrawer.Pallete)
    var selectedPallete: Pallete { palletes[palleteSegmentedControl.selectedSegmentIndex] }
    func setupPalletes() {
        palleteSegmentedControl.removeAllSegments()
        palletes.enumerated().forEach {
            palleteSegmentedControl.insertSegment(withTitle: $0.element.name, at: $0.offset, animated: false)
        }
        palleteSegmentedControl.selectedSegmentIndex = palletes.count / 2
        palleteSegmentedControl.addTarget(self, action: #selector(changePallete), for: .valueChanged)
        changePallete()
    }
    
    @objc func changePallete() {
        drawer.setPallete(selectedPallete.pallete)
    }
    
    var blurValue: CGFloat? { blurSlider.value == 0 ? nil : CGFloat(blurSlider.value.rounded()) }
    var pixelSize: CGFloat { CGFloat(pixelSizeSlider.value).rounded() }
    func setupSliders() {
        blurSlider.setTitle("Blur -")
        blurSlider.minimumValue = 0
        blurSlider.maximumValue = 40
        blurSlider.value = 8
        blurSlider.maximumFractionDigits = 0

        pixelSizeSlider.setTitle("Pixel Size -")
        pixelSizeSlider.minimumValue = 1
        pixelSizeSlider.maximumValue = 64
        pixelSizeSlider.value = 8
        pixelSizeSlider.maximumFractionDigits = 0
        
        [blurSlider, pixelSizeSlider].forEach {
            $0?.addTarget(self, action: #selector(clearHeatMap), for: .valueChanged)
        }
    }
    
    @objc func clearHeatMap() {
        heatMapImageView.image = nil
    }
}

private extension Temperature {
    static func deciKelvin(_ value: Double) -> Self {
        Temperature(value: value, unit: .deciKelvin)
    }
}
