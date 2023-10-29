//
//  WeatherView.swift
//  Journals
//
//  Created by Paco Sun on 2023-08-28.
//

import Foundation
import SwiftUI
import CoreLocation

// Data model for mapping OpenWeatherMap JSON
struct WeatherData: Codable {
    var name: String
    let main: Main
    let weather: [Weather]
    
    struct Main: Codable {
        let temp: Double
    }
    
    struct Weather: Codable {
        let main: String
    }
}

// Core Location manager class
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var isLocationReady = false
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        isLocationReady = true
        self.locationManager.stopUpdatingLocation()
    }
}

// SwiftUI view to display weather
struct WeatherView: View {
    @ObservedObject var locationManager: LocationManager
    @State private var loadingError: Bool = false
    @State private var isTranslating: Bool = false
    @Binding private var lastFetchTime: Date?
    @Binding private var weatherData: WeatherData?
    
    // Explicit initializer
    init(locationManager: LocationManager, lastFetchTime: Binding<Date?>, weatherData: Binding<WeatherData?>) {
        self.locationManager = locationManager
        self._lastFetchTime = lastFetchTime
        self._weatherData = weatherData
    }
    
    var body: some View {
        VStack () {
            
            if isTranslating {
                Text("Fetching city name...")
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
            } else if let weatherData = weatherData {
                let roundedCelcius = Int((weatherData.main.temp - 273.15).rounded())
                Text("\(weatherData.name)")
                    .font(.system(size: 18))
                    .fontWeight(.semibold)

                Text("\(roundedCelcius)°C")
                    .font(.system(size: 45))
                    .padding(.bottom, -5)

                if let condition = weatherData.weather.first?.main,
                   let iconView = weatherIcons[condition] {
                    iconView
                } else {
                    // Default icon or text when condition is not found in the dictionary
                    Image(systemName: "questionmark.circle").resizable().frame(width: 40, height: 40)
                }
            } else if loadingError {
                Text("Error fetching weather.\nPlease check system permission.")
                    .font(.system(size: 13))
            } else {
                Text("Loading weather...")
            }
        }
        .onAppear {
            fetchData()
        }
        .onChange(of: locationManager.isLocationReady) { notReady, isReady in
            if isReady {
                fetchData()
            }
        }
    }
    
    private func fetchData() {
        if let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < 3600 {
            // Skip the fetch if it's been less than an hour since the last one
            return
        }

        if let location = locationManager.location {
            fetchWeather(byLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { data in
                if let data = data {
                    self.weatherData = data
                    self.lastFetchTime = Date() // Update the timestamp
                    
                    translateCityName(city: data.name)
                    
                } else {
                    self.loadingError = true
                }
            }
        } else {
            self.loadingError = true
        }
    }
    
    private func translateCityName(city: String) {
        // Read API key
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let googleAPIKey = dict["GoogleKey"] as? String else {
            print("Failed to get Google API key.")
            return
        }
        
        // Prepare URL
        guard let language = (UserDefaults.standard.object(forKey: "AppleLanguages") as? [String])?.first else {
            print("Failed to get language settings.")
            return
        }
        
        // Get target language for translation
        let targetLanguage = (language.components(separatedBy: "-").first ?? "en")
        if targetLanguage == "en" {
            return
        }

        guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
              let url = URL(string: "https://translation.googleapis.com/language/translate/v2?q=\(cityEncoded)&target=\(targetLanguage)&key=\(googleAPIKey)") else {
            print("Failed to create API URL.")
            return
        }
        
        // Make call and handle response
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let translatedText = (((json?["data"] as? [String: Any])?["translations"] as? [[String: Any]])?.first)?["translatedText"] as? String {
                        // Update UI
                        DispatchQueue.main.async {
                            self.weatherData?.name = translatedText
                        }
                    }
                } catch {
                    print("Failed to parse translation response.")
                }
            }
        }.resume()
    }
}
