//
//  TriviaGameView.swift
//  TrivTest
//
//  Created by Biraj Dahal on 2/28/25.
//

import SwiftUI

struct TriviaGameView: View {
    @ObservedObject var viewModel: TriviaGameViewModel
    @State private var showingResults = false
    @State private var timeRemaining = 60 
    @State private var timer: Timer? = nil
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading Questions...")
            } else if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                    
                    Button("Go Back") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                }
            } else {
                VStack {
                    Text("Time Remaining: \(timeRemaining) seconds")
                        .font(.headline)
                        .foregroundColor(timeRemaining < 10 ? .red : .primary)
                        .padding()
                    
                    List {
                        ForEach(Array(viewModel.questions.enumerated()), id: \.element.id) { index, question in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Question \(index + 1):")
                                    .font(.headline)
                                
                                Text(question.question.decodedHTML())
                                    .font(.body)
                                    .padding(.bottom, 5)
                                
                                Text("Category: \(question.category)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("Difficulty: \(question.difficulty.capitalized)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 10)
                                
                                ForEach(question.allAnswers, id: \.self) { answer in
                                    Button(action: {
                                        viewModel.selectAnswer(questionIndex: index, answer: answer)
                                    }) {
                                        HStack {
                                            Text(answer.decodedHTML())
                                                .font(.body)
                                            
                                            Spacer()
                                            
                                            if showingResults {
                                                if answer == question.correctAnswer {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.green)
                                                } else if viewModel.userAnswers[index] == answer {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.red)
                                                }
                                            } else if index < viewModel.userAnswers.count && viewModel.userAnswers[index] == answer {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    answerBackgroundColor(for: answer, at: index),
                                                    lineWidth: 1
                                                )
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .disabled(showingResults)
                                    .padding(.vertical, 2)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                    
                    Button(action: {
                        let _ = viewModel.submitAnswers()
                        showingResults = true
                        timer?.invalidate()
                    }) {
                        Text("Submit Answers")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                    .disabled(viewModel.userAnswers.contains("") || showingResults)
                }
                .alert(isPresented: $showingResults) {
                    Alert(
                        title: Text("Trivia Results"),
                        message: Text("Your score: \(viewModel.score) out of \(viewModel.questions.count)"),
                        dismissButton: .default(Text("OK")) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                }
            }
        }
        .navigationTitle("Trivia Challenge")
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    func answerBackgroundColor(for answer: String, at index: Int) -> Color {
        if !showingResults {
            return index < viewModel.userAnswers.count && viewModel.userAnswers[index] == answer ? .blue : .gray
        } else {
            if answer == viewModel.questions[index].correctAnswer {
                return .green
            } else if viewModel.userAnswers[index] == answer {
                return .red
            } else {
                return .gray
            }
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                let _ = viewModel.submitAnswers()
                showingResults = true
            }
        }
    }
}
