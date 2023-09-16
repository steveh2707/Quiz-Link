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
            ForEach(connectionManager.availablePeers, id: \.self) { peer in
                HStack {
                    Text(peer.displayName)
                    Spacer()
                    Button("Select") {
                        connectionManager.invitePeer(peer: peer, game: game)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .scrollContentBackground(.hidden)
            Text("Connected Players")
            ForEach(game.players) { connected in
                Text(connected.name)
            }
        }
        .alert("Received invite from \(connectionManager.receivedInviteFrom?.displayName ?? "Unknown")", isPresented: $connectionManager.receivedInvite) {
            Button("Accept Invite") {
                connectionManager.acceptInvite(game: game)
            }
            Button("Reject") {
                connectionManager.declineInvite()
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
