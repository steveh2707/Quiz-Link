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

@MainActor
class MPConnectionManager: NSObject, ObservableObject {
    let serviceType = String.serviceName
    let session: MCSession
    let myPeerId: MCPeerID
    let nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    let nearbyServiceBrowser: MCNearbyServiceBrowser
    var game: GameVM?
    
    func setup(game: GameVM) {
        self.game = game
    }
    
    @Published var availablePeers = [MCPeerID]()
    @Published var receivedInvite: Bool = false
    @Published var receivedInviteFrom: MCPeerID?
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?
    
    @Published var paired: Bool = false
//    @Published var playing: Bool = false
    
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
    
//    deinit {
//        stopAdvertisingAndBrowsing()
//    }
    
    func startAdvertisingAndBrowsing() {
        nearbyServiceAdvertiser.startAdvertisingPeer()
        nearbyServiceBrowser.startBrowsingForPeers()
    }
    
    func stopAdvertisingAndBrowsing() {
        nearbyServiceAdvertiser.stopAdvertisingPeer()
        nearbyServiceBrowser.stopBrowsingForPeers()
    }
    

    func invitePeer(peer: MCPeerID) {
        nearbyServiceBrowser.invitePeer(peer, to: session, withContext: nil, timeout: 30)
    }
    

    func acceptInvite() {
        if let invitationHandler = invitationHandler {
            invitationHandler(true, session)
        }
    }
    
    func declineInvite() {
        if let invitationHandler = invitationHandler {
            invitationHandler(false, nil)
        }
    }
    
    func initiateStartGame() {
        game?.players[0].isHost = true
        let gameMove = MPGameMove(action: .start)
        sendMove(gameMove: gameMove)
        startGame()
    }
    
    private func startGame() {
        self.stopAdvertisingAndBrowsing()
        game?.playing = true
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
    
    func initiateGoToNextQuestion() {
        let gameMove = MPGameMove(action: .next)
        sendMove(gameMove: gameMove)
        game?.goToNextQuestion()
    }
    
    func disconnectFromPeers() {
        self.paired = false
        self.session.disconnect()
    }
    
    private func endGame() {
        self.paired = false
        self.session.disconnect()
        game?.endGame()
    }
    
    
    func sendMove(gameMove: MPGameMove) {
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
    
    func sendQuestionSet() {
        let gameMove = MPGameMove(action: .questions, questionSet: game?.trivia ?? [])
        sendMove(gameMove: gameMove)
    }
    
    func sendQuestionAnswer(answer: Answer) {
        let gameMove = MPGameMove(action: .move, playerName: myPeerId.displayName, answer: answer)
        sendMove(gameMove: gameMove)
    }
    
    
    func handleReceivedMoves(gameMove: MPGameMove) {
        switch gameMove.action {
        case .start:
            self.game?.players[0].isHost = false
            self.startGame()
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
            if index < self.availablePeers.count {
                self.availablePeers.remove(at: index)
            }
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
//                self.playing = false
                self.game?.playing = false
//                self.startAdvertisingAndBrowsing()
            }
        case .connected:
            DispatchQueue.main.async {
                self.paired = true
            }
        default:
            DispatchQueue.main.async {
                self.paired = false
//                self.playing = false
                self.game?.playing = false
//                self.startAdvertisingAndBrowsing()
            }
        }
    }
    
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        if let gameMove = try? JSONDecoder().decode(MPGameMove.self, from: data) {
            DispatchQueue.main.async {
                self.handleReceivedMoves(gameMove: gameMove)
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
