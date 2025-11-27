//
//  WeatherModels.swift
//  WeatherApp
//
//  Created by Sanya Chandel on 22/11/25.
//
// WeatherModels.swift

//checking

import Foundation

struct WeatherData: Codable {
    let cityName: String
    let current: CurrentWeather
    let hourly: [HourlyWeather]
    let daily: [DailyWeather]
}

struct CurrentWeather: Codable {
    let temp: Double
    let description: String
    let high: Double
    let low: Double
    let humidity: Double
    let pressure: Double
    let icon: String
    let windSpeed: Double
}

struct HourlyWeather: Codable {
    let hour: String      // Example: "13:00"
    let temp: Double
    let icon: String
}

struct DailyWeather: Codable {
    let day: String       // Example: "Mon"
    let minTemp: Double
    let maxTemp: Double
    let icon: String
}

struct Wind: Decodable {
    let speed: Double
}

struct OpenWeatherListItem: Decodable {
    let dt: TimeInterval
    let main: OpenWeatherMain
    let weather: [OpenWeatherWeather]
    let dt_txt: String
    let wind: Wind  // <-- ADD THIS LINE
}


struct OpenWeatherMain: Decodable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
    let humidity: Double    // <-- CHANGE TO Double
    let pressure: Double 
}

struct OpenWeatherWeather: Decodable {
    let description: String
    let icon: String
}

struct OpenWeatherResponse: Decodable {
    let city: OpenWeatherCity
    let list: [OpenWeatherListItem]
}

struct OpenWeatherCity: Decodable {
    let name: String
}

// Utility for day-of-week
func dayOfWeek(from dateString: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    if let date = formatter.date(from: dateString) {
        formatter.dateFormat = "EEE"
        return formatter.string(from: date) // "Mon", "Tue", etc.
    }
    return dateString
}
