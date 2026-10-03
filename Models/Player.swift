//
//  Player.swift
//  ShadowWord
//
//  Created by Byan Hasyif on 24/05/26.
//

import Foundation

struct Player: Identifiable, Equatable {
    let id = UUID()
    let number: Int
    let role: Role
    let word: String?
    var name: String = ""

    var displayName: String {
        name.isEmpty ? "Player \(number)" : name
    }
}
