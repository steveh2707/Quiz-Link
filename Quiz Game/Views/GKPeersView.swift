//
//  GKPeersVoew.swift
//  Quiz Game
//
//  Created by Steve on 19/09/2023.
//

import SwiftUI

struct GKPeersView: View {
    @EnvironmentObject var gameVM: GameVM
    
    
    var body: some View {
        VStack {
            Text(gameVM.authenticationState.rawValue)
            
            if gameVM.authenticationState == .authenticated {
                Button("Play") {
                    gameVM.GKstartMatchmaking()
                }
                .buttonStyle(.borderedProminent)
            }
            
            ForEach(gameVM.players) { player in
                Text(player.name)
            }
        }
        .onAppear {
            gameVM.authenticateUser()
        }
        
    }
}

struct GKPeersVoew_Previews: PreviewProvider {
    static var previews: some View {
        GKPeersView()
            .environmentObject(GKConnectionManager())
            .environmentObject(GameVM(yourName: "Sample"))
    }
}
