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
    
    // MARK: - Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    // MARK: - Controller custom methods
    fileprivate func registerCollectionViewCell() {
        let weatherCellNib = UINib(nibName: CellIdentifier.weatherCell, bundle: Bundle.main)
        self.collectionView.register(weatherCellNib, forCellWithReuseIdentifier: CellIdentifier.weatherCell)
    }
}

extension MainViewController: UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.weatherCell, for: indexPath) as! WeatherCell
        
        cell.configureCell(with: Weather())
        
        return cell
    }
}

extension MainViewController: UICollectionViewDelegate {
    // MARK: - UICollectionViewDelegate methods
    
    
}

