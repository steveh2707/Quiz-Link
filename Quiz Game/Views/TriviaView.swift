//
//  TriviaView.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import SwiftUI

struct TriviaView: View {
    @StateObject var triviaManager = TriviaVM()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            if triviaManager.reachedEnd {
                VStack(spacing: 20) {
                    Text("Quiz Game")
                        .accentTitle()
                    Text("Congratulations, you completed the game! 🥳")
                    
                    Text("You scored \(triviaManager.score) out of \(triviaManager.length)")
                }
                .foregroundColor(Color.theme.accent)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.theme.background)
            
            Button("Play Again") {
                Task {
                    await triviaManager.fetchTrivia()
                }
            }
            .buttonStyle(.borderedProminent)
            
            } else {
                QuestionView()
                    .environmentObject(triviaManager)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("End Game") {
                                dismiss()
                            }
                            .buttonStyle(.bordered)
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
