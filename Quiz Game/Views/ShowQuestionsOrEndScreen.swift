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
    @EnvironmentObject var triviaVM: TriviaVM
    
    var body: some View {
        NavigationStack {
            if triviaVM.reachedEnd {
                VStack(spacing: 20) {
                    Text("Quiz Game")
                        .accentTitle()
                    
                    if triviaVM.gameType == .single {
                        Text("Congratulations, you completed the game! 🥳")
                            .multilineTextAlignment(.center)
                        
                        Text("You scored \(triviaVM.players[0].score) out of \(triviaVM.length)")
                    } else if triviaVM.gameType == .peer {
                        
                        Text("You scored \(triviaVM.players[0].score) out of \(triviaVM.length)")
                        
                        //TODO: update this
//                        Text("\(triviaVM.player2.name) scored \(triviaVM.player2.score) out of \(triviaVM.length)")
                        
//                        if triviaVM.player1.score > triviaVM.player2.score {
//                            Text("Congratulations, you won! 🥳")
//                        } else if triviaVM.player1.score < triviaVM.player2.score {
//                            Text("Unlucky, you lost! 👎")
//                        } else {
//                            Text("It's a tie! 😐")
//                        }
                        
                    }
                    
                    HStack {
                        Button("Play Again") {
                            if triviaVM.gameType == .single {
                                triviaVM.reset()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .foregroundColor(Color.theme.primaryTextInverse)
                        
                        Button("Quit Game") {
                            dismiss()
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
                    .environmentObject(triviaVM)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("End Game") {
                                if triviaVM.gameType == .peer {
                                    let gameMove = MPGameMove(action: .end, playerName: nil, questionSet: [], answer: nil)
                                    connectionManager.send(gameMove: gameMove)
                                }
                                dismiss()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .onAppear {
                        triviaVM.reset()
                        if triviaVM.gameType == .peer {
                            connectionManager.setup(game: triviaVM)
                        }
                    }
            }

        }
    }
}

//struct TriviaView_Previews: PreviewProvider {
//    static var previews: some View {
//        TriviaView()
//    }
//}
