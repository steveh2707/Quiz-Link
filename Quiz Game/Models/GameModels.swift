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
