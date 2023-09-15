//
//  FlickerAPI.swift
//  SwiftUI_43_6_1
//
//  Created by Raman Kozar on 04/06/2023.
//

import Foundation
import Alamofire
import SwiftyJSON

// Custom error-enum
//
enum CustomError: Error {

    // Throw when an expected resource is not found
    case notFound

}

// Main class for Flickr-API
//
class FlickerAPI: ObservableObject {
    
    // Unique API Flickr key
    let apiKey = "4b8874a860faeb848141d8ba511412cd"

    // method for creating URL
    func createRequestURL(text: String) -> URL {
        
        var componentsURL = URLComponents()
        
        componentsURL.scheme = "https"
        componentsURL.host = "api.flickr.com"
        componentsURL.path = "/services/rest"
        componentsURL.queryItems = [URLQueryItem]()
        
        let queryKeyParameter = URLQueryItem(name: "api_key", value: apiKey)
        let queryMethodParameter = URLQueryItem(name: "method", value: "flickr.photos.search")
        let queryFormatParameter = URLQueryItem(name: "format", value: "json")
        let queryTextParameter = URLQueryItem(name: "text", value: text)
        let queryExtraParameter = URLQueryItem(name: "extras", value: "url_l")
        let queryNojsoncallbackParameter = URLQueryItem(name: "nojsoncallback", value: "1")
        let queryPageParameter = URLQueryItem(name: "page", value: "1")

        componentsURL.queryItems!.append(queryKeyParameter)
        componentsURL.queryItems!.append(queryMethodParameter)
        componentsURL.queryItems!.append(queryFormatParameter)
        componentsURL.queryItems!.append(queryTextParameter)
        componentsURL.queryItems!.append(queryExtraParameter)
        componentsURL.queryItems!.append(queryNojsoncallbackParameter)
        componentsURL.queryItems!.append(queryPageParameter)
        
        return componentsURL.url!
        
    }
    
    // method for downloading data
    //
    func downloadDataUsingAPI(_ requestURL: URL, completion: @escaping (_ data: NSDictionary?, _ error: Error?) -> Void) {
        
        AF.request(requestURL).validate().responseJSON { data in
            
            if let json = try? data.result.get() {
                completion(json as? NSDictionary, nil)
            } else {
                completion(nil, CustomError.notFound)
                return
            }
            
        }
        
    }
    
    // method for parse results
    //
    func parsingJSON_DuringSearch(_ searchText: String, _ json: NSDictionary) -> [FlickerObject] {
        
        var imageURLs = [URL]()
        var flickerDataTest = [FlickerObject]()
        
        let finalJSON = JSON(json)
        let photoArray = finalJSON["photos"]["photo"].arrayValue
        
        for count in 0 ..< photoArray.count where imageURLs.count < 1000 {
            
            var flickerTitle = ""
            if photoArray[count]["title"].stringValue.isEmpty {
                flickerTitle = "No title"
            } else {
                flickerTitle = photoArray[count]["title"].stringValue
            }
    
            var flickerHeight = ""
            if !photoArray[count]["height_l"].stringValue.isEmpty {
                flickerHeight = photoArray[count]["height_l"].stringValue
            } else {
                flickerHeight = "0"
            }
            
            var flickerWidth = ""
            if !photoArray[count]["width_l"].stringValue.isEmpty {
                flickerWidth = photoArray[count]["width_l"].stringValue
            } else {
                flickerWidth = "0"
            }
            
            let flickerUrlToImage = photoArray[count]["url_l"].stringValue
            if let currentURL = URL(string: flickerUrlToImage) {
                imageURLs.append(currentURL)
            }
            
            let newFlickerObject = FlickerObject(flickerTitle: flickerTitle, flickerUrlToImage: flickerUrlToImage, flickerHeight: flickerHeight, flickerWidth: flickerWidth)
            
            flickerDataTest.append(newFlickerObject)
            
        }
        
        return flickerDataTest
        
    }
    
    // method for getting data for View
    //
    func getArrayOfData(searchText: String, completion: @escaping (_ arr: [FlickerObject]) -> Void) {
        
        //let searchText = "Steve Jobs"
        let requestURL = FlickerAPI().createRequestURL(text: searchText)
        
        FlickerAPI().downloadDataUsingAPI(requestURL) { json, error in
            
            guard let json = json else {
                
                print("failed to download data from Flickr, error: \(String(describing: error?.localizedDescription))")
                return
                
            }
            
            let arrOfData = FlickerAPI().parsingJSON_DuringSearch(searchText, json)
            completion(arrOfData)
        
        }
    
    }

}

// For each error type return the appropriate description
extension CustomError: CustomStringConvertible {
   
    public var description: String {
        switch self {
        case .notFound:
            return "The specified item could not be found."
        }
    }
    
}

// For each error type return the appropriate localized description
extension CustomError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .notFound:
            return NSLocalizedString(
                "The specified item could not be found.",
                comment: "Resource Not Found"
            )
        }
        
    }
    
}
