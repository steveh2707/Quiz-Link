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
    
    var body: some View {
        NavigationStack {
            if gameVM.reachedEnd {
                gameEndScreen
            } else {
                QuestionView()
                    .environmentObject(gameVM)
//                    .onAppear {
//                        gameVM.reset()
//                    }
            }
        }
        .onChange(of: gameVM.playing) { newValue in
            if !newValue {
                gameVM.players[0].isHost = false
                dismiss()
            }
        }
        .onDisappear {
            gameVM.endGame()
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
                    gameVM.playAgain()
                }
                .buttonStyle(.borderedProminent)
                .foregroundColor(Color.theme.primaryTextInverse)
                
                Button("Quit Game") {
//                    if gameVM.multiplayerGame {
//                        let gameMove = MPGameMove(action: .end)
//                        gameVM.sendMove(gameMove: gameMove)
//                        gameVM.endGame()
//                    } else {
//                        dismiss()
//                    }
                    gameVM.initiateEndGame()
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
