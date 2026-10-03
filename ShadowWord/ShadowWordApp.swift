//
//  ShadowWordApp.swift
//  ShadowWord
//
//  Created by Byan Hasyif on 24/05/26.
//

import SwiftUI

@main
struct ShadowWordApp: App {
    @StateObject private var gameVM = GameViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameVM)
        }
    }
}
