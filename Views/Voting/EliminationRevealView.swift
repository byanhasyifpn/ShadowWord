//
//  EliminationRevealView.swift
//  ShadowWord
//
//  Created by Byan Hasyif on 26/05/26.
//

import SwiftUI

struct EliminationRevealView: View {
    @EnvironmentObject private var gameVM: GameViewModel

    let playerNumber: Int

    @State private var nextRoute: EliminationRoute?
    @State private var isShowingMrWhiteGuess = false
    @State private var mrWhiteGuess = ""
    @State private var cardVisible = false

    private var eliminatedPlayer: Player? {
        gameVM.player(number: playerNumber)
    }

    private var isGuessEmpty: Bool {
        mrWhiteGuess.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var roleColor: Color {
        switch eliminatedPlayer?.role {
        case .undercover:
            return Color(hex: "FF6B6B")
        case .mrWhite:
            return Color(hex: "7C5CFC")
        case .civilian:
            return Color(hex: "6BCB77")
        case .none:
            return Color(hex: "AEACD0")
        }
    }

    var body: some View {
        ZStack {
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

            Circle()
                .fill(roleColor.opacity(0.14))
                .frame(width: 220, height: 220)
                .blur(radius: 44)
                .offset(x: 110, y: -210)
                .allowsHitTesting(false)

            Circle()
                .fill(Color(hex: "7C5CFC").opacity(0.10))
                .frame(width: 180, height: 180)
                .blur(radius: 40)
                .offset(x: -110, y: 260)
                .allowsHitTesting(false)

            VStack(spacing: 20) {
                GamePhaseBadge(text: "VOTE RESULT", color: roleColor, isPulsing: false)

                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [roleColor.opacity(0.75), roleColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 84, height: 84)
                    .overlay(
                        Image(systemName: "person.crop.circle.badge.xmark.fill")
                            .font(.system(size: 34))
                            .foregroundColor(.white)
                    )
                    .shadow(color: roleColor.opacity(0.42), radius: 14, x: 0, y: 8)

                VStack(spacing: 6) {
                    Text("Eliminated")
                        .font(.custom("Nunito-Black", size: 34))
                        .foregroundColor(Color(hex: "2D2852"))

                    Text(eliminatedPlayer?.displayName ?? "Player")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "8B8AB0"))
                }

                roleCard
                    .offset(y: cardVisible ? 0 : 20)
                    .opacity(cardVisible ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: cardVisible)

                Spacer()

                Button(action: continueAfterReveal) {
                    HStack {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color.white.opacity(0.25))
                                .frame(width: 34, height: 34)
                                .overlay(
                                    Image(systemName: "chevron.right.2")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            Text("Continue")
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
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "FF8585"), Color(hex: "FF6B6B")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color(hex: "FF6B6B").opacity(0.4), radius: 12, x: 0, y: 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                }
                .buttonStyle(SpringButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationBarBackButtonHidden()
        .navigationDestination(item: $nextRoute) { route in
            switch route {
            case .discussion:
                DiscussionView()
            case .result:
                ResultView()
            }
        }
        .sheet(isPresented: $isShowingMrWhiteGuess) {
            MrWhiteGuessSheet(
                guess: $mrWhiteGuess,
                isGuessEmpty: isGuessEmpty,
                onSubmit: submitMrWhiteGuess
            )
            .presentationDetents([.height(420)])
            .presentationCornerRadius(28)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                cardVisible = true
            }
        }
    }

    private var roleCard: some View {
        VStack(spacing: 12) {
            Text("ROLE REVEALED")
                .font(.system(size: 10, weight: .heavy))
                .tracking(0.8)
                .foregroundColor(Color(hex: "AEACD0"))

            Text(eliminatedPlayer?.role.displayName ?? "Unknown")
                .font(.custom("Nunito-Black", size: 28))
                .foregroundColor(roleColor)

        }
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color(hex: "7C5CFC").opacity(0.1), radius: 16, x: 0, y: 4)
    }

    private func continueAfterReveal() {
        guard let eliminatedPlayer else { return }

        if eliminatedPlayer.role == .mrWhite {
            mrWhiteGuess = ""
            isShowingMrWhiteGuess = true
            return
        }

        gameVM.finishGame(votedPlayerNumber: playerNumber)

        if gameVM.pendingMrWhiteGuessPlayerNumber != nil {
            mrWhiteGuess = ""
            isShowingMrWhiteGuess = true
            return
        }

        nextRoute = gameVM.gameState == .result ? .result : .discussion
    }

    private func submitMrWhiteGuess() {
        let mrWhiteNumber = gameVM.pendingMrWhiteGuessPlayerNumber ?? playerNumber
        gameVM.submitMrWhiteGuess(votedPlayerNumber: mrWhiteNumber, guess: mrWhiteGuess)
        isShowingMrWhiteGuess = false
        nextRoute = gameVM.gameState == .result ? .result : .discussion
    }
}

private enum EliminationRoute: Hashable, Identifiable {
    case discussion
    case result

    var id: Self { self }
}

#Preview {
    NavigationStack {
        EliminationRevealView(playerNumber: 1)
            .environmentObject(GameViewModel())
    }
}
