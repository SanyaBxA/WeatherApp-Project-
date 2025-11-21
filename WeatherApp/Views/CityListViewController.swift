//
//  CityListViewController.swift
//  WeatherApp
//
//  Created by Sanya Chandel on 22/11/25.
//


import UIKit

class CityListViewController: UITableViewController {
    let viewModel = CityListViewModel()
    
    // Add: Cache for weather data
        var cityWeather: [String: WeatherData] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(didTapRefreshAllCities))

        
        tableView.backgroundColor = .black
//        let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
//        headerContainer.backgroundColor = .clear
//
//        let titleLabel = UILabel()
//        titleLabel.text = "Pick a city!"
//        titleLabel.font = UIFont.boldSystemFont(ofSize: 36)
//        titleLabel.textColor = .white
//
//        let plusButton = UIButton(type: .system)
//        plusButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
//        plusButton.tintColor = .white
//        plusButton.addTarget(self, action: #selector(didTapAddCity), for: .touchUpInside)
//
//        let stack = UIStackView(arrangedSubviews: [titleLabel, plusButton])
//        stack.axis = .horizontal
//        stack.alignment = .center
//        stack.distribution = .equalSpacing
//        stack.spacing = 12
//
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        headerContainer.addSubview(stack)
//        NSLayoutConstraint.activate([
//            stack.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
//            stack.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20),
//            stack.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 8),
//            stack.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -8)
//        ])
//
//        tableView.tableHeaderView = headerContainer

        // Create the label
        let titleLabel = UILabel()
        titleLabel.text = "Pick a city!"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textColor = .white

        // Create the plus button
        let plusButton = UIButton(type: .system)
        plusButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        plusButton.tintColor = .white
        plusButton.addTarget(self, action: #selector(didTapAddCity), for: .touchUpInside)

        // Horizontal stack for layout
        let stack = UIStackView(arrangedSubviews: [titleLabel, plusButton])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center

        navigationItem.titleView = stack

        // Keep your refresh button on the right as it is
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(didTapRefreshAllCities))

        tableView.backgroundColor = .black

        fetchWeatherForAllCities()

        
        fetchWeatherForAllCities()


    }
    
    // Fetch weather data for all cities in the list
        func fetchWeatherForAllCities() {
            for city in viewModel.cities {
                WeatherAPI.shared.fetch(city: city) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let weather):
                            self?.cityWeather[city] = weather
                            self?.tableView.reloadData()
                        case .failure(_):
                            break
                        }
                    }
                }
            }
        }
    @objc func didTapAddCity() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddCityViewController") as! AddCityViewController
        vc.userCities = viewModel.cities
        vc.addCityHandler = { [weak self] cityName in
            guard let self = self else { return }
            if self.viewModel.addCity(cityName) {
                // Immediately fetch and store weather for new city!
                WeatherAPI.shared.fetch(city: cityName) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let weather):
                            self?.cityWeather[cityName] = weather
                        default:
                            break // leave blank if API failed
                        }
                        self?.tableView.reloadData() // Always reload after API result
                    }
                }
                self.tableView.reloadData() // Optional: instant feedback while loading
            }
        }
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true)
    }
    
    @objc func didTapRefreshAllCities() {
        fetchWeatherForAllCities()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.cities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as! CityCell
            let city = viewModel.cityName(at: indexPath.row)
            cell.cityLabel.text = city
            cell.selectionStyle = .none

            // Fetch data for temp/high/low/description
            if let weather = cityWeather[city] {
                cell.tempLabel.text = "\(Int(weather.current.temp))°"
                cell.highLowLabel.text = "H: \(Int(weather.current.high))°  L: \(Int(weather.current.low))°"
                cell.descriptionLabel.text = weather.current.description.capitalized
            } else {
                cell.tempLabel.text = "--"
                cell.highLowLabel.text = ""
                cell.descriptionLabel.text = ""
            }
            return cell
        }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        125
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Instantiate the detail view controller from the storyboard by its Storyboard ID
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "CityDetailViewController") as! CityDetailViewController
        // Pass the correct city name using your ViewModel
        detailVC.cityName = viewModel.cityName(at: indexPath.row)
        // Push the detail view controller onto the navigation stack
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.removeCity(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }


}
