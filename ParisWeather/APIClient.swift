//
//  APIClient.swift
//  ParisWeather
//
//  Created by Kersuzan on 17/11/2016.
//  Copyright © 2016 com.kersuzan. All rights reserved.
//

import Foundation
import CoreData
import Alamofire
import Alamofire_Gloss

class APIClient {
    
    static let API_KEY = "e43ee41f2412bd9bee1c4315fe76902c"
    static let WEATHER_URL: String = {
        return "http://api.openweathermap.org/data/2.5/forecast?q=Paris&mode=json&appid=\(API_KEY)"
    }()
    
    func getWeather(_ completion: @escaping (Error?, [WeatherDay]) -> ()) {
        Alamofire.request(APIClient.WEATHER_URL).responseObject(JSONWeather.self) { (response) in
            switch response.result {
            case .success(let value):
                // We got data from the API, we need to refresh data in coredata
                completion(nil, self.refreshLocalWeatherData(weatherData: value))
            case .failure(let error):
                completion(error, [])
            }
        }
    }
    
    fileprivate func refreshLocalWeatherData(weatherData: JSONWeather) -> [WeatherDay] {
        guard let coreDataManager = ApplicationManager.getInstance.coreDataManager else {
            return []
        }
        
        deletePreviousWeatherData(coreDataManager: coreDataManager)
        return insertNewWeatherdata(coreDataManager: coreDataManager, weatherData: weatherData)
    }
    
    fileprivate func deletePreviousWeatherData(coreDataManager: CoreDataManager) {
        let request = NSFetchRequest<WeatherDay>(entityName: "WeatherDay")
        
        do {
            let weatherDays = try coreDataManager.mainThreadManagedObjectContext.fetch(request)
            
            for weatherDay in weatherDays {
                coreDataManager.mainThreadManagedObjectContext.delete(weatherDay)
            }
            
            coreDataManager.save()
        } catch let error {
            fatalCoreDataError(error)
        }
    }
    
    fileprivate func insertNewWeatherdata(coreDataManager: CoreDataManager, weatherData: JSONWeather) -> [WeatherDay] {
        var weatherDays: [WeatherDay] = []

        if let jsonWeatherDays = weatherData.weatherDay {
            for jsonWeatherDay in jsonWeatherDays {
                weatherDays.append(WeatherDay(context: coreDataManager.mainThreadManagedObjectContext, jsonWeatherDay: jsonWeatherDay))
            }
        }
        
        coreDataManager.save()
        
        return weatherDays
    }
}
