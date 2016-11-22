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
    @IBOutlet weak var tableView: UITableView!
    
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
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        registerTableViewCell()
    }
    
    // MARK: - Controller custom methods
    fileprivate func registerTableViewCell() {
        let weatherCellNib = UINib(nibName: CellIdentifier.weatherCell, bundle: Bundle.main)
        self.tableView.register(weatherCellNib, forCellReuseIdentifier: CellIdentifier.weatherCell)
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
                
            }
        }
    }
    
    fileprivate func displayError(error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension MainViewController: UITableViewDataSource {
    // MARK: - UITableViewDataSource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nextDaysWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get WeatherCell 
        let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier.weatherCell, for: indexPath) as! WeatherCell
        
        // Get the current day 
        let weatherDay = self.nextDaysWeather[indexPath.row]
        
        // Pass the data to the cell
        cell.configureCell(with: weatherDay)
        
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    // MARK: - UITableViewDelegate methods
    
}

