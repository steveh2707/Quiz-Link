//
//  GameModels.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import Foundation


let maxRemainingTime = 10
let gameTitle = "Quiz Link"

enum GameType {
    case single, peer, online
    
    var description: String {
        switch self {
        case .single:
            return "Answer quiz questions on your own!"
        case .peer:
            return "Invite someone near you who has this app running to play!"
        case .online:
            return "Play online against anyone in the world!"
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
    var UUIDString: String? = nil
    var players: [Player] = []
    var playerName: String? = nil
    var questionSet: [Trivia.Question] = []
    var answer: Answer? = nil
    
    
    func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
}


enum GKPlayerAuthState: String {
    case authenticating = "Logging in to Game Center..."
    case unauthenticated = "Please sign in to Game Center to play."
    case authenticated = ""
    case error = "There was an error logging into Game Center."
    case restricted = "You're not allowed to play multiplayer games!"
}
