//
//  GCConnectionManager.swift
//  Quiz Game
//
//  Created by Steve on 19/09/2023.
//

import Foundation
import GameKit

@MainActor
class GKConnectionManager: NSObject, ObservableObject {
    @Published var authenticationState = GKPlayerAuthState.authenticating
    
    var match: GKMatch?
    var otherPlayers: [GKPlayer] = []
    var localPlayer = GKLocalPlayer.local
    var playerUUIDKey = UUID().uuidString
    
    var highestUUIDReceived: String?  // Used to determine host
    
    var game: GameVM?
    
    func setup(game: GameVM) {
        self.game = game
    }
    
    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
    
    func authenticateUser() {
        GKLocalPlayer.local.authenticateHandler = { [self] vc, e in
            if let viewController = vc {
                rootViewController?.present(viewController, animated: true)
                return
            }
            
            if let error = e {
                authenticationState = .error
                print(error.localizedDescription)
                return
            }
            
            if localPlayer.isAuthenticated {
                if localPlayer.isMultiplayerGamingRestricted {
                    authenticationState = .restricted
                } else {
                    authenticationState = .authenticated
                }
            } else {
                authenticationState = .unauthenticated
            }
        }
    }
    
    func startMatchmaking() {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        
        let matchmakingVC = GKMatchmakerViewController(matchRequest: request)
        matchmakingVC?.matchmakerDelegate = self
        
        rootViewController?.present(matchmakingVC!, animated: true)
    }
    
    @MainActor
    func startGame(newMatch: GKMatch) {
        match = newMatch // likely be able to delete this
        match?.delegate = self
        otherPlayers = match?.players ?? []
        for player in otherPlayers {
            game?.players.append(Player(name: player.displayName))
        }
        game?.players[0].name = localPlayer.displayName
        let gameMove = MPGameMove(action: .start, UUIDString: game?.players[0].id)
        sendMove(gameMove: gameMove)
    }
    
    
    private func endGame() {
        self.match?.disconnect()
        game?.endGame()
    }
    
    func initiatePlayAgain() {
        let gameMove = MPGameMove(action: .reset)
        sendMove(gameMove: gameMove)
        game?.resetGame()
    }
    
    func initiateEndGame() {
        let gameMove = MPGameMove(action: .end)
        sendMove(gameMove: gameMove)
        endGame()
    }
    
    @MainActor
    func initiateGoToNextQuestion() {
        let gameMove = MPGameMove(action: .next)
        sendMove(gameMove: gameMove)
        game?.goToNextQuestion()
    }
    
    func sendMove(gameMove: MPGameMove) {
        do {
            if let data = gameMove.data() {
                try match?.sendData(toAllPlayers: data, with: .reliable)
            }
        } catch {
            print("error sending \(error.localizedDescription)")
        }
    }
    
    func sendQuestionSet() {
        let gameMove = MPGameMove(action: .questions, questionSet: game?.trivia ?? [])
        sendMove(gameMove: gameMove)
    }
    
    func sendQuestionAnswer(answer: Answer) {
        let gameMove = MPGameMove(action: .move, playerName: localPlayer.displayName, answer: answer)
        sendMove(gameMove: gameMove)
    }
    
    @MainActor
    func assignHost(uuid: String) {
        if highestUUIDReceived == nil {
            highestUUIDReceived = game?.players[0].id
        }
        
        // logic to set host for multiple players
        if game?.players[0].id == highestUUIDReceived {
            if let id = game?.players[0].id, id > uuid {
                game?.players[0].isHost = true
            } else {
                game?.players[0].isHost = false
                highestUUIDReceived = uuid
            }
        }
    }
    
    @MainActor
    func GKHandleMove(gameMove: MPGameMove) {
        switch gameMove.action {
        case .start:
            if let uuid = gameMove.UUIDString {
                assignHost(uuid: uuid)
            }
            game?.playing = true
            
        case .questions:
            self.game?.setTrivia(questions: gameMove.questionSet)
        case .move:
            if let answer = gameMove.answer, let name = gameMove.playerName {
                let i = self.game?.findIndexOfPlayer(name: name)
                if let i, i > -1 {
                    self.game?.selectAnswer(index: i, answer: answer)
                }
            }
        case .next:
            self.game?.goToNextQuestion()
        case .reset:
            self.game?.resetGame()
        case .end:
            self.endGame()
        }
    }
}


extension GKConnectionManager: GKMatchmakerViewControllerDelegate {
    
    @MainActor 
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        viewController.dismiss(animated: true)
        startGame(newMatch: match)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        viewController.dismiss(animated: true)
    }
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }
}

extension GKConnectionManager: GKMatchDelegate {
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        
        if let gameMove = try? JSONDecoder().decode(MPGameMove.self, from: data) {
            DispatchQueue.main.async {
                self.GKHandleMove(gameMove: gameMove)
            }
        }
    }
    
    func sendString(_ message: String) {
        guard let encoded = "strData:\(message)".data(using: .utf8) else { return }
        sendData(encoded)
    }
    
    func sendData(_ data: Data, mode: GKMatch.SendDataMode = .reliable) {
        do {
            try match?.sendData(toAllPlayers: data, with: mode)
        } catch {
            print(error)
        }
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        
    }
}
