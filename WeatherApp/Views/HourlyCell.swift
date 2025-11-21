//
//  HourlyCell.swift
//  WeatherApp
//
//  Created by Sanya Chandel on 22/11/25.
//

import UIKit

func sfSymbolName(for icon: String) -> String {
    switch icon {
    case "01d": return "sun.max.fill"
    case "01n": return "moon.fill"
    case "02d": return "cloud.sun.fill"
    case "02n": return "cloud.moon.fill"
    case "03d", "03n": return "cloud.fill"
    case "04d", "04n": return "cloud.fill"
    case "09d", "09n": return "cloud.drizzle.fill"
    case "10d": return "cloud.sun.rain.fill"
    case "10n": return "cloud.moon.rain.fill"
    case "11d", "11n": return "cloud.bolt.rain.fill"
    case "13d", "13n": return "cloud.snow.fill"
    case "50d", "50n": return "cloud.fog.fill"
    default: return "questionmark"
    }
}



class HourlyCell: UICollectionViewCell {
    
    @IBOutlet weak var hourLabel: UILabel!
    
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
//    func configure(with model: HourlyWeather) {
//            hourLabel.text = model.hour
//            tempLabel.text = "\(Int(model.temp))°"
//            iconImageView.image = UIImage(named: model.icon) // Use SF Symbols or real images
//        }
    
    // For example, in your cell's configure(with:) method:
    func configure(with model: HourlyWeather) {
        hourLabel.text = model.hour
        tempLabel.text = "\(Int(model.temp))°"
        hourLabel.textColor = .white
            tempLabel.textColor = .white
        
        let symbolName = sfSymbolName(for: model.icon)

        // Use custom palette for each main symbol
        var config: UIImage.SymbolConfiguration?
        switch symbolName {
        case "sun.max.fill": // Sun - yellow
            config = .init(paletteColors: [.systemYellow, .white])
        case "moon.fill": 
            config = .init(paletteColors: [.systemYellow, .white])
        case "cloud.fill": // Cloud - blue
            config = .init(paletteColors: [.systemBlue, .white])
        case "cloud.sun.fill": // Sun above cloud - yellow and blue
            config = .init(paletteColors: [.systemYellow, .systemBlue])
        case "cloud.moon.fill": // Moon above cloud - blue and blue
            config = .init(paletteColors: [.systemBlue, .systemBlue])
        default: // Fallback/default colors for other weather
            config = .init(paletteColors: [.label, .secondaryLabel])
        }

        iconImageView.preferredSymbolConfiguration = config
        iconImageView.image = UIImage(systemName: symbolName)
    }


    
    
    
}
