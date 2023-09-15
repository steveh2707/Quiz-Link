//
//  MPPeersView.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import SwiftUI

struct MPPeersView: View {
    @EnvironmentObject var connectionManager: MPConnectionManager
    @EnvironmentObject var game: TriviaVM
    @Binding var startGame: Bool
    var body: some View {
        VStack {
            Text("Available Players")
            if connectionManager.availablePeers.isEmpty {
                ProgressView()
            }
//            List(connectionManager.availablePeers, id: \.self) { peer in
            ForEach(connectionManager.availablePeers, id: \.self) { peer in
                HStack {
                    Text(peer.displayName)
                    Spacer()
                    Button("Select") {
                        game.gameType = .peer
                        connectionManager.nearbyServiceBrowser.invitePeer(peer, to: connectionManager.session, withContext: nil, timeout: 30)
                        game.player1.name = connectionManager.myPeerId.displayName
                        game.player2.name = peer.displayName
                        game.host = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .scrollContentBackground(.hidden)
            .alert("Received invite from \(connectionManager.receivedInviteFrom?.displayName ?? "Unknown")", isPresented: $connectionManager.receivedInvite) {
                Button("Accept Invite") {
                    if let invitationHandler = connectionManager.invitationHandler {
                        invitationHandler(true, connectionManager.session)
                        game.player1.name = connectionManager.myPeerId.displayName
                        game.player2.name = connectionManager.receivedInviteFrom?.displayName ?? "Unknown"
                        game.gameType = .peer
                    }
                }
                Button("Reject") {
                    if let invitationHandler = connectionManager.invitationHandler {
                        invitationHandler(false, nil)
                    }
                }
            }
        }
        .background(Color.theme.background)
        .onAppear {
            connectionManager.isAvailableToPlay = true
        }
        .onDisappear {
            connectionManager.isAvailableToPlay = false
        }
        .onChange(of: connectionManager.paired) { newValue in
            startGame = newValue
        }
    }
}

struct MPPeersView_Previews: PreviewProvider {
    static var previews: some View {
        MPPeersView(startGame: .constant(false))
            .environmentObject(MPConnectionManager(yourName: "Sample"))
            .environmentObject(TriviaVM(yourName: "Sample"))
    }
}
