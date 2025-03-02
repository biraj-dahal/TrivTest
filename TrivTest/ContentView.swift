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
    @State private var isGameActive = false
    
    @State private var categories: [TriviaCategory] = []
    @State private var isLoadingCategories = true
    @State private var categoryError: String? = nil
    
    let triviaService = TriviaService()
    let difficulties = ["easy", "medium", "hard"]
    let types = [("multiple", "Multiple Choice"), ("boolean", "True / False")]
    
    private var isFormValid: Bool {
        return selectedCategory != nil && selectedDifficulty != nil && selectedType != nil
    }
    
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "1a2a6c"), Color(hex: "b21f1f"), Color(hex: "fdbb2d")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                    .opacity(0.1)
                
                VStack(spacing: 0) {
                    headerView
                    
                    scrollContent
                }
            }
            .navigationTitle("Trivia Master")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Trivia Master")
                        .font(.title3.bold())
                        .foregroundColor(Color(hex: "1a2a6c"))
                }
            }
            .onAppear {
                loadCategories()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 5) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 50))
                .foregroundColor(Color(hex: "1a2a6c"))
                .padding(.top, 20)
            
            Text("Configure Your Game")
                .font(.title2.bold())
                .foregroundColor(Color(hex: "1a2a6c"))
            
            Text("Customize your trivia challenge")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.5))
    }
    
    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Questions Counter
                configCard(title: "Number of Questions", systemImage: "number.circle.fill") {
                    VStack(spacing: 10) {
                        Text("\(numberOfQuestions)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(hex: "1a2a6c"))
                            .frame(maxWidth: .infinity)
                        
                        Slider(value: Binding(
                            get: { Double(numberOfQuestions) },
                            set: { numberOfQuestions = Int($0) }
                        ), in: 1...50, step: 1)
                        .accentColor(Color(hex: "1a2a6c"))
                        
                        Text("1 question minimum, 50 maximum")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 5)
                }
                
                // Category Selection
                configCard(title: "Category", systemImage: "folder.fill") {
                    if isLoadingCategories {
                        HStack {
                            Spacer()
                            ProgressView("Loading categories...")
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "1a2a6c")))
                            Spacer()
                        }
                    } else if let error = categoryError {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .font(.subheadline)
                    } else {
                        categoryPicker
                    }
                }
                
                // Difficulty Selection
                configCard(title: "Difficulty", systemImage: "chart.bar.fill") {
                    difficultyPicker
                }
                
                // Question Type Selection
                configCard(title: "Question Type", systemImage: "questionmark.circle.fill") {
                    typePicker
                }
                
                // Start Game Button
                startGameButton
                    .padding(.vertical, 20)
            }
            .padding()
        }
    }
    
    private var categoryPicker: some View {
        Menu {
            ForEach(categories) { category in
                Button(action: {
                    selectedCategory = category.id
                }) {
                    HStack {
                        Text(category.name)
                        if selectedCategory == category.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(categories.first(where: { $0.id == selectedCategory })?.name ?? "Select a category")
                    .foregroundColor(selectedCategory == nil ? .secondary : .primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .foregroundColor(.primary)
    }
    
    private var difficultyPicker: some View {
        VStack(spacing: 10) {
            HStack {
                ForEach(difficulties, id: \.self) { difficulty in
                    difficultyButton(difficulty)
                }
            }
            
            Text(selectedDifficulty == nil ? "Select a difficulty level" : "Selected: \(selectedDifficulty?.capitalized ?? "")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func difficultyButton(_ difficulty: String) -> some View {
        let isSelected = selectedDifficulty == difficulty
        
        let difficultyColor: Color = {
            switch difficulty {
            case "easy": return Color(hex: "4caf50")
            case "medium": return Color(hex: "ff9800")
            case "hard": return Color(hex: "f44336")
            default: return .gray
            }
        }()
        
        return Button(action: {
            selectedDifficulty = difficulty
        }) {
            VStack {
                Image(systemName: {
                    switch difficulty {
                    case "easy": return "tortoise.fill"
                    case "medium": return "hare.fill"
                    case "hard": return "flame.fill"
                    default: return "questionmark"
                    }
                }())
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .white : difficultyColor)
                
                Text(difficulty.capitalized)
                    .font(.caption.bold())
                    .foregroundColor(isSelected ? .white : difficultyColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? difficultyColor : Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    private var typePicker: some View {
        VStack(spacing: 10) {
            HStack {
                ForEach(types, id: \.0) { type in
                    typeButton(type)
                }
            }
            
            Text(selectedType == nil ? "Select a question type" : "Selected: \(types.first(where: { $0.0 == selectedType })?.1 ?? "")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func typeButton(_ type: (String, String)) -> some View {
        let isSelected = selectedType == type.0
        
        return Button(action: {
            selectedType = type.0
        }) {
            VStack {
                Image(systemName: type.0 == "multiple" ? "list.bullet" : "arrow.left.arrow.right")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : Color(hex: "1a2a6c"))
                
                Text(type.1)
                    .font(.caption.bold())
                    .foregroundColor(isSelected ? .white : Color(hex: "1a2a6c"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color(hex: "1a2a6c") : Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    private var startGameButton: some View {
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
            isActive: $isGameActive
        ) {
            HStack {
                Image(systemName: "play.fill")
                Text("Start Trivia Game")
                    .fontWeight(.bold)
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 40)
            .background(
                isFormValid ?
                LinearGradient(gradient: Gradient(colors: [Color(hex: "1a2a6c"), Color(hex: "4361ee")]), startPoint: .leading, endPoint: .trailing) :
                LinearGradient(gradient: Gradient(colors: [Color.gray]), startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(25)
            .shadow(color: isFormValid ? Color(hex: "1a2a6c").opacity(0.3) : Color.clear, radius: 10, x: 0, y: 5)
        }
        .disabled(!isFormValid)
        .onTapGesture {
            if isFormValid {
                isGameActive = true
            }
        }
    }
    
    private func configCard<Content: View>(title: String, systemImage: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "1a2a6c"))
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(hex: "1a2a6c"))
            }
            
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
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
                    print("Error fetching categories: \(error.localizedDescription). Using fallback categories.")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}


