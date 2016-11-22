//
//  DetailViewController.swift
//  ParisWeather
//
//  Created by Kersuzan on 22/11/2016.
//  Copyright © 2016 com.kersuzan. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // MARK: - Storyboard
    fileprivate struct CellIdentifier {
        static let weatherCell = "WeatherCell"
    }
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Controller variables
    var weatherDay: [WeatherInfo]?
    private lazy var dateFormatter: DateFormatter = {
       let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short
        
        return dateFormatter
    }()
    
    // MARK: - Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        registerTableViewCell()
        
        // Set the title to the date of weatherDay
        guard let firstWeatherInfo = self.weatherDay?.first, let firstWeatherDate = firstWeatherInfo.date else {
            return
        }
        
        self.title = self.dateFormatter.string(from: firstWeatherDate)
    }
    
    // MARK: - Controller customs methods
    fileprivate func registerTableViewCell() {
        let cellNib = UINib(nibName: CellIdentifier.weatherCell, bundle: Bundle.main)
        self.tableView.register(cellNib, forCellReuseIdentifier: CellIdentifier.weatherCell)
    }
}

extension DetailViewController: UITableViewDataSource {
    // MARK: - UITableViewDataSource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.weatherDay?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier.weatherCell, for: indexPath) as! WeatherCell
        
        if let weatherInfo = self.weatherDay?[indexPath.row] {
            cell.configureCell(withInfo: weatherInfo)
        }
        
        return cell
    }
}

extension DetailViewController: UITableViewDelegate {
    // MARK: - UITableViewDelegate methods
}



