//
//  AddCityViewController.swift
//  WeatherApp
//
//  Created by Sanya Chandel on 25/11/25.
//

import UIKit



struct CitySuggestion: Decodable {
    let city: String
    let country: String
}


class AddCityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noResultsContainer: UIView!
    
    
    var suggestions: [CitySuggestion] = []
       var userCities: [String] = []
       var addCityHandler: ((String) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
                tableView.dataSource = self
                tableView.delegate = self
                searchTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
                noResultsContainer.isHidden = true
                activityIndicator.isHidden = true
        
        // Rounded corners
            searchTextField.layer.cornerRadius = searchTextField.frame.height / 2
            searchTextField.layer.masksToBounds = true

        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.tintColor = .systemGray2
        icon.contentMode = .scaleAspectFit

        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 34, height: 24))
        icon.frame = CGRect(x: 8, y: 2, width: 20, height: 20)
        iconContainer.addSubview(icon)

        // Set as left view
        searchTextField.leftView = iconContainer
        searchTextField.leftViewMode = .always


       
    }
    @objc func textDidChange() {
        noResultsContainer.isHidden = true // Always hide the overlay when typing
        guard let text = searchTextField.text, text.count > 1 else {
            suggestions = []
            tableView.reloadData()
            activityIndicator.isHidden = true // Hide spinner for very short input or clear
            return
        }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        fetchCitySuggestions(query: text) { [weak self] cities in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
                self?.suggestions = cities
                self?.tableView.reloadData()
            }
        }
    }


    
    func fetchCitySuggestions(query: String, completion: @escaping ([CitySuggestion]) -> Void) {
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let urlString = "https://wft-geo-db.p.rapidapi.com/v1/geo/cities?namePrefix=\(encoded)&limit=10"
            guard let url = URL(string: urlString) else { completion([]); return }
            var request = URLRequest(url: url)
            request.setValue("019e58b7b3msh728e7f707d95ed7p1366dcjsnb23505680fd7", forHTTPHeaderField: "X-RapidAPI-Key")
            request.setValue("wft-geo-db.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
            URLSession.shared.dataTask(with: request) { data, _, _ in
                guard let data = data else { completion([]); return }
                struct APIResult: Decodable { struct City: Decodable { let city: String; let country: String }; let data: [City] }
                let decoded = try? JSONDecoder().decode(APIResult.self, from: data)
                let cities = decoded?.data.map { CitySuggestion(city: $0.city, country: $0.country) } ?? []
                completion(cities)
            }.resume()
        }
    
    
    
    // Table view methods
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { suggestions.count }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath)
            let city = suggestions[indexPath.row]
            cell.textLabel?.text = "\(city.city), \(city.country)"
            return cell
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            addCityHandler?(suggestions[indexPath.row].city)
            dismiss(animated: true)
        }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        guard let text = textField.text, !text.isEmpty else { return false }
        // If it matches a suggestion, add
        if let match = suggestions.first(where: { $0.city.lowercased() == text.lowercased() }) {
            addCityHandler?(match.city)
            dismiss(animated: true)
        } else {
            // Validate with WeatherAPI (the real endpoint for checking, e.g., OpenWeather)
            WeatherAPI.shared.fetch(city: text) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self?.addCityHandler?(text)
                        self?.dismiss(animated: true)
                    case .failure(_):
                        self?.noResultsContainer.isHidden = false
                    }
                }
            }
        }
        return true
    }




    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
