//
//  TriviaManager.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import Foundation
import SwiftUI

@MainActor
class TriviaVM: ObservableObject {
    @Published var gameType: GameType = .single
    @Published var player1: Player
    @Published var player2 = Player(name: "Player 2")
    @Published var host: Bool = false
    
    private(set) var yourName: String
    private(set) var trivia: [Trivia.Question] = []
    @Published private(set) var length = 0
    @Published private(set) var index = 0
    @Published private(set) var reachedEnd = false
    @Published private(set) var question: AttributedString = ""
    @Published private(set) var answerChoices: [Answer] = []
    @Published private(set) var progress: CGFloat = 0.00
    
    
    init(yourName: String) {
        player1 = Player(name: yourName)
        self.yourName = yourName
    }
    
    private func simpleReset() {
        self.trivia = []
        self.length = 0
        self.index = 0
        self.reachedEnd = false
        self.question = ""
        self.answerChoices = []
        self.progress = 0.00
    }

    func reset() {
        simpleReset()
        self.player1.score = 0
        self.player1.answer = nil
        self.player2.score = 0
        self.player2.answer = nil
    }
    
    func endGame() {
        simpleReset()
        self.player1 = Player(name: yourName)
        self.player2 = Player(name: "Player 2")
    }
    
    
    func fetchTrivia() async {
        do {
            // interact with API and assign response to decodedResponse variable
            let decodedResponse = try await NetworkingManager.shared.request(.trivia(amount: 10), type: Trivia.self)

            
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
    
    func setTrivia(questions: [Trivia.Question]) {
        self.trivia = questions
        self.length = self.trivia.count
        self.setQuestion()
    }
    
    func goToNextQuestion() {
        if index + 1 < length {
            index += 1
            setQuestion()
        } else {
            reachedEnd = true
        }
    }
    
    private func setQuestion() {
        player1.answer = nil
        player2.answer = nil
        progress = CGFloat(Double(index+1) / Double(length) * 350)
        
        if index < length {
            let currentTriviaQuesiton = trivia[index]
            question = currentTriviaQuesiton.formattedQuestion
            answerChoices = currentTriviaQuesiton.answers
        }
    }
    
    func selectAnswer(answer: Answer) {
//        answerSelected = true
        if player1.name == yourName {
            player1.answer = answer
            if answer.isCorrect {
                player1.score += 1
            }
        } else {
            player2.answer = answer
            if answer.isCorrect {
                player2.score += 1
            }
        }
        
//        player1.answer = answer
//        if answer.isCorrect {
//            player1.score += 1
//        }
    }
    
    func setOpponentAnswer(answer: Answer) {
        if player1.name == yourName {
            player2.answer = answer
            if answer.isCorrect {
                player2.score += 1
            }
        } else {
            player1.answer = answer
            if answer.isCorrect {
                player1.score += 1
            }
        }
        
        
        
//        player2.answer = answer
//        if answer.isCorrect {
//            player2.score += 1
//        }
    }
}
