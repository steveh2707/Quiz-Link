//
//  ContentView.swift
//  Quiz Game
//
//  Created by Steve on 13/09/2023.
//

import SwiftUI

struct StartView: View {
    

    @StateObject private var gameVM: GameVM
//    @StateObject private var mpConnectionManager: MPConnectionManager
//    @StateObject private var gkConnectionManager = GKConnectionManager()
//    @StateObject private var mpConnectionManager: MPGameVM
    
    @AppStorage("yourName") var yourName = ""
    @State private var startGame = false
    
    init(yourName: String) {
        self.yourName = yourName
        self._gameVM = StateObject(wrappedValue: GameVM(yourName: yourName))
//        self._gameVM = StateObject(wrappedValue: GameVM(yourName: yourName))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "brain")
                    .foregroundColor(.theme.accent)
                    .font(.system(size: 50))
                    .padding(.top)
                Text(gameTitle)
                    .accentTitle()
                
                Picker("Select Game", selection: $gameVM.gameType) {
                    Text("Single").tag(GameType.single)
                    Text("Local").tag(GameType.peer)
                    Text("Online").tag(GameType.online)
                }
                .pickerStyle(.segmented)
                .padding()

                Text(gameVM.gameType.description)
                    .foregroundColor(.theme.secondaryText)
                    .padding(.vertical)
                    .multilineTextAlignment(.center)
                VStack {
                    switch gameVM.gameType {
                    case .single:
                        Spacer()
                        Button("Start Game") {
                            startGame = true
                        }
                        .buttonStyle(.borderedProminent)
                        Spacer()
                    case .peer:
                        MPPeersView(startGame: $startGame)
                            .environmentObject(gameVM)
//                            .environmentObject(gameVM)
                    case .online:
                        GKPeersView(startGame: $startGame)
//                            .environmentObject(gkConnectionManager)
                            .environmentObject(gameVM)
                            .onAppear {
                                gameVM.authenticateUser()
                            }
                    }
                }
                .padding()
                .textFieldStyle(.roundedBorder)
                .frame(width: 350)


                Spacer()
                Text("Your name is \(yourName)")
                Button("Change Name") {
                    //TODO: Add code to change name
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.theme.background)
            .fullScreenCover(isPresented: $startGame) {
                ShowQuestionsOrEndScreen()
                    .environmentObject(gameVM)
//                    .environmentObject(gameVM)
                    .onDisappear {
                        gameVM.endGame()
                    }
            }
//            .onChange(of: gameVM.gameType) { newGameType in
//                if newGameType != .peer {
////                    connectionManager.isAvailableToPlay = false
//                    mpConnectionManager.stopAdvertisingAndBrowsing()
//                }
//            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(yourName: "Steve")
    }
}
