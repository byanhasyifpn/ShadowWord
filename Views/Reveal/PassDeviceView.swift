//
//  PassDeviceView.swift
//  ShadowWord
//
//  Created by Byan Hasyif on 24/05/26.
//

import SwiftUI

struct PassDeviceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var gameVM: GameViewModel

    @State private var cardVisible = false
    @State private var playerName = ""
    @State private var nextRoute: PassDeviceRoute?

    private var trimmedPlayerName: String {
        playerName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canContinue: Bool {
        !trimmedPlayerName.isEmpty
    }

    var body: some View {
        ZStack {
            // Background gradient matching Discussion theme
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "eef2ff"), location: 0.0),
                    .init(color: Color(hex: "f5eeff"), location: 0.35),
                    .init(color: Color(hex: "ffe8f5"), location: 0.75),
                    .init(color: Color(hex: "fff0e8"), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color(hex: "7C5CFC").opacity(0.15))
                .frame(width: 200, height: 200)
                .blur(radius: 40)
                .offset(x: 110, y: -200)
                .allowsHitTesting(false)

            Circle()
                .fill(Color(hex: "4DA8FF").opacity(0.12))
                .frame(width: 180, height: 180)
                .blur(radius: 40)
                .offset(x: -100, y: 250)
                .allowsHitTesting(false)

            if let player = gameVM.currentPlayer {
                VStack(spacing: 20) {
                    GamePhaseBadge(
                        text: "PHASE 2 · PASS DEVICE",
                        color: Color(hex: "7C5CFC"),
                        isPulsing: false
                    )

                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "9B7FFE"), Color(hex: "7C5CFC")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "hand.point.right.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        )
                        .shadow(color: Color(hex: "7C5CFC").opacity(0.45), radius: 14, x: 0, y: 8)

                    VStack(spacing: 4) {
                        Text("Hand it over!")
                            .font(.system(size: 12, weight: .heavy))
                            .tracking(0.8)
                            .foregroundColor(Color(hex: "7C5CFC"))
                            .textCase(.uppercase)

                        Text("Pass Device")
                            .font(.custom("Nunito-Black", size: 32))
                            .foregroundColor(Color(hex: "2D2852"))

                        Text("Next player, get ready\nto see your secret role")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "8B8AB0"))
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }

                    playerCard(for: player)
                        .offset(y: cardVisible ? 0 : 20)
                        .opacity(cardVisible ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: cardVisible)

                    Spacer()

                    Button(action: showRole) {
                        HStack {
                            HStack(spacing: 11) {
                                Circle()
                                    .fill(Color.white.opacity(canContinue ? 0.25 : 0.15))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(.white.opacity(canContinue ? 1 : 0.6))
                                    )
                                Text("I'm Ready")
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
                                        .foregroundColor(.white.opacity(canContinue ? 1 : 0.6))
                                )
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 17)
                        .background(
                            canContinue
                                ? LinearGradient(colors: [Color(hex: "9B7FFE"), Color(hex: "7C5CFC")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color(hex: "D5D0F5"), Color(hex: "C2BAF0")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: canContinue ? Color(hex: "7C5CFC").opacity(0.45) : .clear, radius: 14, x: 0, y: 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: canContinue)
                    }
                    .disabled(!canContinue)
                    .buttonStyle(SpringButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }

            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }

                    Spacer()
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .navigationBarBackButtonHidden()
        .navigationDestination(item: $nextRoute) { route in
            switch route {
            case .revealRole:
                RevealRoleView()
            }
        }
        .onAppear {
            playerName = gameVM.currentPlayer?.name ?? ""
            nextRoute = nil
            cardVisible = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                cardVisible = true
            }
        }
    }

    private func playerCard(for player: Player) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "9B7FFE"), Color(hex: "7C5CFC")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text("\(player.number)")
                            .font(.custom("Nunito-Black", size: 20))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("UP NEXT")
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(0.5)
                        .foregroundColor(Color(hex: "AEACD0"))

                    Text(player.displayName)
                        .font(.custom("Nunito-Black", size: 18))
                        .foregroundColor(Color(hex: "2D2852"))
                }

                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("PLAYER NAME")
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(0.6)
                    .foregroundColor(Color(hex: "AEACD0"))

                TextField("Enter player name", text: $playerName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "2D2852"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(hex: "F6F4FF"))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(canContinue ? Color(hex: "E8E4FA") : Color(hex: "FF6B6B").opacity(0.25), lineWidth: 2)
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color(hex: "7C5CFC").opacity(0.1), radius: 14, x: 0, y: 4)
    }

    private func showRole() {
        gameVM.updateCurrentPlayerName(playerName)

        withAnimation(.easeInOut(duration: 0.25)) {
            nextRoute = .revealRole
        }
    }
}

private enum PassDeviceRoute: Hashable, Identifiable {
    case revealRole

    var id: Self { self }
}

#Preview {
    NavigationStack {
        PassDeviceView()
            .environmentObject(GameViewModel())
    }
}
