//
//  CoreDataManager.swift
//  WeatherApp
//
//  Created by Sanya Chandel on 22/11/25.
//
import Foundation
import CoreData
import UIKit

final class CoreDataManager {
    static let shared = CoreDataManager()

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WeatherApp")
        container.loadPersistentStores { desc, error in
            if let error = error { fatalError("CoreData error: \(error)") }
        }
        return container
    }()

    var context: NSManagedObjectContext { persistentContainer.viewContext }

    // Save weather record
    func saveWeather(_ data: WeatherData, for city: String) {
        let entity = NSEntityDescription.entity(forEntityName: "WeatherInfo", in: context)!
        let weather = NSManagedObject(entity: entity, insertInto: context)
        weather.setValue(city, forKey: "cityName")
        weather.setValue(try? JSONEncoder().encode(data), forKey: "weatherJSON")
        weather.setValue(Date(), forKey: "lastUpdated")
        do {
            try context.save()
        } catch {
            print("Failed to save weather: \(error)")
        }
    }

    // Fetch cached weather record
    func fetchWeather(for city: String) -> WeatherData? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "WeatherInfo")
        request.predicate = NSPredicate(format: "cityName == %@", city)
        request.sortDescriptors = [NSSortDescriptor(key: "lastUpdated", ascending: false)]
        request.fetchLimit = 1
        let results = try? context.fetch(request)
        guard
            let entry = results?.first,
            let data = entry.value(forKey: "weatherJSON") as? Data
        else { return nil }
        return try? JSONDecoder().decode(WeatherData.self, from: data)
    }
}

