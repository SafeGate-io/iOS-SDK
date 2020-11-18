//
//  TitledSlider.swift
//  ExampleApp
//
//  Created by Kirill Budevich on 11/18/20.
//

import UIKit

class TitledSlider: UIControl {
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var slider: UISlider!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    @IBOutlet private var minValueLabel: UILabel!
    @IBOutlet private var maxValueLabel: UILabel!
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    var maximumFractionDigits: Int {
        get { numberFormatter.maximumFractionDigits }
        set { numberFormatter.maximumFractionDigits = newValue }
    }

    open var value: Float {
        get { slider.value }
        set {
            slider.value = max(min(maximumValue, newValue), minimumValue)
            valueChanged()
        }
    }

    open var minimumValue: Float {
        get { slider.minimumValue }
        set {
            slider.minimumValue = newValue
            value = max(min(maximumValue, value), newValue)
            minValueLabel.text = text(for: newValue)
        }
    }

    open var maximumValue: Float {
        get { slider.maximumValue }
        set {
            slider.maximumValue = newValue
            value = max(min(newValue, value), minimumValue)
            maxValueLabel.text = text(for: newValue)
        }
    }
    
    open var isContinuous: Bool {
        get { slider.isContinuous }
        set { slider.isContinuous = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    open func setValue(_ value: Float, animated: Bool) {
        slider.setValue(value, animated: animated)
        valueChanged()
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        
        maxValueLabel.text = text(for: minimumValue)
        minValueLabel.text = text(for: maximumValue)
    }
    
    override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        slider.addTarget(target, action: action, for: controlEvents)
    }
}

private extension TitledSlider {
    @objc func valueChanged() {
        valueLabel.text = text(for: value)
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("\(type(of: self))", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func text(for value: Float) -> String? {
        numberFormatter.string(from: NSNumber(value: value))
    }
}
