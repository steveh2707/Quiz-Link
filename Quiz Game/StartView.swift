//
//  ContentView.swift
//  Quiz Game
//
//  Created by Steve on 13/09/2023.
//

import SwiftUI

struct StartView: View {
    
    @State private var gameType: GameType = .single
//    @State private var yourName = "Steve"
    @AppStorage("yourName") var yourName = ""
    @FocusState private var focus: Bool
    @State private var startGame = false
    
    init(yourName: String) {
        self.yourName = yourName
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Quiz Game")
                    .accentTitle()
                    .padding()
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
                        EmptyView()
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
                        gameType == .undetermined
                    )
                }
                Spacer()
                Text("Your name is \(yourName)")
                Button("Change Name") {
                    
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.theme.background)
//            .navigationTitle("Quiz Game")
            .fullScreenCover(isPresented: $startGame) {
                TriviaView()
                    
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(yourName: "Steve")
    }
}
