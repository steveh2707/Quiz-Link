//
//  ContentView.swift
//  Quiz Game
//
//  Created by Steve on 13/09/2023.
//

import SwiftUI

struct StartView: View {
    @State private var gameType: GameType = .undetermined
    @State private var yourName = ""
    @FocusState private var focus: Bool
    @State private var startGame = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Select Game", selection: $gameType) {
                    Text("Select Game Type").tag(GameType.undetermined)
                    Text("Play on your own").tag(GameType.single)
                    Text("Play against a friend").tag(GameType.peer)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(lineWidth: 2))
                Text(gameType.description)
                    .padding()
                VStack {
                    switch gameType {
                    case .single:
                        TextField("Your Name", text: $yourName)
                    case .peer:
                        EmptyView()
                    case .undetermined:
                        EmptyView()
                    }
                }
                .padding()
                .textFieldStyle(.roundedBorder)
                .focused($focus)
                .frame(width: 350)
                
                if gameType != .peer {
                    Button("Start Game") {
                        focus = false
                        startGame = true
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(
                        gameType == .undetermined ||
                        gameType == .single && yourName.isEmpty
                    )
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Quiz Game")
            .fullScreenCover(isPresented: $startGame) {
                GameView()
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
