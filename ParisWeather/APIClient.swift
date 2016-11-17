//
//  APIClient.swift
//  ParisWeather
//
//  Created by Kersuzan on 17/11/2016.
//  Copyright © 2016 com.kersuzan. All rights reserved.
//

import Foundation

class APIClient {
    
    static let API_KEY = "e43ee41f2412bd9bee1c4315fe76902c"
    static let WEATHER_URL: String = {
        return "http://api.openweathermap.org/data/2.5/forecast?q=Paris&mode=json&appid=\(API_KEY)"
    }()
    
    
}
