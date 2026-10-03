//
//  ShadowWordTests.swift
//  ShadowWordTests
//
//  Created by Byan Hasyif on 24/05/26.
//

import Testing
@testable import ShadowWord

@MainActor
struct ShadowWordTests {
    @Test func setupGameCreatesExpectedPlayerCount() async throws {
        let viewModel = GameViewModel(
            wordPairs: [WordPair(civilian: "Cat", undercover: "Tiger")]
        )

        viewModel.setupGame(totalPlayers: 5, undercoverCount: 1, mrWhiteCount: 1)

        #expect(viewModel.players.count == 5)
        #expect(viewModel.currentRevealIndex == 0)
        #expect(viewModel.lastTotalPlayers == 5)
        #expect(viewModel.lastUndercoverCount == 1)
        #expect(viewModel.lastMrWhiteCount == 1)
        #expect(viewModel.gameState == .reveal)
    }

    @Test func invalidSetupDoesNotStartGame() async throws {
        let viewModel = GameViewModel()

        viewModel.setupGame(totalPlayers: 3, undercoverCount: 2, mrWhiteCount: 1)

        #expect(viewModel.players.isEmpty)
        #expect(viewModel.gameState == .home)
    }

    @Test func threePlayerSetupUsesOneUndercoverAndTwoCivilians() async throws {
        let viewModel = GameViewModel(
            wordPairs: [WordPair(civilian: "Cat", undercover: "Tiger")]
        )

        viewModel.setupGame(totalPlayers: 3, undercoverCount: 1, mrWhiteCount: 0)

        #expect(viewModel.players.filter { $0.role == .undercover }.count == 1)
        #expect(viewModel.players.filter { $0.role == .civilian }.count == 2)
        #expect(viewModel.players.filter { $0.role == .mrWhite }.isEmpty)
    }

    @Test func votingOutOnlyUndercoverGivesCivilianWin() async throws {
        let viewModel = GameViewModel(
            wordPairs: [WordPair(civilian: "Cat", undercover: "Tiger")]
        )

        viewModel.setupGame(totalPlayers: 3, undercoverCount: 1, mrWhiteCount: 0)
        let undercover = try #require(
            viewModel.players.first { $0.role == .undercover }
        )

        viewModel.finishGame(votedPlayerNumber: undercover.number)

        #expect(viewModel.winnerText == "Civilian Wins")
        #expect(viewModel.eliminatedPlayerNumbers.contains(undercover.number))
        #expect(viewModel.gameState == .result)
    }

    @Test func votingOutCivilianContinuesWhenCivilianAndSpecialRolesRemain() async throws {
        let viewModel = GameViewModel(
            wordPairs: [WordPair(civilian: "Cat", undercover: "Tiger")]
        )

        viewModel.setupGame(totalPlayers: 5, undercoverCount: 1, mrWhiteCount: 1)
        let civilian = try #require(
            viewModel.players.first { $0.role == .civilian }
        )

        viewModel.finishGame(votedPlayerNumber: civilian.number)

        #expect(viewModel.winnerText.isEmpty)
        #expect(viewModel.eliminatedPlayerNumbers.contains(civilian.number))
        #expect(viewModel.gameState == .discussion)
    }

    @Test func votingOutOneUndercoverContinuesWhenAnotherUndercoverRemains() async throws {
        let viewModel = GameViewModel(
            wordPairs: [WordPair(civilian: "Cat", undercover: "Tiger")]
        )

        viewModel.setupGame(totalPlayers: 7, undercoverCount: 2, mrWhiteCount: 0)
        let undercover = try #require(
            viewModel.players.first { $0.role == .undercover }
        )

        viewModel.finishGame(votedPlayerNumber: undercover.number)

        #expect(viewModel.winnerText.isEmpty)
        #expect(viewModel.eliminatedPlayerNumbers.contains(undercover.number))
        #expect(viewModel.gameState == .discussion)
    }

    @Test func playAgainStartsNewRoundWithPreviousNames() async throws {
        let viewModel = GameViewModel(
            wordPairs: [WordPair(civilian: "Cat", undercover: "Tiger")]
        )

        viewModel.setupGame(totalPlayers: 7, undercoverCount: 2, mrWhiteCount: 1)
        viewModel.players[0].name = "Ari"
        viewModel.players[1].name = "Bima"
        viewModel.preparePlayAgain()

        #expect(viewModel.players.count == 7)
        #expect(viewModel.players[0].name == "Ari")
        #expect(viewModel.players[1].name == "Bima")
        #expect(viewModel.lastTotalPlayers == 7)
        #expect(viewModel.lastUndercoverCount == 2)
        #expect(viewModel.lastMrWhiteCount == 1)
        #expect(viewModel.currentRevealIndex == 0)
        #expect(viewModel.eliminatedPlayerNumbers.isEmpty)
        #expect(viewModel.gameState == .reveal)
    }

    @Test func playAgainUsesDifferentWordPairBeforeRepeating() async throws {
        let viewModel = GameViewModel(
            wordPairs: [
                WordPair(civilian: "Cat", undercover: "Tiger"),
                WordPair(civilian: "Coffee", undercover: "Tea")
            ]
        )

        viewModel.setupGame(totalPlayers: 5, undercoverCount: 1, mrWhiteCount: 1)
        let firstPair = try #require(viewModel.selectedWordPair)

        viewModel.preparePlayAgain()
        let secondPair = try #require(viewModel.selectedWordPair)

        #expect(secondPair != firstPair)
    }

    @Test func oneCivilianAndOneUndercoverGivesUndercoverWin() async throws {
        let viewModel = GameViewModel(
            wordPairs: [WordPair(civilian: "Cat", undercover: "Tiger")]
        )

        viewModel.setupGame(totalPlayers: 3, undercoverCount: 1, mrWhiteCount: 0)
        let civilian = try #require(
            viewModel.players.first { $0.role == .civilian }
        )

        viewModel.finishGame(votedPlayerNumber: civilian.number)

        #expect(viewModel.winnerText == "Undercover Wins")
        #expect(viewModel.gameState == .result)
    }

    @Test func undercoverAndMrWhiteTriggersFinalGuessAndWrongGuessGivesUndercoverWin() async throws {
        let viewModel = GameViewModel(
            wordPairs: [WordPair(civilian: "Cat", undercover: "Tiger")]
        )

        viewModel.setupGame(totalPlayers: 5, undercoverCount: 1, mrWhiteCount: 1)
        let civilians = viewModel.players.filter { $0.role == .civilian }
        let mrWhite = try #require(
            viewModel.players.first { $0.role == .mrWhite }
        )

        for civilian in civilians {
            viewModel.finishGame(votedPlayerNumber: civilian.number)
        }

        #expect(viewModel.pendingMrWhiteGuessPlayerNumber == mrWhite.number)

        viewModel.submitMrWhiteGuess(votedPlayerNumber: mrWhite.number, guess: "Dog")

        #expect(viewModel.winnerText == "Undercover Wins")
        #expect(viewModel.gameState == .result)
    }

    @Test func civilianAndMrWhiteTriggersFinalGuessAndWrongGuessGivesCivilianWin() async throws {
        let viewModel = GameViewModel(
            wordPairs: [WordPair(civilian: "Cat", undercover: "Tiger")]
        )

        viewModel.setupGame(totalPlayers: 5, undercoverCount: 1, mrWhiteCount: 1)
        let undercover = try #require(
            viewModel.players.first { $0.role == .undercover }
        )
        let mrWhite = try #require(
            viewModel.players.first { $0.role == .mrWhite }
        )
        let civiliansToEliminate = viewModel.players.filter { $0.role == .civilian }.dropFirst()

        viewModel.finishGame(votedPlayerNumber: undercover.number)
        for civilian in civiliansToEliminate {
            viewModel.finishGame(votedPlayerNumber: civilian.number)
        }

        #expect(viewModel.pendingMrWhiteGuessPlayerNumber == mrWhite.number)

        viewModel.submitMrWhiteGuess(votedPlayerNumber: mrWhite.number, guess: "Dog")

        #expect(viewModel.winnerText == "Civilian Wins")
        #expect(viewModel.gameState == .result)
    }

    @Test func correctMrWhiteGuessWinsGame() async throws {
        let viewModel = GameViewModel(
            wordPairs: [WordPair(civilian: "Cat", undercover: "Tiger")]
        )

        viewModel.setupGame(totalPlayers: 5, undercoverCount: 1, mrWhiteCount: 1)
        let mrWhite = try #require(
            viewModel.players.first { $0.role == .mrWhite }
        )

        viewModel.submitMrWhiteGuess(votedPlayerNumber: mrWhite.number, guess: " cat ")

        #expect(viewModel.winnerText == "Mr. White Wins")
        #expect(!viewModel.eliminatedPlayerNumbers.contains(mrWhite.number))
        #expect(viewModel.gameState == .result)
    }

    @Test func wrongMrWhiteGuessContinuesGame() async throws {
        let viewModel = GameViewModel(
            wordPairs: [WordPair(civilian: "Cat", undercover: "Tiger")]
        )

        viewModel.setupGame(totalPlayers: 5, undercoverCount: 1, mrWhiteCount: 1)
        let mrWhite = try #require(
            viewModel.players.first { $0.role == .mrWhite }
        )

        viewModel.submitMrWhiteGuess(votedPlayerNumber: mrWhite.number, guess: "Dog")

        #expect(viewModel.winnerText.isEmpty)
        #expect(viewModel.eliminatedPlayerNumbers.contains(mrWhite.number))
        #expect(!viewModel.alivePlayers.contains(mrWhite))
        #expect(viewModel.gameState == .discussion)
    }
}
