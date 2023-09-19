//
//  TriviaManager.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import Foundation
import SwiftUI
import MultipeerConnectivity
import GameKit

@MainActor
class GameVM: NSObject, ObservableObject {
    @Published var gameType: GameType = .single
    @Published var players: [Player]
    @Published var host: Bool = false
    
    @Published var startGame: Bool = false
    
    private(set) var yourName: String
    private(set) var trivia: [Trivia.Question] = []
    @Published private(set) var length = 0
    @Published private(set) var index = 0
    @Published private(set) var reachedEnd = false
    @Published private(set) var question: AttributedString = ""
    @Published private(set) var answerChoices: [Answer] = []
    @Published private(set) var progress: CGFloat = 0.00
    @Published var remainingTime = maxRemainingTime
    
    let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    @Published var playing: Bool = false
    
    // MultpeerConnectivity set up
    let serviceType = String.serviceName
    let session: MCSession
    let myPeerId: MCPeerID
    let nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    let nearbyServiceBrowser: MCNearbyServiceBrowser
    
    @Published var availablePeers: [MCPeerID] = []
    @Published var receivedInvite: Bool = false
    @Published var receivedInviteFrom: MCPeerID?
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?
    @Published var paired: Bool = false

    // Game Centre set up
    @Published var authenticationState = GKPlayerAuthState.authenticating
    
    var match: GKMatch?
    var otherPlayers: [GKPlayer] = []
    var localPlayer = GKLocalPlayer.local
    var playerUUIDKey = UUID().uuidString
    
    
    init(yourName: String) {
        self.players = [Player(name: yourName)]
        self.yourName = yourName
        
        // MultpeerConnectivity
        myPeerId = MCPeerID(displayName: yourName)
        session = MCSession(peer: myPeerId)
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        super.init()
        session.delegate = self
        nearbyServiceAdvertiser.delegate = self
        nearbyServiceBrowser.delegate = self
    }
    
    private func simpleReset() {
        self.trivia = []
        self.length = 0
        self.index = 0
        self.reachedEnd = false
        self.question = ""
        self.answerChoices = []
        self.progress = 0.00
        self.remainingTime = maxRemainingTime
    }

    func reset() {
        self.simpleReset()
        for i in 0..<players.count {
            players[i].score = 0
            players[i].answer = nil
        }
    }
    
    func endGame() {
        self.simpleReset()
        players.removeSubrange(1..<players.count)
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
        for i in 0..<players.count {
            players[i].answer = nil
        }
        progress = CGFloat(Double(index+1) / Double(length) * 350)
        
        if index < length {
            remainingTime = maxRemainingTime
            let currentTriviaQuesiton = trivia[index]
            question = currentTriviaQuesiton.formattedQuestion
            answerChoices = currentTriviaQuesiton.answers
        }
    }
    
    func selectAnswer(index: Int, answer: Answer) {
        
        players[index].answer = answer
        if answer.isCorrect {
            players[index].score += 1
        }
    }
    
    
    func findIndexOfPlayer(name: String) -> Int {
        for (i, player) in players.enumerated() {
            if player.name == name {
                return i
            }
        }
        return -1
    }
    
    var allPlayersAnswered: Bool {
        var allAnswered = true
        for player in players {
            if player.answer == nil {
                allAnswered = false
            }
        }
        return allAnswered
    }

}
