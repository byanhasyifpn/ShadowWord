//
//  HomeView.swift
//  ShadowWord
//
//  Created by Byan Hasyif on 24/05/26.
//

import SwiftUI

// MARK: - Color Extension
extension Color {
    static let gamePurple = Color(hex: "7C5CFC")
    static let gameBlue   = Color(hex: "4DA8FF")
    static let gameOrange = Color(hex: "FFB84D")
    static let gameGreen  = Color(hex: "6BCB77")
    static let gameRed    = Color(hex: "FF6B6B")
    static let gameBG     = Color(hex: "F4F7FB")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int & 0xFF)          / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Animated Background Blobs
struct GameBackground: View {
    var body: some View {
        ZStack {
            Color.gameBG.ignoresSafeArea()
            Circle()
                .fill(Color.gamePurple.opacity(0.22))
                .frame(width: 260, height: 260)
                .blur(radius: 60)
                .offset(x: -100, y: -180)
            Circle()
                .fill(Color.gameBlue.opacity(0.20))
                .frame(width: 220, height: 220)
                .blur(radius: 55)
                .offset(x: 120, y: -100)
            Circle()
                .fill(Color.gameOrange.opacity(0.18))
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .offset(x: -110, y: 100)
            Circle()
                .fill(Color.gameGreen.opacity(0.16))
                .frame(width: 180, height: 180)
                .blur(radius: 48)
                .offset(x: 130, y: 280)
        }
    }
}

// MARK: - Logo Icon Badge
struct IconBadge: View {
    let gradient: [Color]
    let icon: String

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 22, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 50, height: 50)
            .background(
                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: gradient.first!.opacity(0.35), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Stat Pill
struct StatPill: View {
    let icon: String
    let iconColor: Color
    let iconBG: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 30, height: 30)
                .background(iconBG)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(Color(hex: "2D3042"))
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(1.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.gameBG)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - How To Play Step
struct HowToStep: View {
    let number: Int
    let text: String
    let gradient: [Color]

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(number == 3 ? Color(hex: "8A5A00") : .white)
                .frame(width: 28, height: 28)
                .background(
                    LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            Text(text)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "4A5060"))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 5)
        }
    }
}

// MARK: - Chunky Game Button Style
struct GameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .shadow(
                color: Color.gamePurple.opacity(configuration.isPressed ? 0.20 : 0.38),
                radius: configuration.isPressed ? 4 : 16,
                x: 0, y: configuration.isPressed ? 2 : 6
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - HomeView
struct HomeView: View {
    @State private var logoAppeared = false
    @State private var cardAppeared = false
    @State private var howCardAppeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                GameBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 40)

                        // MARK: Logo
                        VStack(spacing: 14) {
                            HStack(spacing: 10) {
                                IconBadge(
                                    gradient: [Color.gamePurple, Color(hex: "9B7EFF")],
                                    icon: "person.fill"
                                )
                                IconBadge(
                                    gradient: [Color.gameBlue, Color(hex: "74BEFF")],
                                    icon: "shield.fill"
                                )
                                IconBadge(
                                    gradient: [Color.gameOrange, Color(hex: "FFD07A")],
                                    icon: "checkmark.square.fill"
                                )
                            }

                            Text("SHADOWWORD")
                                .font(.system(size: 38, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.gamePurple, Color.gameBlue, Color.gameOrange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .tracking(-1.5)

                            Text("SOCIAL DEDUCTION GAME")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                                .tracking(3)
                        }
                        .scaleEffect(logoAppeared ? 1 : 0.7)
                        .opacity(logoAppeared ? 1 : 0)
                        .onAppear {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                                logoAppeared = true
                            }
                        }

                        Spacer().frame(height: 36)

                        // MARK: Main Card
                        VStack(spacing: 14) {
                            // "Ready to play" label
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.gameGreen)
                                    .frame(width: 8, height: 8)
                                Text("Ready to play")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                    .tracking(2.5)
                            }

                            // Start Game Button
                            NavigationLink {
                                SetupGameView()
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 34, height: 34)
                                        .background(Color.white.opacity(0.22))
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                                    Text("Start Game")
                                        .font(.system(size: 20, weight: .black, design: .rounded))
                                        .foregroundColor(.white)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white.opacity(0.55))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [Color.gamePurple, Color(hex: "9B7EFF")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            }
                            .buttonStyle(GameButtonStyle())

                            // Stats Row
                            HStack(spacing: 12) {
                                StatPill(
                                    icon: "person.2.fill",
                                    iconColor: Color.gameBlue,
                                    iconBG: Color.gameBlue.opacity(0.12),
                                    value: "3–10",
                                    label: "Players"
                                )
                                StatPill(
                                    icon: "clock.fill",
                                    iconColor: Color.gameOrange,
                                    iconBG: Color.gameOrange.opacity(0.12),
                                    value: "15m",
                                    label: "Avg game"
                                )
                                StatPill(
                                    icon: "star.fill",
                                    iconColor: Color.gameGreen,
                                    iconBG: Color.gameGreen.opacity(0.12),
                                    value: "Fun",
                                    label: "Guaranteed"
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 26)
                        .background(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(.white)
                                .shadow(color: Color.gamePurple.opacity(0.10), radius: 24, x: 0, y: 8)
                                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                        )
                        .padding(.horizontal, 20)
                        .offset(y: cardAppeared ? 0 : 30)
                        .opacity(cardAppeared ? 1 : 0)
                        .onAppear {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.2)) {
                                cardAppeared = true
                            }
                        }

                        Spacer().frame(height: 16)

                        // MARK: How To Play Card
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 7) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.gamePurple)
                                Text("HOW TO PLAY")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.gamePurple)
                                    .tracking(2)
                            }

                            HowToStep(
                                number: 1,
                                text: "Everyone gets a secret word — one player gets a different one",
                                gradient: [Color.gamePurple, Color(hex: "9B7EFF")]
                            )
                            HowToStep(
                                number: 2,
                                text: "Give clues about your word without revealing it",
                                gradient: [Color.gameBlue, Color(hex: "74BEFF")]
                            )
                            HowToStep(
                                number: 3,
                                text: "Vote to eliminate the undercover player!",
                                gradient: [Color.gameOrange, Color(hex: "FFD07A")]
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.gamePurple.opacity(0.07), Color.gameBlue.opacity(0.07)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(Color.gamePurple.opacity(0.13), lineWidth: 1.5)
                                )
                        )
                        .padding(.horizontal, 20)
                        .offset(y: howCardAppeared ? 0 : 30)
                        .opacity(howCardAppeared ? 1 : 0)
                        .onAppear {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.32)) {
                                howCardAppeared = true
                            }
                        }

                        Spacer().frame(height: 28)

                        // Footer hint
                        HStack(spacing: 8) {
                            Circle().fill(Color.secondary.opacity(0.3)).frame(width: 5, height: 5)
                            Text("Made for parties and game nights")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                            Circle().fill(Color.secondary.opacity(0.3)).frame(width: 5, height: 5)
                        }
                        .opacity(howCardAppeared ? 1 : 0)
                        .animation(.easeIn.delay(0.5), value: howCardAppeared)

                        Spacer().frame(height: 32)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}
