//
//  TriviaView.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import SwiftUI

struct TriviaView: View {
    @StateObject var triviaVM = TriviaVM()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            if triviaVM.reachedEnd {
                VStack(spacing: 20) {
                    Text("Quiz Game")
                        .accentTitle()
                    Text("Congratulations, you completed the game! 🥳")
                    
                    Text("You scored \(triviaVM.score) out of \(triviaVM.length)")
                    
                    HStack {
                        Button("Play Again") {
                            Task {
                                await triviaVM.fetchTrivia()
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
