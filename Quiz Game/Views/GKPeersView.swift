//
//  GKPeersVoew.swift
//  Quiz Game
//
//  Created by Steve on 19/09/2023.
//

import SwiftUI

struct GKPeersView: View {
    @EnvironmentObject var connectionManager: GKConnectionManager
    @EnvironmentObject var gameVM: GameVM
    
    @Binding var startGame: Bool
    
    var body: some View {
        VStack {
            Text(connectionManager.authenticationState.rawValue)
            
            if connectionManager.authenticationState == .authenticated {
                Button("Play") {
                    connectionManager.startMatchmaking()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onChange(of: connectionManager.playing) { newValue in
            if newValue {
                for player in connectionManager.otherPlayers {
                    gameVM.players.append(Player(name: player.displayName))
                }
                startGame = newValue
            }
        }
        
    }
}

struct GKPeersVoew_Previews: PreviewProvider {
    static var previews: some View {
        GKPeersView(startGame: .constant(false))
            .environmentObject(GKConnectionManager())
            .environmentObject(GameVM(yourName: "Sample"))
    }
}
