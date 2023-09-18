//
//  TriviaView.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import SwiftUI

struct ShowQuestionsOrEndScreen: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var connectionManager: MPConnectionManager
    @EnvironmentObject var gameVM: GameVM
    
    var body: some View {
        NavigationStack {
            if gameVM.reachedEnd {
                VStack(spacing: 20) {
                    Text("Quiz Game")
                        .accentTitle()
                    
                    if gameVM.gameType == .single {
                        Text("Congratulations, you completed the game! 🥳")
                            .multilineTextAlignment(.center)
                        
                        Text("You scored \(gameVM.players[0].score) out of \(gameVM.length)")
                    } else if gameVM.gameType == .peer {
                        
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
                            if gameVM.gameType == .peer {
                                let gameMove = MPGameMove(action: .reset)
                                connectionManager.send(gameMove: gameMove)
                            }
                            gameVM.reset()
                        }
                        .buttonStyle(.borderedProminent)
                        .foregroundColor(Color.theme.primaryTextInverse)
                        
                        Button("Quit Game") {
                            if gameVM.gameType == .peer {
                                let gameMove = MPGameMove(action: .end)
                                connectionManager.send(gameMove: gameMove)
                                connectionManager.endGame()
                            } else {
                                dismiss()
                            }
                        }
                        .buttonStyle(.bordered)
                    }

                }
                .foregroundColor(Color.theme.accent)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.theme.background)
            
            } else {
                QuestionView()
                    .environmentObject(gameVM)
                    .onAppear {
                        gameVM.reset()
                        if gameVM.gameType == .peer {
                            connectionManager.setup(game: gameVM)
                        }
                    }
            }

        }
        .onChange(of: connectionManager.playing, perform: { newValue in
            if !newValue {
                gameVM.players[0].isHost = false
                dismiss()
            }
        })
    }
}

//struct TriviaView_Previews: PreviewProvider {
//    static var previews: some View {
//        TriviaView()
//    }
//}
