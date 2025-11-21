//
//  WeeklyCell.swift
//  WeatherApp
//
//  Created by Sanya Chandel on 22/11/25.
//

import UIKit



class WeeklyCell: UITableViewCell {

    
    @IBOutlet weak var dayLabel: UILabel!
    
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    
    @IBOutlet weak var minTempLabel: UILabel!
    
    @IBOutlet weak var maxTempLabel: UILabel!
    
    
//    func configure(with model: DailyWeather) {
//            dayLabel.text = model.day
//            minTempLabel.text = "\(Int(model.minTemp))°"
//            maxTempLabel.text = "\(Int(model.maxTemp))°"
//            iconImageView.image = UIImage(named: model.icon) // Use SF Symbols or real images
//        }
    
    func configure(with model: DailyWeather) {
        dayLabel.text = model.day
        minTempLabel.text = "\(Int(model.minTemp))°"
        maxTempLabel.text = "\(Int(model.maxTemp))°"
        dayLabel.textColor = .white
            minTempLabel.textColor = .white
            maxTempLabel.textColor = .white
        let symbolName = sfSymbolName(for: model.icon)
        
            
        // Custom color palette for weekly weather icons
        var config: UIImage.SymbolConfiguration?
        switch symbolName {
        case "sun.max.fill":
            config = .init(paletteColors: [.systemYellow, .white])
        case "moon.fill":
            config = .init(paletteColors: [.systemYellow, .white])
        case "cloud.fill":
            config = .init(paletteColors: [.systemBlue, .white])
        case "cloud.sun.fill":
            config = .init(paletteColors: [.systemYellow, .systemBlue])
        case "cloud.moon.fill":
            config = .init(paletteColors: [.systemBlue, .systemBlue])
        default:
            config = .init(paletteColors: [.label, .secondaryLabel])
        }
        iconImageView.preferredSymbolConfiguration = config
        iconImageView.image = UIImage(systemName: symbolName)
    }



}
