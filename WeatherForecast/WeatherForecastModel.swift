//
//  WeatherForecastModel.swift
//  WeatherForecast
//
//  Created by expert on 11/10/22.
//

import Foundation
import Combine
import UIKit
import CoreData

class WeatherForecastModel {
    
    static let shared = WeatherForecastModel()
    static var publisher = CurrentValueSubject<(currentLocationData: Location?, foreCastData: Forecast?)?, Never>(nil)
    var responseData: String?
    
    func checkFordataInPersistance(_ city: String, _ vc: ViewController) {
        DispatchQueue.main.async {
            self.fetch(city, vc)
        }
    }
    
    func triggerWeththerforeCastAPI(_ city: String, _ vc: ViewController) {
        if let url = URL.init(string:  "https://api.weatherapi.com/v1/forecast.json?key=522db6a157a748e2996212343221502&q=\(city)&days=7&aqi=no&alerts=no") {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let session = URLSession.shared
            vc.publisher = WeatherForecastModel.publisher
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                if let parseData = data {
                    do {
                        if let jsonDict = try JSONSerialization.jsonObject(with: parseData, options: .allowFragments) as? [String: Any] {
                            let json = self.getJSONStringForDictionary(dict: jsonDict)
                            print(json)
                            DispatchQueue.main.async {
                           // self.storeData(json)
                            }
                            let utf8data = json.data(using: .utf8)!
                            let modelObject = try JSONDecoder().decode(Welcome.self, from: utf8data)
                            WeatherForecastModel.publisher.send((currentLocationData: modelObject.location, foreCastData: modelObject.forecast))
                            vc.reloadViewsWithPublisher()
                            DispatchQueue.main.async {
                               self.storeData(json)
                            }
                        }
                        
                    } catch {
                        if let error = error as? DecodingError {
                            print(error.localizedDescription)
                        }
                        DispatchQueue.main.async {
                            vc.callApiError()
                        }
                    }
                }else {
                    DispatchQueue.main.async {
                        vc.callApiError()
                    }
                }
            })
            task.resume()
        }
    }
    
    func storeData(_ data: String) {
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext =
        appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
        NSEntityDescription.entity(forEntityName: "ResponseData",
                                   in: managedContext)!
        
        let locationObj = NSManagedObject(entity: entity,
                                       insertInto: managedContext)
        
        locationObj.setValue(data, forKeyPath: "data")
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetch(_ city: String, _ vc: ViewController) {
        //1
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
          NSFetchRequest<NSManagedObject>(entityName: "ResponseData")
        
        //3
        do {
            if let responseData = try managedContext.fetch(fetchRequest).first?.value(forKey: "data") as? String {
                self.responseData = responseData
                guard let utf8data = self.responseData?.data(using: .utf8)! else {
                    DispatchQueue.main.async {
                        vc.callApiError()
                    }
                    return
                }
                do {
                    vc.publisher = WeatherForecastModel.publisher
                    let modelObject = try JSONDecoder().decode(Welcome.self, from: utf8data)
                    WeatherForecastModel.publisher.send((currentLocationData: modelObject.location, foreCastData: modelObject.forecast))
                    vc.reloadViewsWithPublisher()
                    
                }catch {
                    if let error = error as? DecodingError {
                        print(error.localizedDescription)
                    }
                    DispatchQueue.main.async {
                        vc.callApiError()
                    }
                }
            } else {
                triggerWeththerforeCastAPI(city, vc)
            }

        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
      }
    
    func getJSONStringForDictionary(dict:[String:Any]) -> String {
      do {
          let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
          if let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as? String {
          return jsonString
        }
      } catch let error as NSError {
        print(error)
      }
      return ""
    }
    
}

