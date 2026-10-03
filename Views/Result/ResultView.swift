//
//  ResultView.swift
//  ShadowWord
//
//  Created by Byan Hasyif on 24/05/26.
//

import SwiftUI

struct ResultView: View {
    @EnvironmentObject private var gameVM: GameViewModel

    @State private var shouldShowSetup = false
    @State private var shouldShowPassDevice = false
    @State private var iconFloating = false
    @State private var cardsVisible = false

    private let avatarGradients: [[Color]] = [
        [Color(hex: "9B7FFE"), Color(hex: "7C5CFC")],
        [Color(hex: "72BFFF"), Color(hex: "4DA8FF")],
        [Color(hex: "FFD080"), Color(hex: "FFB84D")],
        [Color(hex: "88D98F"), Color(hex: "6BCB77")],
        [Color(hex: "FF8585"), Color(hex: "FF6B6B")],
    ]

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "f0edff"), location: 0.0),
                    .init(color: Color(hex: "ffe8f5"), location: 0.35),
                    .init(color: Color(hex: "fff0e8"), location: 0.70),
                    .init(color: Color(hex: "e8fff0"), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Decorative blobs
            Circle()
                .fill(Color(hex: "FFB84D").opacity(0.18))
                .frame(width: 200, height: 200)
                .blur(radius: 40)
                .offset(x: 110, y: -200)
                .allowsHitTesting(false)

            Circle()
                .fill(Color(hex: "6BCB77").opacity(0.14))
                .frame(width: 180, height: 180)
                .blur(radius: 40)
                .offset(x: -100, y: 260)
                .allowsHitTesting(false)

            VStack(spacing: 14) {

                // Phase badge
                GamePhaseBadge(text: "GAME OVER", color: Color(hex: "FFB84D"))

                // Trophy icon
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FFD080"), Color(hex: "FFB84D")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 84, height: 84)
                    .overlay(
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 34))
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color(hex: "FFB84D").opacity(0.48), radius: 14, x: 0, y: 8)
                    .offset(y: iconFloating ? -6 : 0)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: iconFloating)
                    .onAppear { iconFloating = true }

                // Winner card
                WinnerCard(winnerText: gameVM.winnerText)

                // Section label
                HStack(spacing: 7) {
                    Circle()
                        .fill(Color(hex: "C8C6E8"))
                        .frame(width: 7, height: 7)
                    Text("ALL PLAYERS")
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(1.0)
                        .foregroundColor(Color(hex: "AEACD0"))
                    Spacer()
                }

                // Player result cards
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 9) {
                        ForEach(Array(gameVM.players.enumerated()), id: \.element.id) { index, player in
                            PlayerResultCard(
                                player: player,
                                isEliminated: gameVM.eliminatedPlayerNumbers.contains(player.number),
                                avatarColors: avatarGradients[index % avatarGradients.count]
                            )
                            .offset(y: cardsVisible ? 0 : 20)
                            .opacity(cardsVisible ? 1 : 0)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7)
                                    .delay(Double(index) * 0.07),
                                value: cardsVisible
                            )
                        }
                    }
                    .padding(.vertical, 2)
                }

                // Play Again button
                Button {
                    gameVM.preparePlayAgain()
                    shouldShowPassDevice = gameVM.gameState == .reveal
                } label: {
                    HStack {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color.white.opacity(0.25))
                                .frame(width: 34, height: 34)
                                .overlay(
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            Text("Play Again")
                                .font(.custom("Nunito-Black", size: 18))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "9B7FFE"), Color(hex: "7C5CFC")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color(hex: "7C5CFC").opacity(0.42), radius: 12, x: 0, y: 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                }
                .buttonStyle(SpringButtonStyle())

                Button {
                    gameVM.resetGameToSetup()
                    shouldShowSetup = true
                } label: {
                    HStack {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color(hex: "FF6B6B").opacity(0.12))
                                .frame(width: 34, height: 34)
                                .overlay(
                                    Image(systemName: "xmark")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(Color(hex: "FF6B6B"))
                                )
                            Text("Reset Game")
                                .font(.custom("Nunito-Black", size: 17))
                                .foregroundColor(Color(hex: "FF6B6B"))
                        }
                        Spacer()
                        Circle()
                            .fill(Color(hex: "FF6B6B").opacity(0.1))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(hex: "FF6B6B"))
                            )
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color(hex: "FF6B6B").opacity(0.10), radius: 10, x: 0, y: 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color(hex: "FF6B6B").opacity(0.16), lineWidth: 1)
                    )
                }
                .buttonStyle(SpringButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationBarBackButtonHidden()
        .navigationDestination(isPresented: $shouldShowPassDevice) {
            PassDeviceView()
        }
        .navigationDestination(isPresented: $shouldShowSetup) {
            SetupGameView()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                cardsVisible = true
            }
        }
    }
}

// MARK: - Winner Card

struct WinnerCard: View {
    let winnerText: String

    // Detect who won from winnerText for styling
    private var isCivilian: Bool {
        winnerText.lowercased().contains("civilian")
    }

    private var accentColor: Color {
        isCivilian ? Color(hex: "6BCB77") : Color(hex: "FF6B6B")
    }
    private var badgeText: String {
        isCivilian ? "The impostor has been caught" : "The impostor escaped!"
    }

    var body: some View {
        VStack(spacing: 7) {
            Text("WINNER")
                .font(.system(size: 10, weight: .heavy))
                .tracking(0.8)
                .foregroundColor(Color(hex: "AEACD0"))

            Text(winnerText)
                .font(.custom("Nunito-Black", size: 20))
                .foregroundColor(Color(hex: "2D2852"))
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            HStack(spacing: 5) {
                Circle()
                    .fill(accentColor)
                    .frame(width: 6, height: 6)
                Text(badgeText)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(accentColor)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 5)
            .background(accentColor.opacity(0.12))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color(hex: "7C5CFC").opacity(0.09), radius: 14, x: 0, y: 4)
    }
}

// MARK: - Player Result Card

struct PlayerResultCard: View {
    let player: Player
    let isEliminated: Bool
    let avatarColors: [Color]

    private var roleColor: Color {
        switch player.role {
        case .undercover: return Color(hex: "FF6B6B")
        case .mrWhite:  return Color(hex: "7C5CFC")
        default:        return Color(hex: "6BCB77")
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Avatar with optional eliminated X overlay
            ZStack {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(
                        LinearGradient(colors: avatarColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 42, height: 42)
                    .overlay(
                        Text("\(player.number)")
                            .font(.custom("Nunito-Black", size: 17))
                            .foregroundColor(.white)
                    )

                if isEliminated {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(Color(hex: "FF6B6B").opacity(0.2))
                        .frame(width: 42, height: 42)
                        .overlay(
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "FF6B6B"))
                        )
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(player.displayName)
                    .font(.custom("Nunito-Black", size: 14))
                    .foregroundColor(Color(hex: "2D2852"))

                Text(player.role.displayName.uppercased())
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(0.4)
                    .foregroundColor(roleColor)
            }

            Spacer()

            // Word or eliminated pill
            if isEliminated {
                Text("ELIMINATED")
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(0.5)
                    .foregroundColor(Color(hex: "FF6B6B"))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color(hex: "FF6B6B").opacity(0.11))
                    .clipShape(Capsule())
            } else {
                Text(player.word ?? "No word")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "8B8AB0"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "F6F4FF"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color(hex: "7C5CFC").opacity(0.07), radius: 8, x: 0, y: 2)
        .opacity(isEliminated ? 0.75 : 1)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ResultView()
            .environmentObject(GameViewModel())
    }
}
