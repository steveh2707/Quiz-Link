//
//  MPConnectionManager.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import MultipeerConnectivity

extension String {
    static var serviceName = "QuizGame"
}

class MPConnectionManager: NSObject, ObservableObject {
    let serviceType = String.serviceName
    let session: MCSession
    let myPeerId: MCPeerID
    let nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    let nearbyServiceBrowser: MCNearbyServiceBrowser
    var game: TriviaVM?
    
    func setup(game: TriviaVM) {
        self.game = game
    }
    
    @Published var availablePeers = [MCPeerID]()
    @Published var receivedInvite: Bool = false
    @Published var receivedInviteFrom: MCPeerID?
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?
    @Published var paired: Bool = false
    
    var isAvailableToPlay: Bool = false {
        didSet {
            if isAvailableToPlay {
                startAdvertising()
                startBrowsing()
            } else {
                stopAdvertising()
                stopBrowsing()
            }
        }
    }
    
    init(yourName: String) {
        myPeerId = MCPeerID(displayName: yourName)
        session = MCSession(peer: myPeerId)
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        super.init()
        session.delegate = self
        nearbyServiceAdvertiser.delegate = self
        nearbyServiceBrowser.delegate = self
    }
    
    deinit {
        stopAdvertising()
        stopBrowsing()
    }
    
    func startAdvertising() {
        nearbyServiceAdvertiser.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        nearbyServiceAdvertiser.stopAdvertisingPeer()
    }
    
    func startBrowsing() {
        nearbyServiceBrowser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        nearbyServiceBrowser.stopBrowsingForPeers()
        availablePeers.removeAll()
    }
    
    func send(gameMove: MPGameMove) {
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
    
    @MainActor
    func invitePeer(peer: MCPeerID, game: TriviaVM) {
        game.gameType = .peer
        nearbyServiceBrowser.invitePeer(peer, to: session, withContext: nil, timeout: 30)
//        game.player1.name = myPeerId.displayName
//        game.player2.name = peer.displayName
        game.players[0].name = myPeerId.displayName
        game.players.append(Player(name: peer.displayName))
        game.host = true
    }
    
    @MainActor
    func acceptInvite(game: TriviaVM) {
        if let invitationHandler = invitationHandler {
            invitationHandler(true, session)
//            game.player1.name = myPeerId.displayName
//            game.player2.name = receivedInviteFrom?.displayName ?? "Unknown"
            game.players[0].name = myPeerId.displayName
            game.players.append(Player(name: receivedInviteFrom?.displayName ?? "Unknown"))
            game.gameType = .peer
        }
    }
    
    func declineInvite() {
        if let invitationHandler = invitationHandler {
            invitationHandler(false, nil)
        }
    }
}

// Add and remove local peers from availablePeers array
extension MPConnectionManager: MCNearbyServiceBrowserDelegate {
    
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
            self.availablePeers.remove(at: index)
        }
    }
}

// handle received invites
extension MPConnectionManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            self.receivedInvite = true
            self.receivedInviteFrom = peerID
            self.invitationHandler = invitationHandler
        }
    }
}

// handle connection and received moves
extension MPConnectionManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            DispatchQueue.main.async {
                self.paired = false
                self.isAvailableToPlay = true
            }
        case .connected:
            DispatchQueue.main.async {
                self.paired = true
//                self.isAvailableToPlay = false
//                self.availablePeers = []
            }
        default:
            DispatchQueue.main.async {
                self.paired = false
                self.isAvailableToPlay = true
            }
        }
    }
    
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        if let gameMove = try? JSONDecoder().decode(MPGameMove.self, from: data) {
            DispatchQueue.main.async {
                switch gameMove.action {
                case .start:
                    self.game?.setTrivia(questions: gameMove.questionSet)
                case .move:
                    if let answer = gameMove.answer, let name = gameMove.playerName {
                        let i = self.game?.findIndexOfPlayer(name: name)
                        if let i, i > -1 {
                            self.game?.selectAnswer(index: i, answer: answer)
                        }
//                        self.game?.setOpponentAnswer(answer: answer)
                    }
                case .next:
                    self.game?.goToNextQuestion()
                case .end:
                    self.session.disconnect()
                    self.isAvailableToPlay = true
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
