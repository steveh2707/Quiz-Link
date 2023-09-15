//
//  AnswerRow.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import SwiftUI

struct AnswerRow: View {
    @EnvironmentObject var triviaManager: TriviaVM
    @EnvironmentObject var connectionManager: MPConnectionManager
    var answer: Answer
    @State private var isSelected = false
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: "circle.fill")
                .font(.caption)
            
            Text(answer.text)
            
            if isSelected {
                Spacer()
                Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "x.circle.fill")
                    .foregroundColor(answer.isCorrect ? .green : .red)
            } else if triviaManager.player1.answer != nil && answer.isCorrect {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(triviaManager.player1.answer == answer ? (isSelected ? Color.theme.accent : .gray) : Color.theme.accent)
        .background(Color.theme.backgroundSecondary)
        .cornerRadius(10)
        .shadow(color: isSelected ? (answer.isCorrect ? .green : .red) : (triviaManager.player1.answer != nil && answer.isCorrect ? .green : .gray), radius: 5, x: 0.5, y: 0.5)
        .onTapGesture {
            if triviaManager.player1.answer == nil {
                isSelected = true
                triviaManager.selectAnswer(answer: answer)
                if triviaManager.gameType == .peer {
                    let gameMove = MPGameMove(action: .move, playerName: connectionManager.myPeerId.displayName, questionSet: [], answer: answer)
                    connectionManager.send(gameMove: gameMove)
                }
            }
            
        }
    }
}

struct AnswerRow_Previews: PreviewProvider {
    static var previews: some View {
        AnswerRow(answer: Answer(text: "Single", isCorrect: true))
            .environmentObject(TriviaVM(yourName: "Sample"))
    }
}
