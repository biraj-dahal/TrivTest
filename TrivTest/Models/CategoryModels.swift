//
//  CategoryModels.swift
//  TrivTest
//
//  Created by Biraj Dahal on 2/28/25.
//


struct CategoryResponse: Codable {
    let triviaCategories: [TriviaCategory]
    
    enum CodingKeys: String, CodingKey {
        case triviaCategories = "trivia_categories"
    }
}

struct TriviaCategory: Codable, Identifiable {
    let id: Int
    let name: String
}
