//
//  ViewController.swift
//  WeatherApp
//
//  Created by Sanya Chandel on 21/11/25.
//

import UIKit

class LandingViewController: UIViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var forecastLabel: UILabel!
    
    @IBOutlet weak var getStartedButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyGradient()
        styleButton()
        styleLabels()
        iconImageView.image = UIImage(named: "weather_icon")
        // Do any additional setup after loading the view.
    }
    
    func applyGradient() {
            let gradient = CAGradientLayer()
        gradient.colors = [
                UIColor(red: 36/255, green: 26/255, blue: 115/255, alpha: 1).cgColor, // Dark blue
                UIColor(red: 112/255, green: 52/255, blue: 157/255, alpha: 1).cgColor // Rich purple
            ]
            gradient.locations = [0, 1]
            gradient.frame = view.bounds
            view.layer.insertSublayer(gradient, at: 0)
        }
    
    func styleButton() {
            getStartedButton.layer.cornerRadius = 24
        getStartedButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)

            getStartedButton.backgroundColor = UIColor.systemYellow
            getStartedButton.setTitleColor(.darkGray, for: .normal)
        }
    
    func styleLabels() {
//            weatherLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
            weatherLabel.textColor = .white
//            forecastLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
            forecastLabel.textColor = .systemYellow
        }
    
    
  
    @IBAction func getStartedTapped(_ sender: UIButton) {
    }
    

}

