//
//  GlassCard.swift
//  ShadowWord
//
//  Created by Byan Hasyif on 24/05/26.
//

import SwiftUI

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.2))
            }
            .shadow(radius: 10)
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCard())
    }
}
