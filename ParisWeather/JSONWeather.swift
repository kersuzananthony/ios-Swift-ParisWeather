//
//  JSONWeather.swift
//  ParisWeather
//
//  Created by Kersuzan on 17/11/2016.
//  Copyright © 2016 com.kersuzan. All rights reserved.
//

import Foundation
import Gloss


struct JSONWeather: Decodable {
    
    var weatherDay: [JSONWeatherInfo]?
    
    init?(json: JSON) {
        self.weatherDay = "list" <~~ json
    }
    
}
