//
//  MPPeersView.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import SwiftUI

struct MPPeersView: View {
//    @EnvironmentObject var connectionManager: MPConnectionManager
    @EnvironmentObject var gameVM: GameVM
    
    @Binding var startGame: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Text("Available Players")
                    .font(.title2)
                if gameVM.availablePeers.isEmpty {
                    ProgressView()
                        .padding()
                }
                ForEach(gameVM.availablePeers, id: \.self) { peer in
                    HStack {
                        Text(peer.displayName)
                        Spacer()
                        if gameVM.session.connectedPeers.contains(peer) {
                            Button("Disconnect") {
                                gameVM.MPendGame()
                            }
                            .buttonStyle(.bordered)
                        } else {
                            Button("Connect") {
                                gameVM.MPinvitePeer(peer: peer)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
            }
            
            Button("Start Game") {
                gameVM.players[0].isHost = true
                let gameMove = MPGameMove(action: .start)
                gameVM.MPsendMove(gameMove: gameMove)
                gameVM.MPstartGame()
            }
            .buttonStyle(.borderedProminent)
            .disabled(gameVM.session.connectedPeers.count == 0)
            
        }
        .alert("Received invite from \(gameVM.receivedInviteFrom?.displayName ?? "Unknown")", isPresented: $gameVM.receivedInvite) {
            Button("Accept Invite") {
                gameVM.MPacceptInvite()
            }
            Button("Reject") {
                gameVM.MPdeclineInvite()
            }
        }
        .background(Color.theme.background)
        .onAppear {
            gameVM.players[0].isHost = false
            gameVM.MPstartAdvertisingAndBrowsing()
        }
        .onDisappear {
            gameVM.MPstopAdvertisingAndBrowsing()
            gameVM.MPendGame()
        }
        .onChange(of: gameVM.playing) { newValue in
            if newValue {
                for player in gameVM.session.connectedPeers {
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
