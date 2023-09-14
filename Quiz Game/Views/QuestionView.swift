//
//  QuestionView.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import SwiftUI

struct QuestionView: View {
    @EnvironmentObject var triviaManager: TriviaVM
    
    var body: some View {
        VStack(spacing: 40) {
            HStack {
                Text("Quiz Game")
                    .accentTitle()
                
                Spacer()
                
                Text("\(triviaManager.index+1) out of \(triviaManager.length)")
                    .foregroundColor(Color.theme.accent)
                    .fontWeight(.heavy)
            }
            
            ProgressBar(progress: triviaManager.progress)
            
            VStack(alignment: .leading) {
                Text(triviaManager.question)
                    .font(.system(size: 20))
                    .bold()
                    .foregroundColor(.theme.secondaryText)
                    .padding(.bottom)
                
                ForEach(triviaManager.answerChoices, id: \.id) { answer in
                    AnswerRow(answer: answer)
                }

            }
            
            Button("Next") {
                triviaManager.goToNextQuestion()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!triviaManager.answerSelected)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background)
    }
}

struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionView()
            .environmentObject(TriviaVM())
    }
}
