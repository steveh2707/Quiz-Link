//
//  MPPeersView.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import SwiftUI

struct MPPeersView: View {
    @EnvironmentObject var gameVM: GameVM
    
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
//                                gameVM.endGame()
                                gameVM.MPdisconnect()
                                //TODO: endGame function overkill here?
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
            print("disappear")
//            gameVM.removeOtherPlayers()
            gameVM.MPdisconnect()
            gameVM.MPstopAdvertisingAndBrowsing()
        }
    }
}

struct MPPeersView_Previews: PreviewProvider {
    static var previews: some View {
        MPPeersView()
            .environmentObject(MPConnectionManager(yourName: "Sample"))
            .environmentObject(GameVM(yourName: "Sample"))
    }
}
