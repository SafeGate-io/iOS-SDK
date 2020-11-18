//
//  TemperatureMeterInjectable.swift
//  ExampleApp
//
//  Created by Kirill Budevich on 11/18/20.
//

import SafeGateSDK

protocol TemperatureMeterInjectable: AnyObject {
    var temperatureMeter: TemperatureMeter! { get set }
    
    func inject(temperatureMeter: TemperatureMeter)
}

extension TemperatureMeterInjectable {
    func inject(temperatureMeter: TemperatureMeter) {
        assert(self.temperatureMeter == nil, "\(#function) must be called once!")
        self.temperatureMeter = temperatureMeter
    }
}
