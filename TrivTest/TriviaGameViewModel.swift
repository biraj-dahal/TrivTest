//
//  TriviaGameViewModel.swift
//  TrivTest
//
//  Created by Biraj Dahal on 2/28/25.
//

import SwiftUI

class TriviaGameViewModel: ObservableObject {
    @Published var questions: [TriviaQuestion] = []
    @Published var userAnswers: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var score = 0
    
    private let triviaService = TriviaService()
    
    func loadQuestions(amount: Int, category: Int, difficulty: String, type: String) {
        isLoading = true
        errorMessage = nil
        
        triviaService.fetchTrivia(amount: amount, category: category, difficulty: difficulty, type: type) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let questions):
                    self?.questions = questions
                    self?.userAnswers = Array(repeating: "", count: questions.count)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func selectAnswer(questionIndex: Int, answer: String) -> Bool {
        if questionIndex < userAnswers.count {
            userAnswers[questionIndex] = answer
            return questions[questionIndex].correctAnswer == answer
        }
        return false
    }
    
    func submitAnswers() -> Int {
        score = 0
        
        for (index, question) in questions.enumerated() {
            if index < userAnswers.count && userAnswers[index] == question.correctAnswer {
                score += 1
            }
        }
        
        return score
    }
}
