//
//  Weather+CoreDataClass.swift
//  ParisWeather
//
//  Created by Kersuzan on 17/11/2016.
//  Copyright © 2016 com.kersuzan. All rights reserved.
//

import Foundation
import CoreData

@objc(Weather)
public class Weather: NSManagedObject {

    // MARK: - Custom intializer
    convenience init(context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Weather", in: context) else {
            // Entity must exist, otherwise we must stop the application
            fatalError("Cannot instanciate entity")
        }
    
        self.init(entity: entity, insertInto: context)
    }
    
    convenience init(context: NSManagedObjectContext, jsonWeather: JSONWeather) {
        self.init(context: context)
        
        self.shortDescriptionWeather = jsonWeather.shortDescriptionWeather
        self.longDescriptionWeather = jsonWeather.longDescriptionWeather
        self.icon = jsonWeather.icon
        self.tempDay = jsonWeather.tempDay
        self.tempMax = jsonWeather.tempMax
        self.tempMin = jsonWeather.tempMin
        self.windSpeed = jsonWeather.windSpeed
        self.windDirection = jsonWeather.windDirection
        self.humidity = jsonWeather.humidity
        self.pressure = jsonWeather.pressure
    }
    
}
