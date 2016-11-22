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
import Gloss

enum APIClientError: Error {
    case requestFailed
    case dataCorrupted
    case emptyData
    case localDataCorrupted
    
    var errorDescription: String {
        switch self {
        case .requestFailed:
            return "Cannot get data from the server, please retry later"
        case .dataCorrupted:
            return "Data from the server is corrupted, please retry later"
        case .emptyData:
            return "No data has been retrieved from the server"
        case .localDataCorrupted:
            return "Local data corrupted"
        }
    }
}

class APIClient {
    
    static let API_KEY = "e43ee41f2412bd9bee1c4315fe76902c"
    static let WEATHER_URL: String = {
        return "http://api.openweathermap.org/data/2.5/forecast?q=Paris&mode=json&appid=\(API_KEY)"
    }()
    
    func getWeather(_ completion: @escaping (Error?, [[WeatherInfo]]?) -> ()) {
        let queue = DispatchQueue(label: "com.kersuzan.parisweather.response-queue", qos: .utility, attributes: [.concurrent])
        
        // Check if network is reachable
        if ApplicationManager.getInstance.networkIsReachable {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            Alamofire.request(APIClient.WEATHER_URL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON(queue: queue, options: JSONSerialization.ReadingOptions.allowFragments, completionHandler: { (response) in
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                switch response.result {
                case .success:
                    // We can create new WeatherDay object
                    guard let jsonValue = response.result.value as? JSON else {
                        completion(APIClientError.dataCorrupted, nil)
                        break
                    }
                    
                    // Check if json can be converted to an array of weatherInfo
                    guard let jsonWeather = JSONWeather(json: jsonValue), let _ = jsonWeather.weatherDay else {
                        completion(APIClientError.emptyData, nil)
                        break
                    }
                    
                    // We got the data, we can now perform sync into local database
                    do {
                        let weatherInfos = try self.refreshLocalWeatherData(weatherData: jsonWeather)
                        
                        let groupedWeatherInfos = self.groupWeatherInfoByDay(weatherInfos: weatherInfos)
                        
                        // At this point, we have no error and can give back the data to the completion block
                        completion(nil, groupedWeatherInfos)
                    } catch let error as APIClientError {
                        // We give the error to the completion block
                        completion(error, nil)
                    } catch let error {
                        completion(error, nil)
                    }
                case .failure:
                    completion(APIClientError.requestFailed, nil)
                }
                
            })
        } else {
            // User has no access to the network
            // Grab local data in the database
            do {
                let weatherInfos = try self.getLocalWeatherData()
                let groupedWeatherInfos = groupWeatherInfoByDay(weatherInfos: weatherInfos)
                
                completion(nil, groupedWeatherInfos)

            } catch let error as APIClientError {
                // We give the error to the completion block
                completion(error, nil)
            } catch let error {
                completion(error, nil)
            }
        }
    }
    
    fileprivate func getLocalWeatherData() throws -> [WeatherInfo] {
        guard let coreDataManager = ApplicationManager.getInstance.coreDataManager else {
            throw APIClientError.localDataCorrupted
        }
        
        let request = NSFetchRequest<WeatherInfo>(entityName: "WeatherInfo")
        let dateSort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [dateSort]
        
        do {
            return try coreDataManager.mainThreadManagedObjectContext.fetch(request)
        } catch _ {
            throw APIClientError.localDataCorrupted
        }
    }
    
    fileprivate func refreshLocalWeatherData(weatherData: JSONWeather) throws -> [WeatherInfo] {
        guard let coreDataManager = ApplicationManager.getInstance.coreDataManager else {
            throw APIClientError.localDataCorrupted
        }
        
        try deletePreviousWeatherData(coreDataManager: coreDataManager)
        return insertNewWeatherdata(coreDataManager: coreDataManager, weatherData: weatherData)
    }
    
    fileprivate func deletePreviousWeatherData(coreDataManager: CoreDataManager) throws {
        let request = NSFetchRequest<WeatherInfo>(entityName: "WeatherInfo")
        
        do {
            let weatherInfos = try coreDataManager.mainThreadManagedObjectContext.fetch(request)
            
            for weatherInfo in weatherInfos {
                coreDataManager.mainThreadManagedObjectContext.delete(weatherInfo)
            }
            
            coreDataManager.save()
        } catch _ {
            throw APIClientError.localDataCorrupted
        }
    }
    
    fileprivate func insertNewWeatherdata(coreDataManager: CoreDataManager, weatherData: JSONWeather) -> [WeatherInfo] {
        var weatherInfos: [WeatherInfo] = []

        if let jsonWeatherInfos = weatherData.weatherDay {
            for jsonWeatherInfo in jsonWeatherInfos {
                weatherInfos.append(WeatherInfo(context: coreDataManager.mainThreadManagedObjectContext, jsonWeatherInfo: jsonWeatherInfo))
            }
        }
        
        coreDataManager.save()
        
        return weatherInfos
    }
    
    fileprivate func groupWeatherInfoByDay(weatherInfos: [WeatherInfo]) -> [[WeatherInfo]] {
        // Final array to return
        var arrayToReturn: [[WeatherInfo]] = []
        
        // Array of WeatherInfo of the same day
        var weatherInfoByDate: [WeatherInfo] = []
        var currentDay: Int = 0
        
        let calendar = Calendar.current

        
        
        for info in weatherInfos {
            guard let infoDate = info.date else {
                // We cannot get date, so we continue the loop
                continue
            }
            
            let dateComponents = calendar.dateComponents([.day], from: infoDate as Date)
            
            guard let infoDay = dateComponents.day else {
                // Cannot get the day of the infoDate, continue the loop
                continue
            }
            
            if infoDay != currentDay {
                // We have a new date, we append the subarray weatherInfoByDate into arrayToReturn
                // only if subarray weatherInfoByDate is not empty
                if weatherInfoByDate.count > 0 {
                    arrayToReturn.append(weatherInfoByDate)
                }
                
                // We can empty weatherInfoByDate
                weatherInfoByDate = []
                
                
            }
            
            // We append the new info into the subarray
            weatherInfoByDate.append(info)
            
            // We store the new current day
            currentDay = infoDay
        }
        
        // We append the last subarray into the arrayToReturn
        arrayToReturn.append(weatherInfoByDate)
        
        // We return all the element grouped by day
        return arrayToReturn
    }
}
