//
//  SetupGameView.swift
//  ShadowWord
//
//  Created by Byan Hasyif on 24/05/26.
//

import SwiftUI

struct SetupGameView: View {
    @EnvironmentObject private var gameVM: GameViewModel

    @State private var totalPlayers = 5
    @State private var undercoverCount = 1
    @State private var mrWhiteCount = 1
    @State private var shouldShowPassDevice = false

    @State private var cardAppeared = false
    @State private var previewAppeared = false

    private var isSetupValid: Bool {
        gameVM.isValidSetup(
            totalPlayers: totalPlayers,
            undercoverCount: undercoverCount,
            mrWhiteCount: mrWhiteCount
        )
    }

    private var citizenCount: Int {
        max(0, totalPlayers - undercoverCount - mrWhiteCount)
    }

    private var maxSpecialRoleCount: Int {
        gameVM.maxSpecialRoleCount(for: totalPlayers)
    }

    private var maxMrWhiteCount: Int {
        totalPlayers == 3 ? 0 : maxSpecialRoleCount
    }

    var body: some View {
        ZStack {
            GameBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    Spacer().frame(height: 8)

                    // MARK: Roles & Steppers Card
                    VStack(spacing: 0) {
                        SectionLabel(text: "Players & Roles", dotColor: .gamePurple)

                        RoleStepperRow(
                            icon: "person.fill",
                            iconGradient: [.gamePurple, Color(hex: "9B7EFF")],
                            title: "Total Players",
                            hint: "Min 3",
                            value: $totalPlayers,
                            minimum: 3,
                            maximum: nil
                        )
                        Divider().padding(.horizontal, 4)

                        RoleStepperRow(
                            icon: "person.fill.questionmark",
                            iconGradient: [.gameRed, Color(hex: "FF9494")],
                            title: "Undercover",
                            hint: "Max 1/3 players",
                            value: $undercoverCount,
                            minimum: 1,
                            maximum: maxSpecialRoleCount
                        )
                        Divider().padding(.horizontal, 4)

                        RoleStepperRow(
                            icon: "person.fill.xmark",
                            iconGradient: [.gameOrange, Color(hex: "FFD07A")],
                            title: "Mr. White",
                            hint: totalPlayers == 3 ? "Unavailable for 3 players" : "Max 1/3 players",
                            value: $mrWhiteCount,
                            minimum: 0,
                            maximum: maxMrWhiteCount
                        )
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.white)
                            .shadow(color: Color.gamePurple.opacity(0.08), radius: 16, x: 0, y: 4)
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
                    )
                    .offset(y: cardAppeared ? 0 : 24)
                    .opacity(cardAppeared ? 1 : 0)

                    // MARK: Player Preview Card
                    VStack(alignment: .leading, spacing: 14) {
                        SectionLabel(text: "Player Preview", dotColor: .gameBlue)

                        // Dot grid
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.fixed(34), spacing: 8), count: 8),
                            spacing: 8
                        ) {
                            ForEach(0..<totalPlayers, id: \.self) { i in
                                PlayerDot(
                                    role: i < undercoverCount ? .undercover
                                        : i < undercoverCount + mrWhiteCount ? .mrWhite
                                        : .citizen
                                )
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: totalPlayers)
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: undercoverCount)
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: mrWhiteCount)

                        // Legend
                        HStack(spacing: 16) {
                            RoleLegendItem(color: .gameBlue, label: "Citizen")
                            RoleLegendItem(color: .gameRed, label: "Undercover")
                            RoleLegendItem(color: Color(hex: "8A8A9A"), label: "Mr. White")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.white)
                            .shadow(color: Color.gameBlue.opacity(0.08), radius: 16, x: 0, y: 4)
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
                    )
                    .offset(y: previewAppeared ? 0 : 24)
                    .opacity(previewAppeared ? 1 : 0)

                    // MARK: Validation Warning
                    if !isSetupValid {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.gameRed)
                                .frame(width: 28, height: 28)
                                .background(Color.gameRed.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

                            Text("Too many special roles! Civilian players must stay greater than Undercover + Mr. White.")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "CC3333"))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.gameRed.opacity(0.07))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.gameRed.opacity(0.20), lineWidth: 1.5)
                                )
                        )
                        .transition(.scale(scale: 0.95).combined(with: .opacity))
                    }

                    // MARK: Generate Button
                    Button {
                        gameVM.setupGame(
                            totalPlayers: totalPlayers,
                            undercoverCount: undercoverCount,
                            mrWhiteCount: mrWhiteCount
                        )
                        shouldShowPassDevice = gameVM.gameState == .reveal
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.22))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                            Text("Generate Game")
                                .font(.system(size: 19, weight: .black, design: .rounded))
                                .foregroundColor(.white)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.55))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(
                            Group {
                                if isSetupValid {
                                    LinearGradient(
                                        colors: [.gamePurple, Color(hex: "9B7EFF")],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                } else {
                                    LinearGradient(
                                        colors: [Color(hex: "C4C4D4"), Color(hex: "DDDDE8")],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .disabled(!isSetupValid)
                    .buttonStyle(GameButtonStyle())
                    .shadow(
                        color: isSetupValid ? Color.gamePurple.opacity(0.35) : .clear,
                        radius: 16, x: 0, y: 6
                    )
                    .animation(.easeInOut(duration: 0.2), value: isSetupValid)

                    Spacer().frame(height: 16)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Game Setup")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: "2D3042"))
                    Text("CONFIGURE YOUR SESSION")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                        .tracking(2)
                }
            }
        }
        .navigationDestination(isPresented: $shouldShowPassDevice) {
            PassDeviceView()
        }
        .onAppear {
            loadLastSetup()
            clampRoleCounts()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.1)) {
                cardAppeared = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.22)) {
                previewAppeared = true
            }
        }
        .onChange(of: totalPlayers) { _, _ in
            clampRoleCounts()
        }
    }

    private func loadLastSetup() {
        totalPlayers = gameVM.lastTotalPlayers
        undercoverCount = gameVM.lastUndercoverCount
        mrWhiteCount = gameVM.lastMrWhiteCount
    }

    private func clampRoleCounts() {
        undercoverCount = min(max(1, undercoverCount), maxSpecialRoleCount)
        mrWhiteCount = min(max(0, mrWhiteCount), maxMrWhiteCount)

        while !isSetupValid && mrWhiteCount > 0 {
            mrWhiteCount -= 1
        }

        while !isSetupValid && undercoverCount > 1 {
            undercoverCount -= 1
        }
    }
}

// MARK: - Role Enum
enum PlayerRole { case citizen, undercover, mrWhite }

// MARK: - Section Label
struct SectionLabel: View {
    let text: String
    let dotColor: Color

    var body: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(dotColor)
                .frame(width: 7, height: 7)
            Text(text.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .tracking(2.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 14)
    }
}

// MARK: - Role Stepper Row
struct RoleStepperRow: View {
    let icon: String
    let iconGradient: [Color]
    let title: String
    let hint: String
    @Binding var value: Int
    let minimum: Int
    let maximum: Int?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    LinearGradient(colors: iconGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "2D3042"))
                Text(hint)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 10) {
                Button {
                    if value > minimum {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) { value -= 1 }
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.gamePurple)
                        .frame(width: 34, height: 34)
                        .background(Color.gameBG)
                        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                }
                .buttonStyle(ScaleButtonStyle())

                Text("\(value)")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "2D3042"))
                    .frame(minWidth: 28)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: value)

                Button {
                    if maximum.map({ value < $0 }) ?? true {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) { value += 1 }
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(
                            LinearGradient(colors: [.gamePurple, Color(hex: "9B7EFF")],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.vertical, 14)
    }
}

// MARK: - Player Dot
struct PlayerDot: View {
    let role: PlayerRole

    var color: [Color] {
        switch role {
        case .citizen:    return [Color(hex: "4DA8FF"), Color(hex: "74BEFF")]
        case .undercover: return [Color(hex: "FF6B6B"), Color(hex: "FF9494")]
        case .mrWhite:    return [Color(hex: "8A8A9A"), Color(hex: "B4B4C4")]
        }
    }
    var label: String {
        switch role {
        case .citizen:    return "C"
        case .undercover: return "U"
        case .mrWhite:    return "W"
        }
    }

    var body: some View {
        Text(label)
            .font(.system(size: 12, weight: .black, design: .rounded))
            .foregroundColor(.white)
            .frame(width: 34, height: 34)
            .background(
                LinearGradient(colors: color, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
    }
}

// MARK: - Role Legend Item
struct RoleLegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Scale Button Style (for +/- buttons)
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
