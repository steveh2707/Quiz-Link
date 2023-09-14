//
//  TriviaManager.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import Foundation
import SwiftUI

class TriviaVM: ObservableObject {
    private(set) var trivia: [Trivia.Result] = []
    @Published private(set) var length = 0
    @Published private(set) var index = 0
    @Published private(set) var reachedEnd = false
    @Published private(set) var answerSelected = false
    @Published private(set) var question: AttributedString = ""
    @Published private(set) var answerChoices: [Answer] = []
    @Published private(set) var progress: CGFloat = 0.00
    @Published private(set) var score = 0
    
    init() {
        Task {
            await fetchTrivia()
        }
    }
    
    func fetchTrivia() async {
        
        
        do {
            // interact with API and assign response to decodedResponse variable
            let decodedResponse = try await NetworkingManager.shared.request(.trivia(amount: 10), type: Trivia.self)
            self.index = 0
            self.score = 0
            self.progress = 0.00
            self.reachedEnd = false
            
            self.trivia = decodedResponse.results
            self.length = self.trivia.count
            self.setQuestion()
                        
        } catch {
            // ignore error from cancellation by user
            if let errorCode = (error as NSError?)?.code, errorCode == NSURLErrorCancelled { return }
            
            // assign any other error to local error variable to be displayed to user
//            self.hasError = true
//            if let networkingError = error as? NetworkingManager.NetworkingError {
//                self.error = networkingError
//            } else {
//                self.error = .custom(error: error)
//            }
            print("Error fetching trivia: \(error)")
        }
    }
    
    func goToNextQuestion() {
        if index + 1 < length {
            index += 1
            setQuestion()
        } else {
            reachedEnd = true
        }
    }
    
    func setQuestion() {
        answerSelected = false
        progress = CGFloat(Double(index+1) / Double(length) * 350)
        
        if index < length {
            let currentTriviaQuesiton = trivia[index]
            question = currentTriviaQuesiton.formattedQuestion
            answerChoices = currentTriviaQuesiton.answers
        }
    }
    
    func selectAnswer(answer: Answer) {
        answerSelected = true
        if answer.isCorrect {
            score += 1
        }
    }
}
