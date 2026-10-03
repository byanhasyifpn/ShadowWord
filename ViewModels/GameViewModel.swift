//
//  GameViewModel.swift
//  ShadowWord
//
//  Created by Byan Hasyif on 24/05/26.
//

import Combine
import Foundation

final class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .home
    @Published var players: [Player] = []
    @Published var currentRevealIndex = 0
    @Published var selectedWordPair: WordPair?
    @Published var eliminatedPlayerNumbers: Set<Int> = []
    @Published var winnerText = ""
    @Published var startingCluePlayerNumber: Int?
    @Published var pendingMrWhiteGuessPlayerNumber: Int?
    @Published private(set) var lastTotalPlayers = 5
    @Published private(set) var lastUndercoverCount = 1
    @Published private(set) var lastMrWhiteCount = 1

    private(set) var wordPairs: [WordPair]
    private var usedWordPairs: [WordPair] = []

    init(wordPairs: [WordPair] = GameViewModel.loadWordPairs()) {
        self.wordPairs = wordPairs.isEmpty ? Self.fallbackWordPairs : wordPairs
    }

    var currentPlayer: Player? {
        guard players.indices.contains(currentRevealIndex) else { return nil }
        return players[currentRevealIndex]
    }

    var alivePlayers: [Player] {
        players.filter { !eliminatedPlayerNumbers.contains($0.number) }
    }

    var civilianWord: String? {
        selectedWordPair?.civilian
    }

    var startingCluePlayer: Player? {
        player(number: startingCluePlayerNumber)
    }

    func setupGame(
        totalPlayers: Int,
        undercoverCount: Int,
        mrWhiteCount: Int
    ) {
        guard isValidSetup(
            totalPlayers: totalPlayers,
            undercoverCount: undercoverCount,
            mrWhiteCount: mrWhiteCount
        ) else { return }

        lastTotalPlayers = totalPlayers
        lastUndercoverCount = undercoverCount
        lastMrWhiteCount = mrWhiteCount

        startNewRound(
            totalPlayers: totalPlayers,
            undercoverCount: undercoverCount,
            mrWhiteCount: mrWhiteCount
        )
    }

    func nextPlayer() {
        guard !players.isEmpty else {
            gameState = .home
            return
        }

        if currentRevealIndex < players.count - 1 {
            currentRevealIndex += 1
        } else {
            prepareDiscussionStarter()
            gameState = .discussion
        }
    }

    func updateCurrentPlayerName(_ name: String) {
        guard players.indices.contains(currentRevealIndex) else { return }
        players[currentRevealIndex].name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func player(number: Int?) -> Player? {
        guard let number else { return nil }
        return players.first { $0.number == number }
    }

    func finishGame(votedPlayerNumber: Int?) {
        if let votedPlayerNumber {
            eliminatedPlayerNumbers.insert(votedPlayerNumber)
        }

        updateGameStateAfterElimination()
    }

    func submitMrWhiteGuess(votedPlayerNumber: Int, guess: String) {
        guard player(number: votedPlayerNumber)?.role == .mrWhite else { return }

        pendingMrWhiteGuessPlayerNumber = nil

        if isCorrectCivilianWordGuess(guess) {
            winnerText = "Mr. White Wins"
            gameState = .result
        } else {
            eliminatedPlayerNumbers.insert(votedPlayerNumber)
            updateGameStateAfterElimination()
        }
    }

    func preparePlayAgain() {
        let namesByNumber = Dictionary(
            uniqueKeysWithValues: players.map { ($0.number, $0.name) }
        )

        guard isValidSetup(
            totalPlayers: lastTotalPlayers,
            undercoverCount: lastUndercoverCount,
            mrWhiteCount: lastMrWhiteCount
        ) else {
            resetGameToSetup()
            return
        }

        startNewRound(
            totalPlayers: lastTotalPlayers,
            undercoverCount: lastUndercoverCount,
            mrWhiteCount: lastMrWhiteCount,
            namesByNumber: namesByNumber
        )
    }

    func resetGameToSetup() {
        players.removeAll()
        eliminatedPlayerNumbers.removeAll()
        selectedWordPair = nil
        usedWordPairs.removeAll()
        currentRevealIndex = 0
        startingCluePlayerNumber = nil
        pendingMrWhiteGuessPlayerNumber = nil
        winnerText = ""
        gameState = .setup
    }

    func restartGame() {
        players.removeAll()
        eliminatedPlayerNumbers.removeAll()
        selectedWordPair = nil
        usedWordPairs.removeAll()
        currentRevealIndex = 0
        startingCluePlayerNumber = nil
        pendingMrWhiteGuessPlayerNumber = nil
        winnerText = ""
        gameState = .home
    }

    func isValidSetup(
        totalPlayers: Int,
        undercoverCount: Int,
        mrWhiteCount: Int
    ) -> Bool {
        let specialRoleCount = undercoverCount + mrWhiteCount
        let civilianCount = totalPlayers - specialRoleCount
        let maxRoleCount = maxSpecialRoleCount(for: totalPlayers)

        return totalPlayers >= 3
            && undercoverCount >= 1
            && mrWhiteCount >= 0
            && undercoverCount <= maxRoleCount
            && mrWhiteCount <= maxRoleCount
            && civilianCount > specialRoleCount
            && (totalPlayers != 3 || mrWhiteCount == 0)
    }

    func maxSpecialRoleCount(for totalPlayers: Int) -> Int {
        guard totalPlayers > 3 else { return 1 }
        return max(1, totalPlayers / 3)
    }

    private func startNewRound(
        totalPlayers: Int,
        undercoverCount: Int,
        mrWhiteCount: Int,
        namesByNumber: [Int: String] = [:]
    ) {
        players.removeAll()
        eliminatedPlayerNumbers.removeAll()
        startingCluePlayerNumber = nil
        pendingMrWhiteGuessPlayerNumber = nil
        winnerText = ""

        selectedWordPair = nextUnusedWordPair()
        guard let pair = selectedWordPair else { return }

        var roles = Array(repeating: Role.undercover, count: undercoverCount)
        roles += Array(repeating: Role.mrWhite, count: mrWhiteCount)
        roles += Array(
            repeating: Role.civilian,
            count: totalPlayers - undercoverCount - mrWhiteCount
        )
        roles.shuffle()

        players = roles.enumerated().map { index, role in
            let number = index + 1
            return Player(
                number: number,
                role: role,
                word: word(for: role, in: pair),
                name: namesByNumber[number] ?? ""
            )
        }

        currentRevealIndex = 0
        gameState = .reveal
    }

    private func nextUnusedWordPair() -> WordPair? {
        if usedWordPairs.count >= wordPairs.count {
            usedWordPairs.removeAll()
        }

        let availablePairs = wordPairs.filter { !usedWordPairs.contains($0) }

        guard let selected = (availablePairs.isEmpty
                              ? wordPairs
                              : availablePairs).randomElement() else {
            return nil
        }

        usedWordPairs.append(selected)

        let useSwap = Bool.random()

        let finalPair = useSwap
            ? WordPair(
                civilian: selected.undercover,
                undercover: selected.civilian
            )
            : selected

        return finalPair
    }

    private func word(for role: Role, in pair: WordPair) -> String? {
        switch role {
        case .civilian:
            return pair.civilian
        case .undercover:
            return pair.undercover
        case .mrWhite:
            return nil
        }
    }

    private func isCorrectCivilianWordGuess(_ guess: String) -> Bool {
        guard let civilianWord else { return false }
        return normalized(guess) == normalized(civilianWord)
    }

    private func normalized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).localizedLowercase
    }

    private func prepareDiscussionStarter() {
        startingCluePlayerNumber = alivePlayers
            .filter { $0.role != .mrWhite }
            .randomElement()?
            .number
    }

    private func updateGameStateAfterElimination() {
        if let mrWhiteNumber = mrWhitePlayerNumberForFinalGuess() {
            pendingMrWhiteGuessPlayerNumber = mrWhiteNumber
            winnerText = ""
            return
        }

        pendingMrWhiteGuessPlayerNumber = nil

        if let winnerText = winnerTextAfterCurrentEliminations() {
            self.winnerText = winnerText
            gameState = .result
        } else {
            winnerText = ""
            prepareDiscussionStarter()
            gameState = .discussion
        }
    }

    private func mrWhitePlayerNumberForFinalGuess() -> Int? {
        let alive = alivePlayers
        guard alive.count == 2,
              let mrWhite = alive.first(where: { $0.role == .mrWhite }),
              alive.contains(where: { $0.role == .civilian || $0.role == .undercover }) else {
            return nil
        }

        return mrWhite.number
    }

    private func winnerTextAfterCurrentEliminations() -> String? {
        let civilianCount = alivePlayers.filter { $0.role == .civilian }.count
        let undercoverCount = alivePlayers.filter { $0.role == .undercover }.count
        let mrWhiteCount = alivePlayers.filter { $0.role == .mrWhite }.count

        if civilianCount == 1 && undercoverCount == 1 && mrWhiteCount == 0 {
            return "Undercover Wins"
        }

        if civilianCount == 0 && undercoverCount > 0 && mrWhiteCount == 0 {
            return "Undercover Wins"
        }

        if civilianCount == 0 && undercoverCount == 0 && mrWhiteCount > 0 {
            return "Mr. White Wins"
        }

        if undercoverCount == 0 && mrWhiteCount == 0 {
            return "Civilian Wins"
        }

        return nil
    }

    private static func loadWordPairs() -> [WordPair] {
        guard let url = Bundle.main.url(forResource: "words", withExtension: "geojson"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([WordPair].self, from: data) else {
            return fallbackWordPairs
        }

        return decoded
    }

    private static let fallbackWordPairs: [WordPair] = [
            WordPair(civilian: "Kucing", undercover: "Macan"),
            WordPair(civilian: "Nasi", undercover: "Bubur"),
            WordPair(civilian: "Danau", undercover: "Kolam"),
            WordPair(civilian: "Teh", undercover: "Susu"),
            WordPair(civilian: "Manga", undercover: "Pepaya"),
            WordPair(civilian: "Sepeda", undercover: "Skateboard"),
            WordPair(civilian: "Guru", undercover: "Dosen"),
            WordPair(civilian: "Angin", undercover: "Badai"),
            WordPair(civilian: "Crayon", undercover: "Marker"),
            WordPair(civilian: "Lumba-lumba", undercover: "Paus"),
            WordPair(civilian: "Tablet", undercover: "Smartphone"),
            WordPair(civilian: "Voli", undercover: "Tenis"),
            WordPair(civilian: "Tebing", undercover: "Lembah"),
            WordPair(civilian: "Donat", undercover: "Pastry"),
            WordPair(civilian: "Drone", undercover: "Pesawat"),
            WordPair(civilian: "Bintang", undercover: "Planet"),
            WordPair(civilian: "Pisau", undercover: "Gunting"),
            WordPair(civilian: "Kerbau", undercover: "Sapi"),
            WordPair(civilian: "Tram", undercover: "Mobil"),
            WordPair(civilian: "Permen", undercover: "Jelly"),
            WordPair(civilian: "Pemanas", undercover: "Kipas Angin"),
            WordPair(civilian: "Pasta", undercover: "Ramen"),
            WordPair(civilian: "Jaket", undercover: "Coat"),
            WordPair(civilian: "Bantal", undercover: "Bantal Cinta"),
            WordPair(civilian: "Microphone", undercover: "Amplifier"),
            WordPair(civilian: "Snapchat", undercover: "WhatsApp"),
            WordPair(civilian: "Angsa", undercover: "Burung"),
            WordPair(civilian: "Durian", undercover: "Rambutan"),
            WordPair(civilian: "Yacht", undercover: "Kapal Pesiar"),
            WordPair(civilian: "Celana Pendek", undercover: "Celana Panjang"),
            WordPair(civilian: "Venus", undercover: "Merkurius"),
            WordPair(civilian: "Helm", undercover: "Masker"),
            WordPair(civilian: "Monitor", undercover: "Layar"),
            WordPair(civilian: "Pipa", undercover: "Balon"),
            WordPair(civilian: "Anjing Laut", undercover: "Singa Laut"),
            WordPair(civilian: "Telaga", undercover: "Rawa"),
            WordPair(civilian: "Lemari", undercover: "Rak"),
            WordPair(civilian: "Obor", undercover: "Lentera"),
            WordPair(civilian: "Gel Rambut", undercover: "Pomade"),
            WordPair(civilian: "Freezer", undercover: "Kulkas"),
            WordPair(civilian: "Dompet Uang", undercover: "Pouch"),
            WordPair(civilian: "Komik", undercover: "Novel"),
            WordPair(civilian: "Arloji", undercover: "Jam Dinding"),
            WordPair(civilian: "Fudge", undercover: "Brownies"),
            WordPair(civilian: "Ponco", undercover: "Raincoat"),
            WordPair(civilian: "Tikus Liar", undercover: "Tikus Rumah"),
            WordPair(civilian: "Aki", undercover: "Baterai"),
            WordPair(civilian: "Biola", undercover: "Saksofon"),
            WordPair(civilian: "Zebra", undercover: "Kuda"),
            WordPair(civilian: "Tikar", undercover: "Permadani")
        ]
}
