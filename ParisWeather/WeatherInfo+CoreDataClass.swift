//
//  WeatherInfo+CoreDataClass.swift
//  ParisWeather
//
//  Created by Kersuzan on 17/11/2016.
//  Copyright © 2016 com.kersuzan. All rights reserved.
//

import Foundation
import CoreData

@objc(WeatherInfo)
public class WeatherInfo: NSManagedObject {

    // MARK: - Custom intializer
    convenience init(context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: "WeatherInfo", in: context) else {
            // Entity must exist, otherwise we must stop the application
            fatalError("Cannot instanciate entity")
        }
    
        self.init(entity: entity, insertInto: context)
    }
    
    convenience init(context: NSManagedObjectContext, jsonWeatherInfo: JSONWeatherInfo) {
        self.init(context: context)
        
        self.shortDescriptionWeather = jsonWeatherInfo.shortDescriptionWeather
        self.longDescriptionWeather = jsonWeatherInfo.longDescriptionWeather
        self.icon = jsonWeatherInfo.icon
        self.tempDay = jsonWeatherInfo.tempDay
        self.tempMax = jsonWeatherInfo.tempMax
        self.tempMin = jsonWeatherInfo.tempMin
        self.windSpeed = jsonWeatherInfo.windSpeed
        self.windDirection = jsonWeatherInfo.windDirection
        self.humidity = jsonWeatherInfo.humidity
        self.pressure = jsonWeatherInfo.pressure
        self.date = jsonWeatherInfo.date
    }
    
}
