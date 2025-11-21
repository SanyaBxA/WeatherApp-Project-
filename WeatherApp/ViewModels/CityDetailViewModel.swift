//
//  CityDetailViewModel.swift
//  WeatherApp
//
//  Created by Sanya Chandel on 22/11/25.
//
// CityDetailViewModel.swift
import Foundation

final class CityDetailViewModel {
    let cityName: String
    var weatherData: WeatherData?

    init(cityName: String) {
        self.cityName = cityName
    }

    func fetchWeather(completion: @escaping (Result<WeatherData, Error>) -> Void) {
        WeatherAPI.shared.fetch(city: cityName) { result in
            switch result {
            case .success(let data):
                self.weatherData = data
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func refreshWeather(completion: @escaping (Result<WeatherData, Error>) -> Void) {
        fetchWeather(completion: completion)
    }
}



//currently 
