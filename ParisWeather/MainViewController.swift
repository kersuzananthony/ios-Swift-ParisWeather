//
//  MainViewController.swift
//  ParisWeather
//
//  Created by Kersuzan on 17/11/2016.
//  Copyright © 2016 com.kersuzan. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    // MARK: - Statics member
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .long
        
        return dateFormatter
    }()
    
    // MARK: - Storyboard
    fileprivate struct CellIdentifier {
        static let weatherCell = "WeatherCell"
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Controller variables
    var applicationManager: ApplicationManager? {
        didSet {
            getWeather()
        }
    }
    var todayWeather: WeatherDay?
    var nextDaysWeather: [WeatherDay] = []
    
    // MARK: - Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        registerCollectionViewCell()
    }
    
    // MARK: - Controller custom methods
    fileprivate func registerCollectionViewCell() {
        let weatherCellNib = UINib(nibName: CellIdentifier.weatherCell, bundle: Bundle.main)
        self.collectionView.register(weatherCellNib, forCellWithReuseIdentifier: CellIdentifier.weatherCell)
    }
    
    fileprivate func getWeather() {
        self.applicationManager?.apiClient.getWeather { (error: Error?, weatherDays: [WeatherDay]) in
            DispatchQueue.main.async {
                if error != nil {
                    self.displayError(error: error!)
                    return
                }
                
                // Check if weatherDays length is greater than 1
                if weatherDays.count < 1 {
                    return
                }
                
                var weathersToSplit = weatherDays // We make a copy of it in order to split the data
                
                self.todayWeather = weathersToSplit.first
                weathersToSplit.removeFirst()
                self.nextDaysWeather = weathersToSplit
                
                self.updateUI()
            }
        }
    }
    
    fileprivate func updateUI() {
        if let todayWeather = self.todayWeather {
            self.temperatureLabel.text = "\(todayWeather.tempDay)˚C"
            
            if let date = todayWeather.date as? Date {
                self.dateLabel.text = MainViewController.dateFormatter.string(from: date)
            }
            
            if let iconName = todayWeather.icon {
                self.weatherImageView.image = UIImage(named: iconName)
            }
        }
        
        self.collectionView.reloadData()
    }
    
    fileprivate func displayError(error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension MainViewController: UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.nextDaysWeather.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.weatherCell, for: indexPath) as! WeatherCell
        
        let currentWeather = self.nextDaysWeather[indexPath.row]
        
        cell.configureCell(with: currentWeather)
        
        return cell
    }
}

extension MainViewController: UICollectionViewDelegate {
    // MARK: - UICollectionViewDelegate methods
    
    
}

