//
//  TriviaView.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import SwiftUI

struct ShowQuestionsOrEndScreen: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gameVM: GameVM
    @EnvironmentObject var mpVM: MPConnectionManager
    @EnvironmentObject var gkVM: GKConnectionManager
    
    var body: some View {
        NavigationStack {
            if gameVM.reachedEnd {
                gameEndScreen
            } else {
                QuestionView()
            }
        }
    }
    
    
    private var gameEndScreen: some View {
        VStack(spacing: 20) {
            Text("Quiz Game")
                .accentTitle()
            
            switch gameVM.gameType {
            case .single:
                Text("Congratulations, you completed the game! 🥳")
                    .multilineTextAlignment(.center)
                Text("You scored \(gameVM.players[0].score) out of \(gameVM.length)")
            case .peer, .online:
                Text("You scored \(gameVM.players[0].score) out of \(gameVM.length)")
                
                Text("Ranking")
                    .font(.title2)
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(gameVM.players.sorted{ $0.score > $1.score }) { player in
                        Text("\(player.name): \(player.score)")
                    }
                }
            }
            
            HStack {
                Button("Play Again") {
                    switch gameVM.gameType {
                    case .single:
                        gameVM.resetGame()
                    case .peer:
                        mpVM.initiatePlayAgain()
                    case .online:
                        gkVM.initiatePlayAgain()
                    }
                }
                .buttonStyle(.borderedProminent)
                .foregroundColor(Color.theme.primaryTextInverse)
                
                Button("Quit Game") {
                    switch gameVM.gameType {
                    case .single:
                        gameVM.endGame()
                    case .peer:
                        mpVM.initiateEndGame()
                    case .online:
                        gkVM.initiateEndGame()
                    }
                    
                }
                .buttonStyle(.bordered)
            }

        }
        .foregroundColor(Color.theme.accent)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background)
    }
}

//struct TriviaView_Previews: PreviewProvider {
//    static var previews: some View {
//        TriviaView()
//    }
//}
