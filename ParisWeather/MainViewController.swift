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
    
    fileprivate struct Segue {
        static let detail = "DetailVC"
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Controller variables
    var applicationManager: ApplicationManager? {
        didSet {
            if isViewLoaded {
                getWeather()
            }
        }
    }

    var nextWeatherInfos: [[WeatherInfo]] = []
    var activityIndicatorView: UIActivityIndicatorView?
    
    // MARK: - Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        if applicationManager != nil {
            getWeather()
        }
        
        registerTableViewCell()
    }
    
    // MARK: - Controller custom methods
    fileprivate func registerTableViewCell() {
        let weatherCellNib = UINib(nibName: CellIdentifier.weatherCell, bundle: Bundle.main)
        self.tableView.register(weatherCellNib, forCellReuseIdentifier: CellIdentifier.weatherCell)
    }
    
    fileprivate func getWeather() {
        startActivityIndicatorView()
        
        self.applicationManager?.apiClient.getWeather { (error: Error?, weatherInfos: [[WeatherInfo]]?) in
            DispatchQueue.main.async { [weak self] in
                if let strongSelf = self {
                    strongSelf.stopActivityIndicatorView()
                    
                    if error != nil {
                        strongSelf.displayError(error: error!)
                        return
                    }
                    
                    guard let weatherInfos = weatherInfos, weatherInfos.count > 0 else {
                        return
                    }
                    
                    strongSelf.nextWeatherInfos = weatherInfos
                    strongSelf.tableView.reloadData()

                }
            }
        }
    }
    
    fileprivate func startActivityIndicatorView() {
        // Adds activityIndicatorView into the navigation bar
        if self.activityIndicatorView == nil {
            self.activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            self.activityIndicatorView!.activityIndicatorViewStyle = .gray
            let barButton = UIBarButtonItem(customView: self.activityIndicatorView!)
            self.navigationItem.setRightBarButton(barButton, animated: true)
        }
        
        self.activityIndicatorView!.startAnimating()
    }
    
    fileprivate func stopActivityIndicatorView() {
        // Stop and remove activityIndicatorView from the navigation bar
        if self.activityIndicatorView != nil {
            self.activityIndicatorView!.stopAnimating()
            
            self.navigationItem.setRightBarButton(nil, animated: true)
            self.activityIndicatorView = nil
        }
    }
    
    fileprivate func displayError(error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.detail {
            if let destinationVC = segue.destination as? DetailViewController, let weatherDay = sender as? [WeatherInfo] {
                destinationVC.weatherDay = weatherDay
            }
        }
    }
}

extension MainViewController: UITableViewDataSource {
    // MARK: - UITableViewDataSource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nextWeatherInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get WeatherCell 
        let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier.weatherCell, for: indexPath) as! WeatherCell
        
        // Get the current day (which contains an array of weather info of the day) 
        let weatherDayInfos = self.nextWeatherInfos[indexPath.row]
        
        // Pass the data to the cell
        cell.configureCell(with: weatherDayInfos)
        
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    // MARK: - UITableViewDelegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        
        let weatherDay: [WeatherInfo] = self.nextWeatherInfos[indexPath.row]
        
        performSegue(withIdentifier: Segue.detail, sender: weatherDay)
    }
}

