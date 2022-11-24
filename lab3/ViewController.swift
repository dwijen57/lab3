//
//  ViewController.swift
//  lab3
//
//  Created by DWIJEN RATHOD on 2022-11-20.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var weatherConditionImage: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!

    @IBOutlet weak var segment: UISegmentedControl!
    var c = ""
    var f = ""
    
    @IBOutlet weak var locationLabel: UILabel!
    var celcius = ""
    var farenheit = ""
    
    private let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchTextField.delegate = self
        
        locationManager.delegate = self
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.endEditing(true)
        loadWeather(search: searchTextField.text)
        return true
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got Location")
        if let location = locations.last{
            let coordinates = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            
            print(coordinates)
            
//            getURL(query: "(\(latitude),\(longitude))")
            loadWeather(search: coordinates)
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print (error)
    }
        
        
    
    
    @IBAction func onLocationTapped(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    
    @IBAction func onSearchTapped(_ sender: UIButton) {
        loadWeather(search: searchTextField.text)
        
        
    }
    
    @IBAction func change(_ sender: UISegmentedControl) {
        if(segment.selectedSegmentIndex == 0){
           temperatureLabel.text = c
        }
        else if(segment.selectedSegmentIndex == 1){
            self.temperatureLabel.text = f
        }
        else{
            temperatureLabel.text = c
        }
        
    }
    
    
    private func loadWeather(search: String?){
        guard let search = search else{
            return
        }
        guard let url = getURL(query: search) else{
            print("Could not get URL")
            return
        }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) { data, response, error in
            print("Network call complete")
            
            guard error == nil else{
                print("Received error")
                return
            }
            
            guard let data = data else{
                print("No data found")
                return
            }
            
            if let weatherResponse = self.parseJson(data: data){
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                print(weatherResponse.current.temp_f)
                
                DispatchQueue.main.async {
                    
                    self.locationLabel.text = weatherResponse.location.name
                    
                    self.c = "\(weatherResponse.current.temp_c)C"
                    self.f = "\(weatherResponse.current.temp_f)F"

                    if(self.segment.selectedSegmentIndex == 0){
                        self.temperatureLabel.text = "\(weatherResponse.current.temp_c)C"
                    }
                    else if(self.segment.selectedSegmentIndex == 1){
                        self.temperatureLabel.text = "\(weatherResponse.current.temp_f)F"
                    }
                    else{
                        self.temperatureLabel.text = "\(weatherResponse.current.temp_c)C"
                    }

                    

                    
                    if (weatherResponse.current.condition.code == 1000){
                        self.weatherConditionImage.image = UIImage(systemName: "sun.min")
                    }
                    else if(weatherResponse.current.condition.code == 1003){
                        self.weatherConditionImage.image = UIImage(systemName: "cloud")
                    }
                    else if(weatherResponse.current.condition.code == 1006){
                        self.weatherConditionImage.image = UIImage(systemName: "cloud.fill")
                    }
                    else if(weatherResponse.current.condition.code == 1009){
                        self.weatherConditionImage.image = UIImage(systemName: "")
                    }
                }
            
            }
    
        }
        dataTask.resume()
    }
    
    private func getURL(query: String) -> URL? {
        
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "67ee3f2753b74b88a4f213034222011" 
        
        guard let url = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
           return nil
        }
        print(url)
        return URL(string: url)
    }
    
    
    private func parseJson(data: Data) -> WeatherResponse?{
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        do{
            weather = try decoder.decode(WeatherResponse.self, from: data)
        } catch{
            print("Error decoding")
        }
        return weather
    }
    
    
    
}

struct WeatherResponse: Decodable{
    let location: Location
    let current: Current
}

struct Location: Decodable{
    let name: String
}

struct Current : Decodable{
    let temp_c: Float
    let temp_f: Float
    let condition: Condition
}

struct Condition: Decodable{
    let text: String
    let code: Int
}


