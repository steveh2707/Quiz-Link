//
//  ContentView.swift
//  Quiz Game
//
//  Created by Steve on 13/09/2023.
//

import SwiftUI

struct StartView: View {
    

    @StateObject private var connectionManager: MPConnectionManager
    @StateObject var triviaVM: TriviaVM
    
    @AppStorage("yourName") var yourName = ""
    @FocusState private var focus: Bool
    @State private var startGame = false
    
    init(yourName: String) {
        self.yourName = yourName
        self._connectionManager = StateObject(wrappedValue: MPConnectionManager(yourName: yourName))
        self._triviaVM = StateObject(wrappedValue: TriviaVM(yourName: yourName))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Quiz Game")
                    .accentTitle()
                    .padding()
                Picker("Select Game", selection: $triviaVM.gameType) {
                    Text("Select Game Type").tag(GameType.undetermined)
                    Text("Play on your own").tag(GameType.single)
                    Text("Play against a friend").tag(GameType.peer)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(lineWidth: 2))
                Text(triviaVM.gameType.description)
                    .padding()
                VStack {
                    switch triviaVM.gameType {
                    case .single:
                        EmptyView()
                    case .peer:
                        MPPeersView(startGame: $startGame)
                            .environmentObject(connectionManager)
                            .environmentObject(triviaVM)
                    case .undetermined:
                        EmptyView()
                    }
                }
                .padding()
                .textFieldStyle(.roundedBorder)
                .focused($focus)
                .frame(width: 350)
                
                if triviaVM.gameType != .peer {
                    Button("Start Game") {
                        focus = false
                        startGame = true
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(
                        triviaVM.gameType == .undetermined
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
            .fullScreenCover(isPresented: $startGame) {
                ShowQuestionsOrEndScreen()
                    .environmentObject(connectionManager)
                    .environmentObject(triviaVM)
                    .onDisappear {
                        triviaVM.endGame()
                    }
                    
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(yourName: "Steve")
    }
}
