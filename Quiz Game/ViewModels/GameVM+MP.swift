//
//  GameVM+MP.swift
//  Quiz Game
//
//  Created by Steve on 19/09/2023.
//

import Foundation
import MultipeerConnectivity

extension String {
    static var serviceName = "QuizGame"
}

@MainActor
extension GameVM {

    
//    private func MPstartAdvertising() {
//        
//    }
//    
//    private func MPstopAdvertising() {
//        
//    }
//    
//    private func MPstartBrowsing() {
//        
//    }
//    
//    private func MPstopBrowsing() {
//        
//    }
    
    func MPstartAdvertisingAndBrowsing() {
//        MPstartAdvertising()
//        MPstartBrowsing()
        
        nearbyServiceAdvertiser?.startAdvertisingPeer()
        nearbyServiceBrowser?.startBrowsingForPeers()
    }
    
    func MPstopAdvertisingAndBrowsing() {
//        MPstopAdvertising()
//        MPstopBrowsing()
        nearbyServiceAdvertiser?.stopAdvertisingPeer()
        nearbyServiceBrowser?.stopBrowsingForPeers()
        print("stop called")
    }
    
    func MPinvitePeer(peer: MCPeerID) {
        nearbyServiceBrowser?.invitePeer(peer, to: session!, withContext: nil, timeout: 30)
    }
    
    func MPacceptInvite() {
        if let invitationHandler = invitationHandler {
            invitationHandler(true, session)
        }
    }
    
    func MPdeclineInvite() {
        if let invitationHandler = invitationHandler {
            invitationHandler(false, nil)
        }
    }
    
    func MPstartGame() {
        players[0].isHost = true
        let gameMove = MPGameMove(action: .start)
        sendMove(gameMove: gameMove)
        startGame()
    }

    
    func MPhandleMove(gameMove: MPGameMove) {
        switch gameMove.action {
        case .start:
            self.startGame()
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
    
    func MPdisconnect() {
        self.paired = false
        self.session?.disconnect()
    }
}


// Add and remove local peers from availablePeers array
extension GameVM: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            if !self.availablePeers.contains(peerID) {
                self.availablePeers.append(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            if let index = self.availablePeers.firstIndex(of: peerID),
               index < self.availablePeers.count {
                self.availablePeers.remove(at: index)
            }
        }
    }
}

// handle received invites
extension GameVM: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            self.receivedInvite = true
            self.receivedInviteFrom = peerID
            self.invitationHandler = invitationHandler
        }
    }
}

// handle connection and received moves
extension GameVM: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            DispatchQueue.main.async {
                self.paired = false
                self.playing = false
                if let index = self.players.firstIndex(where: { $0.name == peerID.displayName }),
                   index < self.players.count {
                    self.players.remove(at: index)
                }
            }
        case .connected:
            DispatchQueue.main.async {
                self.paired = true
                self.players.append(Player(name: peerID.displayName))
            }
        default:
            DispatchQueue.main.async {
                self.paired = false
                self.playing = false
//                self.MPstartAdvertisingAndBrowsing()
            }
        }
    }
    
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let gameMove = try? JSONDecoder().decode(MPGameMove.self, from: data) {
            DispatchQueue.main.async {
                self.MPhandleMove(gameMove: gameMove)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
    
    
}

