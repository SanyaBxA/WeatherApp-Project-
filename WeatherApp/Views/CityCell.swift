//
//  CityCell.swift
//  WeatherApp
//
//  Created by Sanya Chandel on 22/11/25.
//

import UIKit

class CityCell: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var highLowLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    override func layoutSubviews() {
            super.layoutSubviews()

            // Set background to clear (ensures gradient is visible)
        self.backgroundColor = .clear
                contentView.backgroundColor = .clear
                cardView.backgroundColor = .clear
        
            // Set card corner radius (always enforced)
            cardView.layer.cornerRadius = 20
            cardView.layer.masksToBounds = true
        
        cardView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
            let gradient = CAGradientLayer()
            gradient.colors = [
                UIColor(red: 36/255, green: 26/255, blue: 115/255, alpha: 1).cgColor,   // Dark blue
                UIColor(red: 112/255, green: 52/255, blue: 157/255, alpha: 1).cgColor   // Rich purple
            ]
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            gradient.frame = cardView.bounds
            gradient.cornerRadius = 20
            cardView.layer.insertSublayer(gradient, at: 0)
        }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
