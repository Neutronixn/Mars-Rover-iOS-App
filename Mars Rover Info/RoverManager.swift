//
//  RoverManager.swift
//  Mars Rover Info
//
//  Created by Vision on 10/10/24.
//

import Foundation

struct MarsPhoto: Codable {
    let id: Int
    let sol: Int
    let camera: Camera
    let imgSrc: String
    let earthDate: String
    
    enum CodingKeys: String, CodingKey {
        case id, sol, camera
        case imgSrc = "img_src"
        case earthDate = "earth_date"
    }
}

struct Camera: Codable {
    let name: String
    let fullName: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case fullName = "full_name"
    }
}

class MarsRoverAPI {
    static let shared = MarsRoverAPI()
    private let baseURL = "https://api.nasa.gov/mars-photos/api/v1/rovers/"
    private let apiKey = "nF15nUDjYaQxNWhyANQ4ObFt87Lh6HSUdqruPX6K"  // Replace with your NASA API key
    
    func fetchPhotos(rover: String, sol: Int, camera: String? = nil, completion: @escaping ([MarsPhoto]?, Error?) -> Void) {
        var urlString = "\(baseURL)\(rover)/photos?sol=\(sol)&api_key=\(apiKey)"
        if let camera = camera {
            urlString += "&camera=\(camera)"
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data received", code: 0, userInfo: nil))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(PhotosResponse.self, from: data)
                completion(result.photos, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}

struct PhotosResponse: Codable {
    let photos: [MarsPhoto]
}
