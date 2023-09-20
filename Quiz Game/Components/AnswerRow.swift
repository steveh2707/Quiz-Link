//
//  AnswerRow.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import SwiftUI

struct AnswerRow: View {
    @EnvironmentObject var gameVM: GameVM
//    @EnvironmentObject var connectionManager: MPConnectionManager
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
            } else if gameVM.players[0].answer != nil && answer.isCorrect {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(gameVM.players[0].answer == answer ? (isSelected ? Color.theme.accent : .gray) : Color.theme.accent)
        .background(Color.theme.backgroundSecondary)
        .cornerRadius(10)
        .shadow(color: isSelected ? (answer.isCorrect ? .green : .red) : (gameVM.players[0].answer != nil && answer.isCorrect ? .green : .gray), radius: 5, x: 0.5, y: 0.5)
        .onTapGesture {
            if gameVM.players[0].answer == nil {
                isSelected = true
                gameVM.selectAnswer(index: 0, answer: answer)
                
                if gameVM.multiplayerGame {
                    let gameMove = MPGameMove(action: .move, playerName: gameVM.myPeerId.displayName, answer: answer)
                    gameVM.sendMove(gameMove: gameMove)
                }
                
//                if gameVM.gameType == .peer {
//                    let gameMove = MPGameMove(action: .move, playerName: gameVM.myPeerId.displayName, answer: answer)
//                    gameVM.MPsendMove(gameMove: gameMove)
//                }
//                if gameVM.gameType == .online {
//                    let gameMove = MPGameMove(action: .move, playerName: gameVM.localPlayer.displayName, answer: answer)
//                    gameVM.GKsendMove(gameMove: gameMove)
//                }
            }
            
        }
    }
}

struct AnswerRow_Previews: PreviewProvider {
    static var previews: some View {
        AnswerRow(answer: Answer(text: "Single", isCorrect: true))
            .environmentObject(GameVM(yourName: "Sample"))
    }
}
