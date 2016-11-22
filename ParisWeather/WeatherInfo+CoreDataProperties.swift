//
//  WeatherInfo+CoreDataProperties.swift
//  ParisWeather
//
//  Created by Kersuzan on 17/11/2016.
//  Copyright © 2016 com.kersuzan. All rights reserved.
//

import Foundation
import CoreData


extension WeatherInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherInfo> {
        return NSFetchRequest<WeatherInfo>(entityName: "WeatherInfo");
    }

    @NSManaged public var shortDescriptionWeather: String?
    @NSManaged public var longDescriptionWeather: String?
    @NSManaged public var tempMin: Double
    @NSManaged public var tempMax: Double
    @NSManaged public var tempDay: Double
    @NSManaged public var tempNight: Double
    @NSManaged public var pressure: Double
    @NSManaged public var humidity: Double
    @NSManaged public var windSpeed: Double
    @NSManaged public var windDirection: String?
    @NSManaged public var date: Date?
    @NSManaged public var icon: String?

}
