//
//  QuestionView.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import SwiftUI

struct QuestionView: View {
    @EnvironmentObject var triviaVM: TriviaVM
    
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
                
                ForEach(triviaVM.answerChoices, id: \.id) { answer in
                    AnswerRow(answer: answer)
                }

            }
            
            Button("Next") {
                triviaVM.goToNextQuestion()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!triviaVM.answerSelected)
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
