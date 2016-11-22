//
//  WeatherCell.swift
//  ParisWeather
//
//  Created by Kersuzan on 17/11/2016.
//  Copyright © 2016 com.kersuzan. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {

    // MARK: Static 
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short
        
        return dateFormatter
    }()
    
    private static let timeFormatter: DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
        
        return timeFormatter
    }()
    
    // MARK: - WeatherCell outlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var tempMinLabel: UILabel!
    @IBOutlet weak var tempMaxLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - WeatherCell custom methods
    
    // Configure cell for mainView
    func configureCell(with weatherDay: [WeatherInfo]) {
        // Check for the max temp of the day
        let maxTemperatures = weatherDay.flatMap({ $0.tempMax })
        if let maxTemp = maxTemperatures.max() {
            self.tempMaxLabel.text = "\(Int(maxTemp))"
        }
        
        // Check for the minx temp of the day
        let minTemperatures = weatherDay.flatMap({ $0.tempMin })
        if let minTemp = minTemperatures.min() {
            self.tempMinLabel.text = "\(Int(minTemp))"
        }
        
        // For the date, we simply get the date from the first element
        if let date = weatherDay.first?.date {
            self.dateLabel.text = WeatherCell.dateFormatter.string(from: date)
        }

        // For the icon, we use the icon of the midelement
        let midElementIndex = Int(round(Double(weatherDay.count / 2)))
        if let icon = weatherDay[midElementIndex].icon {
            self.weatherImageView.image = UIImage(named: icon)
        }
    }
    
    // Configure cell for detailView
    func configureCell(withInfo weatherInfo: WeatherInfo) {
        if let date = weatherInfo.date {
            self.dateLabel.text = WeatherCell.timeFormatter.string(from: date)
        }
        
        if let icon = weatherInfo.icon {
            self.weatherImageView.image = UIImage(named: icon)
        }
        
        self.tempMaxLabel.text = "\(Int(weatherInfo.tempMax))"
        self.tempMinLabel.text = "\(Int(weatherInfo.tempMin))"
    }
}
