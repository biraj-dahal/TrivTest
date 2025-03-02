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
    @State private var timeRemaining: Int
    @State private var timer: Timer? = nil
    @Environment(\.presentationMode) var presentationMode
    
    init(viewModel: TriviaGameViewModel, timeLimit: Int = 60) {
            self.viewModel = viewModel
            _timeRemaining = State(initialValue: timeLimit)
        }
    
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "1a2a6c"), Color(hex: "b21f1f"), Color(hex: "fdbb2d")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
                .opacity(0.15)
                
            if viewModel.isLoading {
                LoadingView()
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(errorMessage: errorMessage, presentationMode: presentationMode)
            } else {
                gameContentView
            }
        }
        .navigationTitle("Trivia Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Trivia Challenge")
                    .font(.headline.bold())
                    .foregroundColor(Color(hex: "1a2a6c"))
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var gameContentView: some View {
        VStack(spacing: 0) {
            timerView
                .padding(.horizontal)
                
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(Array(viewModel.questions.enumerated()), id: \.element.id) { index, question in
                        QuestionCardView(
                            index: index,
                            question: question,
                            userAnswer: index < viewModel.userAnswers.count ? viewModel.userAnswers[index] : "",
                            onAnswerSelected: { answer in
                                let _ = viewModel.selectAnswer(questionIndex: index, answer: answer)
                            }
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            
            submitButton
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
    
    private var timerView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(timeRemaining < 10 ? .red : Color(hex: "1a2a6c"))
                    .font(.system(size: 18, weight: .bold))
                
                ProgressView(value: Double(timeRemaining), total: 60)
                    .progressViewStyle(LinearProgressViewStyle(tint: timeRemaining < 10 ? .red : Color(hex: "1a2a6c")))
                    .frame(height: 8)
                
                Text("\(timeRemaining)s")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(timeRemaining < 10 ? .red : Color(hex: "1a2a6c"))
                    .frame(width: 40)
            }
            .padding()
        }
        .frame(height: 60)
        .padding(.vertical, 10)
    }
    
    private var submitButton: some View {
        Button(action: {
            let _ = viewModel.submitAnswers()
            showingResults = true
            timer?.invalidate()
        }) {
            Text("Submit Answers")
                .font(.headline.bold())
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "1a2a6c"), Color(hex: "4361ee")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .padding()
        .disabled(viewModel.userAnswers.contains("") || showingResults)
        .opacity(viewModel.userAnswers.contains("") || showingResults ? 0.6 : 1)
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

struct QuestionCardView: View {
    let index: Int
    let question: TriviaQuestion
    let userAnswer: String
    let onAnswerSelected: (String) -> Void
    
    private var difficultyColor: Color {
        switch question.difficulty {
        case "easy":
            return Color(hex: "4caf50")  // Green
        case "medium":
            return Color(hex: "ff9800")  // Orange
        case "hard":
            return Color(hex: "f44336")  // Red
        default:
            return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Question \(index + 1)")
                    .font(.headline.bold())
                    .foregroundColor(Color(hex: "1a2a6c"))
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(question.difficulty.capitalized)
                        .font(.footnote.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(difficultyColor)
                        .cornerRadius(12)
                    
                    Text(question.category.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespaces) ?? question.category)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Text(question.question.decodedHTML())
                .font(.body)
                .fontWeight(.medium)
                .padding(.vertical, 5)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(spacing: 8) {
                ForEach(question.allAnswers, id: \.self) { answer in
                    AnswerButton(
                        answer: answer.decodedHTML(),
                        isSelected: userAnswer == answer,
                        isCorrect: answer == question.correctAnswer,
                        isAnswered: !userAnswer.isEmpty,
                        action: {
                            onAnswerSelected(answer)
                        }
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct AnswerButton: View {
    let answer: String
    let isSelected: Bool
    let isCorrect: Bool
    let isAnswered: Bool
    let action: () -> Void
    
    private var backgroundColor: Color {
        if isAnswered {
            if isSelected {
                return isCorrect ? Color(hex: "4caf50").opacity(0.2) : Color(hex: "f44336").opacity(0.2)
            } else if isCorrect {
                return Color(hex: "4caf50").opacity(0.2)
            } else {
                return Color.gray.opacity(0.1)
            }
        } else {
            return Color.gray.opacity(0.1)
        }
    }
    
    private var borderColor: Color {
        if isAnswered {
            if isSelected {
                return isCorrect ? Color(hex: "4caf50") : Color(hex: "f44336")
            } else if isCorrect {
                return Color(hex: "4caf50")
            } else {
                return Color.gray.opacity(0.3)
            }
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(answer)
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? (isCorrect ? Color(hex: "4caf50") : Color(hex: "f44336")) : .primary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 10)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                if isAnswered {
                    if isSelected {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isCorrect ? Color(hex: "4caf50") : Color(hex: "f44336"))
                            .font(.system(size: 18))
                    } else if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "4caf50"))
                            .font(.system(size: 18))
                    }
                }
            }
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isAnswered)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "1a2a6c")))
            
            Text("Loading Questions...")
                .font(.headline)
                .foregroundColor(Color(hex: "1a2a6c"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.9))
    }
}

struct ErrorView: View {
    let errorMessage: String
    let presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.title2.bold())
                .foregroundColor(.red)
            
            Text(errorMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Go Back") {
                presentationMode.wrappedValue.dismiss()
            }
            .font(.headline)
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding()
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: 
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
