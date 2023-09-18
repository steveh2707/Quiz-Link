//
//  Temp.swift
//  Quiz Game
//
//  Created by Steve on 17/09/2023.
//

import SwiftUI

struct Score: View {
    var player: Player
    
    var body: some View {
        VStack {
            Text(player.name)
                .font(.title3)
            
            Text("\(player.score)")
                .font(.headline)
                .foregroundColor(.theme.accent)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.theme.backgroundSecondary)
        )
    }
}

struct Temp_Previews: PreviewProvider {
    static var previews: some View {
        Score(player: Player(name: "Steve"))
        
    }
}
