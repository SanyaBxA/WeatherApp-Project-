//
//  WeatherAPI.swift
//  WeatherApp
//
//  Created by Sanya Chandel on 22/11/25.
//

// WeatherAPI.swift
import Foundation

final class WeatherAPI {
    static let shared = WeatherAPI()
    let apiKey = "c898952b540271e34bde3696b0f02db4" // <-- use your real key
    
    func fetch(city: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        
        guard !city.trimmingCharacters(in: .whitespaces).isEmpty else {
                completion(.failure(NSError(domain: "WeatherAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: "City name is missing"])))
                return
            }
        
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "invalidURL", code: 0)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, resp, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "noData", code: 0)))
                return
            }
            do {
                let weatherData = try self.parseWeatherData(data: data)
                completion(.success(weatherData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    
    private func parseWeatherData(data: Data) throws -> WeatherData {
        // 1. Print the raw response for debug
        if let raw = String(data: data, encoding: .utf8) {
            print("Raw API response:\n\(raw)")
        }

        // 2. Try to decode the main response (but handle error JSON too)
        // Attempt to decode error format
        struct APIError: Decodable {
            let cod: String
            let message: String?
        }
        if let apiError = try? JSONDecoder().decode(APIError.self, from: data),
           apiError.cod != "200" {
            throw NSError(domain: "WeatherAPI", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: apiError.message ?? "Unknown API error"])
        }

        // 3. Decode as normal forecast if OK
        let decoded = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)

        // --------- KEEP the rest of your normal mapping code below ----------
        let now = decoded.list.first!
        let current = CurrentWeather(
            temp: now.main.temp,
            description: now.weather.first?.description ?? "",
            high: now.main.temp_max,
            low: now.main.temp_min,
            humidity: now.main.humidity,
            pressure: now.main.pressure,
            icon: now.weather.first?.icon ?? "01d",
            windSpeed: now.wind.speed   // <-- Use now.wind.speed
        )



        let hourly = decoded.list.prefix(8).enumerated().map { (index, item) in
            let hour = index == 0 ? "Now" : String(item.dt_txt.split(separator: " ")[1].prefix(5))
            return HourlyWeather(
                hour: hour,
                temp: item.main.temp,
                icon: item.weather.first?.icon ?? "01d"
            )
        }

        var dailyDict: [String: [OpenWeatherListItem]] = [:]
        for item in decoded.list {
            let day = String(item.dt_txt.split(separator: " ")[0])
            dailyDict[day, default: []].append(item)
        }
        let dailyTuples = Array(dailyDict)
            .sorted { $0.key < $1.key }
            .prefix(7)
        let daily: [DailyWeather] = dailyTuples.compactMap { (day, items) in
            guard let first = items.first else { return nil }
            let temps = items.map { $0.main.temp }
            let minTemp = temps.min() ?? first.main.temp
            let maxTemp = temps.max() ?? first.main.temp
            let icon = first.weather.first?.icon ?? "01d"
            return DailyWeather(
                day: dayOfWeek(from: day),
                minTemp: minTemp,
                maxTemp: maxTemp,
                icon: icon
            )
        }

        return WeatherData(
            cityName: decoded.city.name,
            current: current,
            hourly: hourly,
            daily: daily
        )
    }

}
