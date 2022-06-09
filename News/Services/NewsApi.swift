

import Foundation
import Combine



class NewsApi {
    
    
    static let shared = NewsApi()
    
    let urlString = "https://newsapi.org/v2/"
    
    var apiKey: String? {
        if let apiKey = ProcessInfo.processInfo.environment["apiKey"] {
            return apiKey
        }
        return nil
    }
    
    func fetch(endpoint: String, pageSize: Int, page: Int = 1, country: String? = nil, q: String? = nil, sources: String? = nil, category: String? = nil, completion: @escaping (Result<[Article], Error>) -> Void) {
        guard let apiKey = apiKey else {
            return completion(.failure(ArticleError.notApiKey))
        }

        var components = URLComponents(string: urlString + endpoint)
        components?.queryItems = [
            URLQueryItem(name: "pageSize", value: String(pageSize)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "apiKey", value: apiKey),
        ]
        
        if let q = q {
            components?.queryItems?.append(URLQueryItem(name: "q", value: q))
        }
        if let country = country {
            components?.queryItems?.append(URLQueryItem(name: "country", value: country))
        }
        
        if let sources = sources {
            components?.queryItems?.append(URLQueryItem(name: "sources", value: sources))
        }
        
        if let category = category {
            components?.queryItems?.append(URLQueryItem(name: "category", value: category))
        }
        
        guard let url = components?.url else {
            return completion(.failure(URLError(.badURL)))
        }
        print(url)
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
                
            }
            
            guard let data = data else {
                completion(.failure(ArticleError.missingData))
                return
            }

            do {
                let respone = try JSONDecoder().decode(Response.self, from: data)
                completion(.success(respone.articles))
            } catch {
                completion(.failure(error))
            }
            
        }.resume()
    }
    
  
    
}

enum ArticleError: Error {
    case notApiKey
    case missingData
}
