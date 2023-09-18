//
//  GameModels.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import Foundation

enum GameType {
    case single, peer, undetermined
    
    var description: String {
        switch self {
        case .single:
            return "Answer quiz questions on your own."
        case .peer:
            return "Invite someone near you who has this app running to play"
        case .undetermined:
            return ""
        }
    }
}


struct Answer: Identifiable, Codable, Equatable {
    var id = UUID()
    var text: AttributedString
    var isCorrect: Bool
}


struct Player: Identifiable, Codable {
    var id: UUID { UUID() }
    var name: String
    var score: Int = 0
    var isHost: Bool = false
    var answer: Answer? = nil
}


struct MPGameMove: Codable {
    enum Action: Int, Codable {
        case start, questions, move, next, reset, end
    }
    
    let action: Action
    var players: [Player] = []
    var playerName: String? = nil
    var questionSet: [Trivia.Question] = []
    var answer: Answer? = nil
    
    
    func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
}

let maxRemainingTime = 10
