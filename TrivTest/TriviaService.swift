//
//  TriviaService.swift
//  TrivTest
//
//  Created by Biraj Dahal on 2/28/25.
//

import Foundation

class TriviaService {
    func fetchCategories(completion: @escaping (Result<[TriviaCategory], Error>) -> Void) {
            let url = URL(string: "https://opentdb.com/api_category.php")!
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "No data received", code: -2, userInfo: nil)))
                    return
                }
                
                do {
                    let categoryResponse = try JSONDecoder().decode(CategoryResponse.self, from: data)
                    completion(.success(categoryResponse.triviaCategories))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    
    func fetchTrivia(amount: Int, category: Int, difficulty: String, type: String, completion: @escaping (Result<[TriviaQuestion], Error>) -> Void) {
            let baseURL = "https://opentdb.com/api.php"
            let urlString = "\(baseURL)?amount=\(amount)&category=\(category)&difficulty=\(difficulty)&type=\(type)"
            
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "No data received", code: -2, userInfo: nil)))
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
                    completion(.success(decodedResponse.results))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
}
