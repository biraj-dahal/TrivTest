//
//  ContentView.swift
//  TrivTest
//
//  Created by Biraj Dahal on 2/27/25.
//
import SwiftUI

struct ContentView: View {
    @State private var numberOfQuestions = 10
    @State private var selectedCategory: Int?
    @State private var selectedDifficulty: String?
    @State private var selectedType: String?
    
    @State private var categories: [TriviaCategory] = []
    @State private var isLoadingCategories = true
    @State private var categoryError: String? = nil
    
    let triviaService = TriviaService()
    let difficulties = ["easy", "medium", "hard"]
    let types = [("multiple", "Multiple Choice"), ("boolean", "True / False")]
    
    // Computed properties to determine if form is valid
    private var isFormValid: Bool {
        return selectedCategory != nil && selectedDifficulty != nil && selectedType != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Number of Questions")) {
                    Stepper("\(numberOfQuestions) questions", value: $numberOfQuestions, in: 1...50)
                }
                
                Section(header: Text("Category")) {
                    if isLoadingCategories {
                        HStack {
                            Spacer()
                            ProgressView("Loading categories...")
                            Spacer()
                        }
                    } else if let error = categoryError {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                    } else {
                        Picker("Select Category", selection: $selectedCategory) {
                            Text("Select a category").tag(nil as Int?)
                            ForEach(categories) { category in
                                Text(category.name).tag(category.id as Int?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Section(header: Text("Difficulty")) {
                    Picker("Select Difficulty", selection: $selectedDifficulty) {
                        Text("Select difficulty").tag(nil as String?)
                        ForEach(difficulties, id: \.self) { difficulty in
                            Text(difficulty.capitalized).tag(difficulty as String?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Question Type")) {
                    Picker("Select Type", selection: $selectedType) {
                        Text("Select question type").tag(nil as String?)
                        ForEach(types, id: \.0) { type in
                            Text(type.1).tag(type.0 as String?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section {
                    NavigationLink(
                        destination: TriviaGameView(
                            viewModel: {
                                let vm = TriviaGameViewModel()
                                if let category = selectedCategory,
                                   let difficulty = selectedDifficulty,
                                   let type = selectedType {
                                    vm.loadQuestions(
                                        amount: numberOfQuestions,
                                        category: category,
                                        difficulty: difficulty,
                                        type: type
                                    )
                                }
                                return vm
                            }()
                        ),
                        isActive: .constant(isFormValid)
                    ) {
                        Text("Start Trivia Game")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(isFormValid ? .blue : .gray)
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Trivia Options")
            .onAppear {
                loadCategories()
            }
        }
    }
    
    private func loadCategories() {
        isLoadingCategories = true
        categoryError = nil
        
        triviaService.fetchCategories { result in
            DispatchQueue.main.async {
                isLoadingCategories = false
                
                switch result {
                case .success(let fetchedCategories):
                    self.categories = fetchedCategories
                case .failure(let error):
                    self.categoryError = error.localizedDescription
                    // Optionally add fallback categories
                    self.categories = [
                        TriviaCategory(id: 9, name: "General Knowledge"),
                        TriviaCategory(id: 18, name: "Science: Computers"),
                        TriviaCategory(id: 22, name: "Geography")
                    ]
                    print("Error fetching categories: \(error.localizedDescription). Using fallback categories.")
                }
            }
        }
    }
}
#Preview {
    ContentView()
}
