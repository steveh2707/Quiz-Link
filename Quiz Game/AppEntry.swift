//
//  Quiz_GameApp.swift
//  Quiz Game
//
//  Created by Steve on 13/09/2023.
//

import SwiftUI

@main
struct Quiz_GameApp: App {
    @AppStorage("yourName") var yourName = ""
    var body: some Scene {
        WindowGroup {
            if yourName.isEmpty {
                YourNameView()
            } else {
                StartView(yourName: yourName)
            }
        }
    }
}
