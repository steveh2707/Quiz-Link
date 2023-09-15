//
//  QuestionView.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import SwiftUI

struct QuestionView: View {
    @EnvironmentObject var triviaVM: TriviaVM
    @EnvironmentObject var connectionManager: MPConnectionManager
    
    var body: some View {
        VStack(spacing: 40) {
            
            HStack {
                Text("Quiz Game")
                    .accentTitle()
                
                Spacer()
                
                Text("\(triviaVM.index+1) out of \(triviaVM.length)")
                    .foregroundColor(Color.theme.accent)
                    .fontWeight(.heavy)
            }
            
            ProgressBar(progress: triviaVM.progress)
            
            VStack(alignment: .leading, spacing: 20) {
                Text(triviaVM.question)
                    .font(.system(size: 20))
                    .bold()
                    .foregroundColor(.theme.secondaryText)
                    .padding(.bottom)
                    .fixedSize(horizontal: false, vertical: true)
                
                ForEach(triviaVM.answerChoices, id: \.id) { answer in
                    AnswerRow(answer: answer)
                }
                
            }
            
            Button("Next") {
                triviaVM.goToNextQuestion()
                if triviaVM.gameType == .peer {
                    let gameMove = MPGameMove(action: .next)
                    connectionManager.send(gameMove: gameMove)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled( triviaVM.gameType == .peer ?
                       triviaVM.player1.answer == nil || triviaVM.player2.answer == nil :
                        triviaVM.player1.answer == nil
            )
            Spacer()
            
            HStack {
                VStack {
                    Text(triviaVM.player1.name)
                    Text("\(triviaVM.player1.score)")
                }
                if triviaVM.gameType == .peer {
                    VStack {
                        Text(triviaVM.player2.name)
                        Text("\(triviaVM.player2.score)")
                    }
                }
            }
        }
        .onAppear {
            if triviaVM.gameType == .single || triviaVM.host {
                Task {
                    await triviaVM.fetchTrivia()
                    
                    if triviaVM.gameType == .peer {
                        let gameMove = MPGameMove(action: .start, playerName: triviaVM.player1.name, questionSet: triviaVM.trivia, answer: nil)
                        connectionManager.send(gameMove: gameMove)
                    }
                }
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
            .environmentObject(TriviaVM(yourName: "Test"))
    }
}
