//
//  CityDetailViewController.swift
//  WeatherApp
//
//  Created by Sanya Chandel on 22/11/25.
//

import UIKit
import CoreData

class CityDetailViewController: UIViewController {

    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    @IBOutlet weak var weeklyTableView: UITableView!
    @IBOutlet weak var hourlySectionView: UIView!
    @IBOutlet weak var weeklySectionView: UIView!
    
    
    // This will be set before showing this controller (by the list screen)
        var cityName: String = "London"  // default, but is replaced on navigation
        var weatherData: WeatherData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMainBackgroundGradient()
        view.addSubview(loadingLabel)
        NSLayoutConstraint.activate([
            loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        styleWeeklySectionCard()
        hourlyCollectionView.dataSource = self
        weeklyTableView.dataSource = self
        weeklyTableView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .refresh, target: self, action: #selector(didTapRefresh))
            loadOrFetchWeather(for: cityName)
        
        weeklyTableView.contentInsetAdjustmentBehavior = .never
        
        weeklyTableView.contentInset = .zero
        weeklyTableView.scrollIndicatorInsets = .zero
        
        weeklyTableView.tableHeaderView = nil


    }
    
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .white
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    
    func loadOrFetchWeather(for city: String) {
        loadingLabel.isHidden = false

        if let savedInfo = fetchWeatherInfoFromCoreData(for: city),
           let json = savedInfo.weatherJSON,
           let decoded = try? JSONDecoder().decode(WeatherData.self, from: json) {
            // VALID cached, display from local data
            self.weatherData = decoded
            updateUI(with: decoded)
        } else {
            // No object at all, OR object with no JSON blob (first time, or incomplete) — force API fetch!
            fetchWeatherFromAPIAndSave(city: city)
        }

    }
    
    
    func fetchWeatherFromAPIAndSave(city: String) {
        WeatherAPI.shared.fetch(city: city) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.weatherData = data
                    self?.updateUI(with: data)
                    self?.saveWeatherDataToCoreData(data) // Save entire object as JSON
                case .failure(let error):
                    print("Error fetching weather:", error)
                }
            }
        }
    }


        // Core Data logic: fetch saved city info
        func fetchWeatherInfoFromCoreData(for city: String) -> WeatherInfo? {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
            let context = appDelegate.persistentContainer.viewContext
            let request: NSFetchRequest<WeatherInfo> = WeatherInfo.fetchRequest()
            request.predicate = NSPredicate(format: "cityName == %@", city)
            return try? context.fetch(request).first
        }
    
    
    // Converts WeatherInfo (Core Data) back to your WeatherData model
    func convertCoreDataToWeatherData(_ info: WeatherInfo) -> WeatherData {
        return WeatherData(
            cityName: info.cityName ?? "",
            current: CurrentWeather(
                temp: info.temperature,
                description: info.weatherDescription ?? "",
                high: info.highTemp,
                low: info.lowTemp,
                humidity: info.humidity,
                pressure: info.pressure,
                icon: info.iconName ?? "01d",
                windSpeed: info.windSpeed     // <-- ADD this line
            ),


            hourly: [],
            daily: []
        )
    }
    
  
    
    @objc func didTapRefresh() {
        fetchWeatherFromAPIAndSave(city: cityName) // Always call API, then update and re-save Core Data
    }


        // UI update code (existing from your app)
        func updateUI(with data: WeatherData) {
            loadingLabel.isHidden = true

            cityNameLabel.text = data.cityName
            temperatureLabel.text = "\(Int(data.current.temp))°"
            descriptionLabel.text = data.current.description
            highTempLabel.text = "H: \(Int(data.current.high))°"
            lowTempLabel.text = "L: \(Int(data.current.low))°"
            cityNameLabel.textColor = .white
            temperatureLabel.textColor = .white
            descriptionLabel.textColor = .white
            highTempLabel.textColor = .white
            lowTempLabel.textColor = .white
            hourlyCollectionView.reloadData()
            weeklyTableView.reloadData()
        }
    
    func saveWeatherDataToCoreData(_ data: WeatherData) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        // Check if city exists
        let request: NSFetchRequest<WeatherInfo> = WeatherInfo.fetchRequest()
        request.predicate = NSPredicate(format: "cityName == %@", data.cityName)
        let results = try? context.fetch(request)

        let info = results?.first ?? WeatherInfo(context: context)
        info.cityName = data.cityName
        info.temperature = data.current.temp
        info.highTemp = data.current.high
        info.lowTemp = data.current.low
        info.weatherDescription = data.current.description
        info.humidity = data.current.humidity
        info.pressure = data.current.pressure
        info.windSpeed = data.current.windSpeed
        info.iconName = data.current.icon
        info.lastUpdated = Date()

        // Save all data as JSON for easy decoding later
        if let encoded = try? JSONEncoder().encode(data) {
            info.weatherJSON = encoded
        }
        try? context.save()
    }


    func addMainBackgroundGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 36/255, green: 26/255, blue: 115/255, alpha: 1).cgColor, // Dark blue (#241A73)
            UIColor(red: 112/255, green: 52/255, blue: 157/255, alpha: 1).cgColor // Rich purple (#70349D)
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    func styleSectionCard(_ view: UIView, top: UIColor, bottom: UIColor) {
        // Remove any previous gradients
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        let gradient = CAGradientLayer()
        gradient.colors = [top.cgColor, bottom.cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.frame = view.bounds
        gradient.cornerRadius = 18
        view.layer.insertSublayer(gradient, at: 0)

        view.layer.cornerRadius = 18
        view.clipsToBounds = false

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.24
        view.layer.shadowRadius = 18
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
    }
    
    
    func styleWeeklySectionCard() {
        // Remove old gradients if any
        weeklySectionView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 120/255, green: 60/255, blue: 200/255, alpha: 0.90).cgColor,   // Deep purple
            UIColor(red: 170/255, green: 120/255, blue: 230/255, alpha: 0.94).cgColor   // Lighter violet
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = weeklySectionView.bounds
        gradient.cornerRadius = 22
        weeklySectionView.layer.insertSublayer(gradient, at: 0)

        weeklySectionView.layer.cornerRadius = 22
        weeklySectionView.clipsToBounds = false
        weeklySectionView.layer.shadowColor = UIColor.black.cgColor
        weeklySectionView.layer.shadowOpacity = 0.18
        weeklySectionView.layer.shadowRadius = 18
        weeklySectionView.layer.shadowOffset = CGSize(width: 0, height: 8)
    }



    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        styleSectionCard(
            hourlySectionView,
            top: UIColor(red: 90/255, green: 92/255, blue: 204/255, alpha: 0.88), // deep blue-purple
            bottom: UIColor(red: 136/255, green: 84/255, blue: 186/255, alpha: 0.93) // purple
        )
        styleSectionCard(
            weeklySectionView,
            top: UIColor(red: 93/255, green: 64/255, blue: 156/255, alpha: 0.90), // slightly different purple
            bottom: UIColor(red: 146/255, green: 107/255, blue: 191/255, alpha: 0.91) // blend to pastel
        )
    }
    
    }


    
// MARK: - UICollectionViewDataSource for hourly forecast
extension CityDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherData?.hourly.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as! HourlyCell
        if let model = weatherData?.hourly[indexPath.item] {
            cell.configure(with: model)
        }
        return cell
    }
}


// MARK: - UITableViewDataSource for daily forecast
extension CityDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData?.daily.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklyCell", for: indexPath) as! WeeklyCell
        if let model = weatherData?.daily[indexPath.row] {
            cell.configure(with: model)
        }
        return cell
    }
}


// MARK: - UITableViewDelegate for daily forecast
extension CityDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 36}
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return 0 }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { return UIView() }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 0 }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { return nil }

   
  
}
