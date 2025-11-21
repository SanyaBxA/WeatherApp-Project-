//
//  WeatherInfo+CoreDataProperties.swift
//  WeatherApp
//
//  Created by Sanya Chandel on 21/11/25.
//
//

import Foundation
import CoreData

extension WeatherInfo {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherInfo> {
        return NSFetchRequest<WeatherInfo>(entityName: "WeatherInfo")
    }
    
    @NSManaged public var cityName: String?
    @NSManaged public var temperature: Double
    @NSManaged public var highTemp: Double
    @NSManaged public var lowTemp: Double
    @NSManaged public var weatherDescription: String?
    @NSManaged public var humidity: Double
    @NSManaged public var pressure: Double
    @NSManaged public var windSpeed: Double
    @NSManaged public var iconName: String?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var weatherJSON: Data?

}

extension WeatherInfo: Identifiable { }



