//
//  JSONWeatherInfo.swift
//  ParisWeather
//
//  Created by Kersuzan on 17/11/2016.
//  Copyright © 2016 com.kersuzan. All rights reserved.
//

import Foundation
import Gloss

enum WeatherError: Error {
    case InvalidData(item: String)
}

enum WindDirection: String {
    case N = "North"
    case NNE = "North/North Est"
    case NE = "North Est"
    case ENE = "Est/North Est"
    case E = "Est"
    case ESE = "Est/South Est"
    case SE = "South Est"
    case SSE = "South/South Est"
    case S = "South"
    case SSW = "South/South West"
    case SW = "South West"
    case WSW = "West/South West"
    case W =  "West"
    case WNW = "West/North West"
    case NW = "North West"
    case NNW = "North/North West"
}

struct JSONWeatherInfo: Decodable {
    
    var error: WeatherError? // Since the init function cannot throw in order to conform Decodable protocol, we put this error variable to toggle error state
    var shortDescriptionWeather: String?
    var longDescriptionWeather: String?
    var icon: String?
    var tempMin: Double
    var tempMax: Double
    var tempDay: Double
    var windSpeed: Double
    var windDirection: String
    var pressure: Double
    var humidity: Double
    var date: Date?
    
    init?(json: JSON) {
        // Weather info
        guard let mainInfo: [[String: AnyObject]] = "weather" <~~ json else {
            self.error = WeatherError.InvalidData(item: "main")
            return nil
        }
        
        if let mainDescription = mainInfo.first?["main"] as? String {
            self.shortDescriptionWeather = mainDescription
        }
        
        if let longDescription = mainInfo.first?["description"] as? String {
            self.longDescriptionWeather = longDescription
        }
        
        if let icon = mainInfo.first?["icon"] as? String {
            self.icon = icon
        }
        
        // Temperatures
        guard let tempDay: Double = "main.temp" <~~ json else {
            self.error =  WeatherError.InvalidData(item: "tempDay")
            return nil
        }
        self.tempDay = tempDay
        
        guard let tempMin: Double = "main.temp_min" <~~ json else {
            self.error = WeatherError.InvalidData(item: "tempMin")
            return nil
        }
        self.tempMin = tempMin
        
        
        guard let tempMax: Double = "main.temp_max" <~~ json else {
            self.error = WeatherError.InvalidData(item: "tempMax")
            return nil
        }
        self.tempMax = tempMax
        
        // Extract the date from json file
        guard let intervalInMilliseconds: Int = "dt" <~~ json else {
            self.error = WeatherError.InvalidData(item: "Date")
            return nil
        }
        
        self.date = Date(timeIntervalSince1970: TimeInterval(intervalInMilliseconds))
        
        // Wind
        guard let windSpeed: Double = "wind.speed" <~~ json else {
            self.error = WeatherError.InvalidData(item: "WindSpeed")
            return nil
        }
        self.windSpeed = windSpeed
        
        guard let windDirectionInDegrees: Double = "wind.deg" <~~ json else {
            self.error = WeatherError.InvalidData(item: "WindDirection")
            return nil
        }
        self.windDirection = JSONWeatherInfo.convertWindDegreeToWindDirection(degree: windDirectionInDegrees)
        
        // Pressure
        guard let pressure: Double = "main.pressure" <~~ json else {
            self.error = WeatherError.InvalidData(item: "Pressure")
            return nil
        }
        self.pressure = pressure
        
        // Humidity
        guard let humidity: Double = "main.humidity" <~~ json else {
            self.error = WeatherError.InvalidData(item: "Humidity")
            return nil
        }
        self.humidity = humidity
    }
    
    static func convertWindDegreeToWindDirection(degree: Double) -> String {
        switch (degree) {
        case 348.75...360:
            return WindDirection.N.rawValue
        case 0..<11.25:
            return WindDirection.N.rawValue
        case 11.25..<33.75:
            return WindDirection.NNE.rawValue
        case 33.75..<56.25:
            return WindDirection.NE.rawValue
        case 56.25..<78.75:
            return WindDirection.ENE.rawValue
        case 78.75..<101.25:
            return WindDirection.E.rawValue
        case 101.25..<123.75:
            return WindDirection.ESE.rawValue
        case 123.75..<146.25:
            return WindDirection.SE.rawValue
        case 146.25..<168.75:
            return WindDirection.SSE.rawValue
        case 168.75..<191.25:
            return WindDirection.S.rawValue
        case 191.25..<213.75:
            return WindDirection.SSW.rawValue
        case 213.75..<236.25:
            return WindDirection.SW.rawValue
        case 236.25..<258.75:
            return WindDirection.WSW.rawValue
        case 258.75..<281.25:
            return WindDirection.W.rawValue
        case 281.25..<303.75:
            return WindDirection.WNW.rawValue
        case 303.75..<326.25:
            return WindDirection.NW.rawValue
        case 326.25..<348.75:
            return WindDirection.NNW.rawValue
        default:
            return WindDirection.N.rawValue
        }
    }
}
