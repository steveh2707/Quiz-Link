//
//  GameVM+GK.swift
//  Quiz Game
//
//  Created by Steve on 19/09/2023.
//

import Foundation
import GameKit

@MainActor
extension GameVM {
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
    
    func GKstartMatchmaking() {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        
        let matchmakingVC = GKMatchmakerViewController(matchRequest: request)
        matchmakingVC?.matchmakerDelegate = self
        
        rootViewController?.present(matchmakingVC!, animated: true)
    }
    
//    @MainActor
    func GKstartGame(newMatch: GKMatch) {
        match = newMatch // likely be able to delete this
        match?.delegate = self
        let otherPlayers = match?.players ?? []
        for player in otherPlayers {
            players.append(Player(name: player.displayName))
        }
        let gameMove = MPGameMove(action: .start, UUIDString: self.players[0].id)
        sendMove(gameMove: gameMove)
    }
    
    
    
//    func GKsendMove(gameMove: MPGameMove) {
//        do {
//            if let data = gameMove.data() {
//                try match?.sendData(toAllPlayers: data, with: .reliable)
//            }
//        } catch  {
//            print("error sending \(error.localizedDescription)")
//        }
//    }
    
    func GKHandleMove(gameMove: MPGameMove) {
        switch gameMove.action {
        case .start:
            if let uuid = gameMove.UUIDString {

                // logic to set host for multiple players
                if self.players[0].id == highestUUIDReceived {
                    if self.players[0].id > uuid {
                        self.players[0].isHost = true
                    } else {
                        self.players[0].isHost = false
                        highestUUIDReceived = uuid
                    }
                }
            }
            startGame()
            
        case .questions:
            self.setTrivia(questions: gameMove.questionSet)
        case .move:
            if let answer = gameMove.answer, let name = gameMove.playerName {
                let i = self.findIndexOfPlayer(name: name)
                if i > -1 {
                    self.selectAnswer(index: i, answer: answer)
                }
            }
        case .next:
            self.goToNextQuestion()
        case .reset:
            self.reset()
        case .end:
            self.endGame()
        }
    }
    
}

extension GameVM: GKMatchmakerViewControllerDelegate {
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        viewController.dismiss(animated: true)
        GKstartGame(newMatch: match)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        viewController.dismiss(animated: true)
    }
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }
}


extension GameVM: GKMatchDelegate {
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        
        if let gameMove = try? JSONDecoder().decode(MPGameMove.self, from: data) {
            DispatchQueue.main.async {
                self.GKHandleMove(gameMove: gameMove)
            }
        }
    }
    

    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        switch state {
        case .disconnected:
            DispatchQueue.main.async {
                self.endGame()
            }
        case .connected:
            DispatchQueue.main.async {
                
            }
        default:
            DispatchQueue.main.async {
                
            }
        }
    }
}
