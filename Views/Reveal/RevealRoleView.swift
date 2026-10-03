//
//  RevealRoleView.swift
//  ShadowWord
//
//  Created by Byan Hasyif on 24/05/26.
//

import SwiftUI

struct RevealRoleView: View {
    @EnvironmentObject private var gameVM: GameViewModel

    @State private var isRevealed = false
    @State private var nextRoute: RevealRoute?

    private var canContinue: Bool {
        isRevealed
    }

    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "f7eeff"), location: 0.0),
                    .init(color: Color(hex: "fdf0e8"), location: 0.4),
                    .init(color: Color(hex: "ffe8e8"), location: 0.8),
                    .init(color: Color(hex: "f0eeff"), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color(hex: "4DA8FF").opacity(0.15))
                .frame(width: 200, height: 200)
                .blur(radius: 40)
                .offset(x: 110, y: -200)
                .allowsHitTesting(false)

            Circle()
                .fill(Color(hex: "7C5CFC").opacity(0.12))
                .frame(width: 180, height: 180)
                .blur(radius: 40)
                .offset(x: -100, y: 260)
                .allowsHitTesting(false)

            if let player = gameVM.currentPlayer {
                VStack(spacing: 20) {

                    GamePhaseBadge(text: "PHASE 2 · YOUR ROLE", color: Color(hex: "4DA8FF"), isPulsing: false)

                    // Floating icon
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "72BFFF"), Color(hex: "4DA8FF")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: isRevealed ? "person.fill.checkmark" : "lock.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        )
                        .shadow(color: Color(hex: "4DA8FF").opacity(0.45), radius: 14, x: 0, y: 8)

                    // Title block
                    VStack(spacing: 4) {
                        Text(player.displayName)
                            .font(.system(size: 12, weight: .heavy))
                            .tracking(0.8)
                            .foregroundColor(Color(hex: "4DA8FF"))
                            .textCase(.uppercase)

                        Text("Your Role")
                            .font(.custom("Nunito-Black", size: 32))
                            .foregroundColor(Color(hex: "2D2852"))

                        Text(isRevealed ? "Your secret is safe with us" : "Tap the card to reveal\nyour secret assignment")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "8B8AB0"))
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }

                    // Reveal card
                    revealCard(for: player)

                    Spacer()

                    // Next player button
                    Button {
                        gameVM.nextPlayer()
                        nextRoute = gameVM.gameState == .discussion ? .discussion : .passDevice
                    } label: {
                        HStack {
                            HStack(spacing: 11) {
                                Circle()
                                    .fill(Color.white.opacity(canContinue ? 0.25 : 0.15))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: "chevron.right.2")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white.opacity(canContinue ? 1 : 0.6))
                                    )
                                Text("Next Player")
                                    .font(.custom("Nunito-Black", size: 18))
                                    .foregroundColor(.white.opacity(canContinue ? 1 : 0.6))
                            }
                            Spacer()
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white.opacity(isRevealed ? 1 : 0.6))
                                )
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 17)
                        .background(
                            Group {
                                if canContinue {
                                    LinearGradient(
                                        colors: [Color(hex: "88D98F"), Color(hex: "6BCB77")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                } else {
                                    LinearGradient(
                                        colors: [Color(hex: "D5D0F5"), Color(hex: "C2BAF0")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(
                            color: canContinue ? Color(hex: "6BCB77").opacity(0.45) : .clear,
                            radius: 14, x: 0, y: 6
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                    }
                    .disabled(!canContinue)
                    .buttonStyle(SpringButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden()
        .navigationDestination(item: $nextRoute) { route in
            switch route {
            case .passDevice:  PassDeviceView()
            case .discussion:  DiscussionView()
            }
        }
        .onAppear {
            isRevealed = false
            nextRoute = nil
        }
    }

    // MARK: - Reveal Card
    private func revealCard(for player: Player) -> some View {
        VStack(spacing: 16) {
            if isRevealed {
                // Role badge
                let isImpostor = player.role != .civilian
                HStack(spacing: 6) {
                    Circle()
                        .fill(isImpostor ? Color(hex: "FF6B6B") : Color(hex: "6BCB77"))
                        .frame(width: 7, height: 7)
                    Text(player.role.displayName.uppercased())
                        .font(.system(size: 11, weight: .heavy))
                        .tracking(0.8)
                        .foregroundColor(isImpostor ? Color(hex: "FF6B6B") : Color(hex: "4CAF57"))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    (isImpostor ? Color(hex: "FF6B6B") : Color(hex: "6BCB77")).opacity(0.12)
                )
                .clipShape(Capsule())

                // Divider
                Rectangle()
                    .fill(Color(hex: "F0EEF8"))
                    .frame(height: 1)

                // Word
                VStack(spacing: 4) {
                    Text("YOUR WORD")
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(0.6)
                        .foregroundColor(Color(hex: "AEACD0"))

                    if let word = player.word {
                        Text(word)
                            .font(.custom("Nunito-Black", size: 30))
                            .foregroundColor(Color(hex: "2D2852"))
                    } else {
                        Text("NO WORD")
                            .font(.custom("Nunito-Black", size: 24))
                            .foregroundColor(Color(hex: "FF6B6B"))
                    }
                }

            } else {
                // Locked state
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(hex: "7C5CFC").opacity(0.1))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "lock.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "7C5CFC"))
                    )

                Text("Tap to Reveal")
                    .font(.custom("Nunito-Black", size: 16))
                    .foregroundColor(Color(hex: "7C5CFC"))

                Text("Only you should see this")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "AEACD0"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color(hex: "7C5CFC").opacity(0.1), radius: 16, x: 0, y: 4)
        .onTapGesture {
            guard !isRevealed else { return }
            isRevealed = true
        }
    }
}

// MARK: - Shared Components

struct GamePhaseBadge: View {
    let text: String
    let color: Color
    let isPulsing: Bool
    @State private var pulsing = false

    init(text: String, color: Color, isPulsing: Bool = true) {
        self.text = text
        self.color = color
        self.isPulsing = isPulsing
    }

    var body: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .shadow(color: color.opacity(isPulsing && pulsing ? 0.1 : 0.4), radius: isPulsing && pulsing ? 6 : 3)
                .animation(isPulsing ? .easeInOut(duration: 1.8).repeatForever(autoreverses: true) : nil, value: pulsing)
                .onAppear { pulsing = isPulsing }

            Text(text)
                .font(.system(size: 10, weight: .heavy))
                .tracking(1.1)
                .foregroundColor(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 2)
    }
}


// MARK: - Route Enum
private enum RevealRoute: Hashable, Identifiable {
    case passDevice
    case discussion
    var id: Self { self }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        RevealRoleView()
            .environmentObject(GameViewModel())
    }
}
