//
//  WeatherCell.swift
//  ParisWeather
//
//  Created by Kersuzan on 17/11/2016.
//  Copyright © 2016 com.kersuzan. All rights reserved.
//

import UIKit

class WeatherCell: UICollectionViewCell {

    // MARK: Static 
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short
        
        return dateFormatter
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
    func configureCell(with weather: WeatherDay) {
        if let date = weather.date as? Date {
            self.dateLabel.text = WeatherCell.dateFormatter.string(from: date)
        }
        
        if let icon = weather.icon {
            self.weatherImageView.image = UIImage(named: icon)
        }
        
        self.tempMinLabel.text = "\(Int(weather.tempMin))˚K"
        self.tempMaxLabel.text = "\(Int(weather.tempMax))˚K"
    }
}
