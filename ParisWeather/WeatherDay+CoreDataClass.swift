//
//  WeatherDay+CoreDataClass.swift
//  ParisWeather
//
//  Created by Kersuzan on 17/11/2016.
//  Copyright © 2016 com.kersuzan. All rights reserved.
//

import Foundation
import CoreData

@objc(WeatherDay)
public class WeatherDay: NSManagedObject {

    // MARK: - Custom intializer
    convenience init(context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: "WeatherDay", in: context) else {
            // Entity must exist, otherwise we must stop the application
            fatalError("Cannot instanciate entity")
        }
    
        self.init(entity: entity, insertInto: context)
    }
    
    convenience init(context: NSManagedObjectContext, jsonWeatherDay: JSONWeatherDay) {
        self.init(context: context)
        
        self.shortDescriptionWeather = jsonWeatherDay.shortDescriptionWeather
        self.longDescriptionWeather = jsonWeatherDay.longDescriptionWeather
        self.icon = jsonWeatherDay.icon
        self.tempDay = jsonWeatherDay.tempDay
        self.tempMax = jsonWeatherDay.tempMax
        self.tempMin = jsonWeatherDay.tempMin
        self.windSpeed = jsonWeatherDay.windSpeed
        self.windDirection = jsonWeatherDay.windDirection
        self.humidity = jsonWeatherDay.humidity
        self.pressure = jsonWeatherDay.pressure
    }
    
}
