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

extension GameVM {
//    deinit {
//        stopAdvertisingAndBrowsing()
//    }
    
    private func MPstartAdvertising() {
        nearbyServiceAdvertiser.startAdvertisingPeer()
    }
    
    private func MPstopAdvertising() {
        nearbyServiceAdvertiser.stopAdvertisingPeer()
    }
    
    private func MPstartBrowsing() {
        nearbyServiceBrowser.startBrowsingForPeers()
    }
    
    private func stopBrowsing() {
        nearbyServiceBrowser.stopBrowsingForPeers()
    }
    
    func MPstartAdvertisingAndBrowsing() {
        MPstartAdvertising()
        MPstartBrowsing()
    }
    
    func MPstopAdvertisingAndBrowsing() {
        MPstopAdvertising()
        stopBrowsing()
        availablePeers.removeAll()
    }
    

    
    func MPinvitePeer(peer: MCPeerID) {
        nearbyServiceBrowser.invitePeer(peer, to: session, withContext: nil, timeout: 30)
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
        self.MPstopAdvertisingAndBrowsing()
        self.playing = true
        
    }
    
    func MPsendMove(gameMove: MPGameMove) {
        if !session.connectedPeers.isEmpty {
            do {
                if let data = gameMove.data() {
                    try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                }
            } catch {
                print("error sending \(error.localizedDescription)")
            }
        }
    }
    
    func MPendGame() {
        self.playing = false
        self.paired = false
        self.session.disconnect()
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
        guard let index = availablePeers.firstIndex(of: peerID) else { return }
        DispatchQueue.main.async {
            if index < self.availablePeers.count {
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
                self.MPstartAdvertisingAndBrowsing()
//                self.isAvailableToPlay = true
            }
        case .connected:
            DispatchQueue.main.async {
                self.paired = true
            }
        default:
            DispatchQueue.main.async {
                self.paired = false
                self.playing = false
                self.MPstartAdvertisingAndBrowsing()
//                self.isAvailableToPlay = true
            }
        }
    }
    
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        if let gameMove = try? JSONDecoder().decode(MPGameMove.self, from: data) {
            DispatchQueue.main.async {
                switch gameMove.action {
                case .start:
                    self.MPstartGame()
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
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
    
    
}

