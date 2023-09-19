//
//  Text.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import Foundation
import SwiftUI


extension Text {
    func accentTitle() -> some View {
        self
            .font(.largeTitle)
            .fontWeight(.heavy)
            .foregroundColor(Color.theme.accent)
    }
}
