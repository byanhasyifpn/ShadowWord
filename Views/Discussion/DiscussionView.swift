//
//  DiscussionView.swift
//  ShadowWord
//
//  Created by Byan Hasyif on 24/05/26.
//

import SwiftUI

// MARK: - Discussion View
struct DiscussionView: View {
    @EnvironmentObject private var gameVM: GameViewModel
    @State private var iconFloating = false

    var body: some View {
        ZStack {
            // Soft gradient background
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

            // Decorative blobs
            Circle()
                .fill(Color(hex: "FFB84D").opacity(0.18))
                .frame(width: 220, height: 220)
                .blur(radius: 40)
                .offset(x: 100, y: -200)
                .allowsHitTesting(false)

            Circle()
                .fill(Color(hex: "7C5CFC").opacity(0.12))
                .frame(width: 200, height: 200)
                .blur(radius: 40)
                .offset(x: -100, y: 260)
                .allowsHitTesting(false)

            VStack(spacing: 22) {

                // Phase badge
                PhaseBadge()

                // Floating icon
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
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 34))
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color(hex: "FFB84D").opacity(0.45), radius: 14, x: 0, y: 8)
                    .onAppear { iconFloating = true }

                // Title block
                VStack(spacing: 6) {
                    Text("Discussion")
                        .font(.custom("Nunito-Black", size: 36))
                        .foregroundColor(Color(hex: "2D2852"))

                    Text("Talk it out — who's giving\nsuspicious clues?")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "8B8AB0"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                // First clue card
                FirstClueCard(player: gameVM.startingCluePlayer)

                Spacer()

                // Start Voting button
                StartVotingButton()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Phase Badge
struct PhaseBadge: View {
    var body: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(Color(hex: "FFB84D"))
                .frame(width: 9, height: 9)
                .shadow(color: Color(hex: "FFB84D").opacity(0.4), radius: 3)

            Text("PHASE 3 · DISCUSSION")
                .font(.system(size: 11, weight: .heavy))
                .tracking(1.2)
                .foregroundColor(Color(hex: "FFB84D"))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 9)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 2)
    }
}

// MARK: - First Clue Card
struct FirstClueCard: View {
    let player: Player?

    private var playerName: String {
        player?.displayName ?? "Player"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 7) {
                Circle()
                    .fill(Color(hex: "C8C6E8"))
                    .frame(width: 8, height: 8)
                Text("FIRST CLUE")
                    .font(.system(size: 10.5, weight: .heavy))
                    .tracking(1.1)
                    .foregroundColor(Color(hex: "AEACD0"))
            }

            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FFD080"), Color(hex: "FFB84D")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "quote.bubble.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(playerName)
                        .font(.custom("Nunito-Black", size: 18))
                        .foregroundColor(Color(hex: "2D2852"))
                    Text("starts by saying one clue")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "8B8AB0"))
                }

                Spacer()
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color(hex: "7C5CFC").opacity(0.1), radius: 16, x: 0, y: 4)
    }
}

// MARK: - Start Voting Button
struct StartVotingButton: View {
    @State private var isPressed = false

    var body: some View {
        NavigationLink {
            VotingView()
        } label: {
            HStack {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 38, height: 38)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        )

                    Text("Start Voting")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.white)
                }

                Spacer()

                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color(hex: "FF8585"), Color(hex: "FF6B6B")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color(hex: "FF6B6B").opacity(0.45), radius: 14, x: 0, y: 6)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(SpringButtonStyle())
    }
}

// MARK: - Spring Button Style
struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}


// MARK: - Preview
#Preview {
    NavigationStack {
        DiscussionView()
            .environmentObject(GameViewModel())
    }
}
