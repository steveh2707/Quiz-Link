//
//  MPGameMove.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import Foundation

struct MPGameMove: Codable {
    enum Action: Int, Codable {
        case start, move, next, end
    }
    
    let action: Action
    var playerName: String? = nil
    var questionSet: [Trivia.Question] = []
    var answer: Answer? = nil
    
    
    func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
