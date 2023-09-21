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
    @EnvironmentObject var mpVM: MPConnectionManager
    @EnvironmentObject var gkVM: GKConnectionManager
    
    var body: some View {
        VStack(spacing: 20) {
            
            if gameVM.trivia.isEmpty {
                Text("Getting question set...")
                    .foregroundColor(Color.theme.accent)
                ProgressView()
                
            } else {
                
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
                    switch gameVM.gameType {
                    case .single:
                        gameVM.goToNextQuestion()
                    case .peer:
                        mpVM.initiateGoToNextQuestion()
                    case .online:
                        gkVM.initiateGoToNextQuestion()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!gameVM.allPlayersAnswered)
                
                Spacer(minLength: 0)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(gameVM.players) { player in
                            Score(player: player)
                        }
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("End Game") {
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
            ToolbarItem(placement: .navigationBarLeading) {
                if !gameVM.trivia.isEmpty {
                    HStack {
                        Image(systemName: "clock")
                        Text("\(gameVM.remainingTime)")
                            .font(.title2)
                    }
                    .foregroundColor(.theme.accent)
                }
            }
        }

        .onAppear {
            
            Task {
                switch gameVM.gameType {
                case .single:
                    await gameVM.fetchTrivia()
                case .peer:
                    if gameVM.players[0].isHost {
                        await gameVM.fetchTrivia()
                        mpVM.sendQuestionSet()
                    }
                case .online:
                    if gameVM.players[0].isHost {
                        await gameVM.fetchTrivia()
                        gkVM.sendQuestionSet()
                    }
                }
            }
            
        }
        .onReceive(gameVM.countdownTimer) { _ in
            gameVM.remainingTime -= 1
            if gameVM.remainingTime == 0 {
                gameVM.goToNextQuestion()
            }
        }
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
