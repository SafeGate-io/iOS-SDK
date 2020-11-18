//
//  Button.swift
//  ExampleApp
//
//  Created by Kirill Budevich on 11/18/20.
//

import UIKit

class Button: UIButton {
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .white)
        view.hidesWhenStopped = true
        return view
    }()
    
    private var titleForActivity: String?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 10
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setTitleColor(.white, for: .normal)
        backgroundColor = UIColor(named: "deepSkyBlue")
        contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    func showActivity() {
        titleForActivity = title(for: .normal)
        setTitle(nil, for: .normal)
        activityIndicator.startAnimating()
        isUserInteractionEnabled = !activityIndicator.isAnimating
    }
    
    func hideActivity() {
        activityIndicator.stopAnimating()
        setTitle(titleForActivity, for: .normal)
        titleForActivity = nil
        isUserInteractionEnabled = !activityIndicator.isAnimating
    }
}
