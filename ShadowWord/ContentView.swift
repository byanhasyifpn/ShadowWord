//
//  ContentView.swift
//  ShadowWord
//
//  Created by Byan Hasyif on 24/05/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
        .environmentObject(GameViewModel())
}
