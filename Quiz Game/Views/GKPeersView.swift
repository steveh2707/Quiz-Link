//
//  GKPeersVoew.swift
//  Quiz Game
//
//  Created by Steve on 19/09/2023.
//

import SwiftUI

struct GKPeersView: View {
//    @EnvironmentObject var connectionManager: GKConnectionManager
    @EnvironmentObject var gameVM: GameVM
    
    @Binding var startGame: Bool
    
    var body: some View {
        VStack {
            Text(gameVM.authenticationState.rawValue)
            
            if gameVM.authenticationState == .authenticated {
                Button("Play") {
                    gameVM.startMatchmaking()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onChange(of: gameVM.playing) { newValue in
            if newValue {
                gameVM.players[0].name = gameVM.localPlayer.displayName
                for player in gameVM.otherPlayers {
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
