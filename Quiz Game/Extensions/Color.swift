//
//  Color.swift
//  Quiz Game
//
//  Created by Steve on 14/09/2023.
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

/// Create theme to be used throughout app
struct ColorTheme {
    let accent = Color("AccentColor")
    let background = Color("BackgroundColor")
    let backgroundSecondary = Color("BackgroundSecondaryColor")
    let primaryText = Color("PrimaryTextColor")
    let primaryTextInverse = Color("PrimaryTextInverseColor")
    let secondaryText = Color("SecondaryTextColor")
    let linkText = Color("LinkColor")
}
