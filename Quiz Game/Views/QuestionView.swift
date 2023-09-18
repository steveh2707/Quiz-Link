//
//  QuestionView.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import SwiftUI

struct QuestionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gameVM: GameVM
    @EnvironmentObject var connectionManager: MPConnectionManager
    
    var body: some View {
        VStack(spacing: 20) {
            
            HStack {
                Text("Quiz Game")
                    .accentTitle()
                
                Spacer()
                
                Text("\(gameVM.index+1) out of \(gameVM.length)")
                    .foregroundColor(Color.theme.accent)
                    .fontWeight(.heavy)
            }
            
            ProgressBar(progress: gameVM.progress)
            
            VStack(alignment: .leading, spacing: 20) {
                Text(gameVM.question)
                    .font(.system(size: 20))
                    .bold()
                    .foregroundColor(.theme.secondaryText)
                    .padding(.bottom)
                    .fixedSize(horizontal: false, vertical: true)
                
                ForEach(gameVM.answerChoices, id: \.id) { answer in
                    AnswerRow(answer: answer)
                }
                
            }
            
            Button("Next") {
                gameVM.goToNextQuestion()
                if gameVM.gameType == .peer {
                    let gameMove = MPGameMove(action: .next)
                    connectionManager.send(gameMove: gameMove)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!gameVM.allPlayersAnswered)
            
            Spacer(minLength: 0)
            
            HStack {
                ForEach(gameVM.players) { player in
                    Score(player: player)
                }
            }
            Spacer(minLength: 0)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("End Game") {
                    if gameVM.gameType == .peer {
                        let gameMove = MPGameMove(action: .end)
                        connectionManager.send(gameMove: gameMove)
                        connectionManager.disconnect()
                    } else {
                        dismiss()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .onAppear {
            if gameVM.gameType == .single || gameVM.players[0].isHost {
                Task {
                    await gameVM.fetchTrivia()
                    
                    if gameVM.gameType == .peer {
                        let gameMove = MPGameMove(action: .questions, questionSet: gameVM.trivia)
                        connectionManager.send(gameMove: gameMove)
                    }
                }
            }
        }
        .onChange(of: connectionManager.startGame, perform: { newValue in
            if !newValue {
                gameVM.players[0].isHost = false
                dismiss()
            }
        })
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background)
    }
}

struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionView()
            .environmentObject(GameVM(yourName: "Test"))
    }
}
