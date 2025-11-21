//
//  CityListViewModel.swift
//  WeatherApp
//
//  Created by Sanya Chandel on 22/11/25.
//

import Foundation

final class CityListViewModel {
    var cities: [String]
    
    init(cities: [String] = [
        "Mumbai", "Delhi", "Bengaluru", "Chennai", "Kolkata",
        "Pune", "Jaipur", "Agra", "Lucknow", "Kanpur"
    ]) {
        self.cities = cities
    }
    
    func numberOfCities() -> Int {
        return cities.count
    }

    func cityName(at index: Int) -> String {
        return cities[index]
    }
    func addCity(_ city: String) -> Bool {
        // Lowercase check to prevent duplicates of any case variant
        let lowercasedCity = city.lowercased()
        let existing = cities.map { $0.lowercased() }
        if existing.contains(lowercasedCity) {
            return false      // Do not add, already present
        }
        cities.append(city)
        return true           // Added successfully
    }

    
    func removeCity(at index: Int) {
            cities.remove(at: index)
        }
    
}
