//
//  YourNameView.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import SwiftUI

struct YourNameView: View {
    @AppStorage("yourName") var yourName = ""
    @State private var userName = ""
    var body: some View {
        NavigationStack {
            VStack {
                Text("This is the name that will be associated with this device")
                TextField("Your Name", text: $userName)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                Button("Set") {
                    yourName = userName
                }
                .buttonStyle(.borderedProminent)
                .disabled(userName.isEmpty)
                Spacer()
            }
            .padding()
            .navigationTitle("Quiz Game")
        }
    }
}

struct YourNameView___Previews: PreviewProvider {
    static var previews: some View {
        YourNameView()
    }
}
