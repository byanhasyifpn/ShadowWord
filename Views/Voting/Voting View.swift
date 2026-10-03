//
//  Voting View.swift
//  ShadowWord
//
//  Created by Byan Hasyif on 24/05/26.
//

import SwiftUI

struct VotingView: View {
    @EnvironmentObject private var gameVM: GameViewModel

    @State private var selectedPlayerNumber: Int?
    @State private var nextRoute: VotingRoute?
    @State private var iconFloating = false

    private var selectedPlayer: Player? {
        gameVM.player(number: selectedPlayerNumber)
    }

    // Gradient per player index (cycles)
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
                    .init(color: Color(hex: "fdf0e8"), location: 0.0),
                    .init(color: Color(hex: "ffe8f0"), location: 0.35),
                    .init(color: Color(hex: "ede8ff"), location: 0.75),
                    .init(color: Color(hex: "e8f0ff"), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Decorative blobs
            Circle()
                .fill(Color(hex: "FF6B6B").opacity(0.15))
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

            VStack(spacing: 16) {

                // Phase badge
                GamePhaseBadge(text: "PHASE 4 · VOTE", color: Color(hex: "FF6B6B"))

                // Floating icon
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FF8585"), Color(hex: "FF6B6B")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 78, height: 78)
                    .overlay(
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color(hex: "FF6B6B").opacity(0.42), radius: 14, x: 0, y: 8)
                    .offset(y: iconFloating ? -5 : 0)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: iconFloating)
                    .onAppear { iconFloating = true }

                // Title block
                VStack(spacing: 3) {
                    Text("CAST YOUR VOTE")
                        .font(.system(size: 11, weight: .heavy))
                        .tracking(0.8)
                        .foregroundColor(Color(hex: "FF6B6B"))

                    Text("Vote Suspect")
                        .font(.custom("Nunito-Black", size: 30))
                        .foregroundColor(Color(hex: "2D2852"))

                    Text("Who do you think is the impostor?")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "8B8AB0"))
                }

                // Player list
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 9) {
                        ForEach(Array(gameVM.alivePlayers.enumerated()), id: \.element.id) { index, player in
                            PlayerVoteRow(
                                player: player,
                                isSelected: selectedPlayerNumber == player.number,
                                avatarColors: avatarGradients[index % avatarGradients.count]
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                                    selectedPlayerNumber = player.number
                                }
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }

                // Finish Vote button
                Button { finishVote() } label: {
                    HStack {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color.white.opacity(selectedPlayerNumber == nil ? 0.15 : 0.25))
                                .frame(width: 34, height: 34)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white.opacity(selectedPlayerNumber == nil ? 0.6 : 1))
                                )
                            Text("Finish Vote")
                                .font(.custom("Nunito-Black", size: 18))
                                .foregroundColor(.white.opacity(selectedPlayerNumber == nil ? 0.6 : 1))
                        }
                        Spacer()
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white.opacity(selectedPlayerNumber == nil ? 0.6 : 1))
                            )
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(
                        Group {
                            if selectedPlayerNumber != nil {
                                LinearGradient(
                                    colors: [Color(hex: "FF8585"), Color(hex: "FF6B6B")],
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
                        color: selectedPlayerNumber != nil ? Color(hex: "FF6B6B").opacity(0.4) : .clear,
                        radius: 12, x: 0, y: 6
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedPlayerNumber)
                }
                .disabled(selectedPlayerNumber == nil)
                .buttonStyle(SpringButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationBarBackButtonHidden()
        .navigationDestination(item: $nextRoute) { route in
            switch route {
            case .elimination(let playerNumber):
                EliminationRevealView(playerNumber: playerNumber)
            case .discussion:
                DiscussionView()
            case .result:
                ResultView()
            }
        }
    }

    // MARK: - Logic

    private func finishVote() {
        guard let votedPlayerNumber = selectedPlayerNumber else { return }
        selectedPlayerNumber = nil
        nextRoute = .elimination(votedPlayerNumber)
    }
}

// MARK: - Player Vote Row

struct PlayerVoteRow: View {
    let player: Player
    let isSelected: Bool
    let avatarColors: [Color]
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Avatar
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(
                        LinearGradient(colors: avatarColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 42, height: 42)
                    .overlay(
                        Text("\(player.number)")
                            .font(.custom("Nunito-Black", size: 18))
                            .foregroundColor(.white)
                    )

                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(player.displayName)
                        .font(.custom("Nunito-Black", size: 15))
                        .foregroundColor(Color(hex: "2D2852"))
                    Text("Still in the game")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "AEACD0"))
                }

                Spacer()

                // Check circle
                Circle()
                    .fill(isSelected ? Color(hex: "FF6B6B") : Color.clear)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected ? Color(hex: "FF6B6B") : Color(hex: "E8E6F5"),
                                lineWidth: 2
                            )
                    )
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(isSelected ? 1 : 0)
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        isSelected ? Color(hex: "FF6B6B") : Color.clear,
                        lineWidth: 2
                    )
            )
            .shadow(
                color: isSelected
                    ? Color(hex: "FF6B6B").opacity(0.2)
                    : Color(hex: "7C5CFC").opacity(0.07),
                radius: isSelected ? 10 : 6,
                x: 0, y: 2
            )
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isSelected)
        }
        .buttonStyle(SpringButtonStyle())
    }
}

// MARK: - Mr. White Guess Sheet

struct MrWhiteGuessSheet: View {
    @Binding var guess: String
    let isGuessEmpty: Bool
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            // Handle
            Capsule()
                .fill(Color(hex: "E0DCF5"))
                .frame(width: 40, height: 4)
                .padding(.top, 8)

            // Icon
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "FF8585"), Color(hex: "FF6B6B")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                )
                .shadow(color: Color(hex: "FF6B6B").opacity(0.38), radius: 10, x: 0, y: 5)

            // Title
            VStack(spacing: 4) {
                Text("Mr. White Caught!")
                    .font(.custom("Nunito-Black", size: 22))
                    .foregroundColor(Color(hex: "2D2852"))

                Text("Guess the civilian word to steal the win")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "8B8AB0"))
                    .multilineTextAlignment(.center)
            }

            // Text field
            VStack(alignment: .leading, spacing: 6) {
                Text("YOUR GUESS")
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(0.8)
                    .foregroundColor(Color(hex: "AEACD0"))

                TextField("Type the civilian word...", text: $guess)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "2D2852"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 13)
                    .background(Color(hex: "F6F4FF"))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color(hex: "E8E4FA"), lineWidth: 2)
                    )
            }

            // Submit button
            Button(action: onSubmit) {
                HStack {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color.white.opacity(isGuessEmpty ? 0.15 : 0.25))
                            .frame(width: 34, height: 34)
                            .overlay(
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white.opacity(isGuessEmpty ? 0.6 : 1))
                            )
                        Text("Submit Guess")
                            .font(.custom("Nunito-Black", size: 17))
                            .foregroundColor(.white.opacity(isGuessEmpty ? 0.6 : 1))
                    }
                    Spacer()
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(isGuessEmpty ? 0.6 : 1))
                        )
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 15)
                .background(
                    isGuessEmpty
                        ? LinearGradient(colors: [Color(hex: "D5D0F5"), Color(hex: "C2BAF0")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color(hex: "FF8585"), Color(hex: "FF6B6B")], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: isGuessEmpty ? .clear : Color(hex: "FF6B6B").opacity(0.38), radius: 10, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isGuessEmpty)
            }
            .disabled(isGuessEmpty)
            .buttonStyle(SpringButtonStyle())

            Spacer()
        }
        .padding(.horizontal, 20)
        .background(Color.white)
    }
}

// MARK: - Route

private enum VotingRoute: Hashable, Identifiable {
    case elimination(Int)
    case discussion
    case result

    var id: Self { self }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        VotingView()
            .environmentObject(GameViewModel())
    }
}
