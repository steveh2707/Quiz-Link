//
//  MPPeersView.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import SwiftUI

struct MPPeersView: View {
    @EnvironmentObject var connectionManager: MPConnectionManager
    @EnvironmentObject var gameVM: GameVM
    
    @Binding var startGame: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Text("Available Players")
                    .font(.title2)
                if connectionManager.availablePeers.isEmpty {
                    ProgressView()
                }
                ForEach(connectionManager.availablePeers, id: \.self) { peer in
                    if !connectionManager.session.connectedPeers.contains(peer) {
                        HStack {
                            Text(peer.displayName)
                            Spacer()
                            Button("Select") {
                                connectionManager.invitePeer(peer: peer, game: gameVM)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
            }
            
            if connectionManager.session.connectedPeers.count > 0 {
                VStack {
                    Text("Connected Players")
                        .font(.title3)
                    ForEach(connectionManager.session.connectedPeers, id: \.self) { connected in
                        Text(connected.displayName)
                    }
                }
            }
            
            Button("Start Game") {
                gameVM.players[0].isHost = true
                let gameMove = MPGameMove(action: .start)
                connectionManager.send(gameMove: gameMove)
                connectionManager.startGame = true
            }
            .buttonStyle(.borderedProminent)
            .disabled(connectionManager.session.connectedPeers.count == 0)
            
        }
        .alert("Received invite from \(connectionManager.receivedInviteFrom?.displayName ?? "Unknown")", isPresented: $connectionManager.receivedInvite) {
            Button("Accept Invite") {
                connectionManager.acceptInvite(game: gameVM)
            }
            Button("Reject") {
                connectionManager.declineInvite()
            }
        }
        .background(Color.theme.background)
        .onAppear {
            gameVM.players[0].isHost = false
            connectionManager.isAvailableToPlay = true
        }
        .onDisappear {
            connectionManager.isAvailableToPlay = false
        }
        .onChange(of: connectionManager.startGame) { newValue in
            if newValue {
                for player in connectionManager.session.connectedPeers {
                    gameVM.players.append(Player(name: player.displayName))
                }
                startGame = newValue
            }
        }
    }
}

struct MPPeersView_Previews: PreviewProvider {
    static var previews: some View {
        MPPeersView(startGame: .constant(false))
            .environmentObject(MPConnectionManager(yourName: "Sample"))
            .environmentObject(GameVM(yourName: "Sample"))
    }
}
