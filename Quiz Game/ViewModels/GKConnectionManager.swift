//
//  GCConnectionManager.swift
//  Quiz Game
//
//  Created by Steve on 19/09/2023.
//

import Foundation
import GameKit

class GKConnectionManager: NSObject, ObservableObject {
    @Published var authenticationState = GKPlayerAuthState.authenticating
    @Published var playing: Bool = false
    
    var match: GKMatch?
    var otherPlayers: [GKPlayer] = []
    var localPlayer = GKLocalPlayer.local
    var playerUUIDKey = UUID().uuidString
    
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
//        for player in otherPlayers {
//            game?.players.append(Player(name: player.displayName))
//        }
        sendString("began:\(playerUUIDKey)")
        playing = true
    }
    
    func receivedString(_ message: String) {
        let messageSplit = message.split(separator: ".")
        guard let messagePrefix = messageSplit.first else { return }
        
        let parameter = String(messageSplit.last ?? "")
        
        switch messagePrefix {
        case "began":
            // unlikely scenario that UUIDs are the same
            if playerUUIDKey == parameter {
                playerUUIDKey = UUID().uuidString
                sendString("began: \(playerUUIDKey)")
                break
            }
            
            
        default:
            break
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
        let content = String(decoding: data, as: UTF8.self)
        
        if content.starts(with: "strData:") {
            let message = content.replacing("strData", with: "")
            receivedString(message)
        } else {
            return
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
