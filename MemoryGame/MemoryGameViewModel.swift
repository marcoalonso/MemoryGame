//
//  MemoryGameViewModel.swift
//  MemoryGame
//
//  Created by Marco Alonso Rodriguez on 16/12/24.
//

import Foundation
import SwiftUI
import AVFoundation
import UIKit

enum Difficulty: String, CaseIterable {
    case easy = "Fácil"
    case medium = "Intermedio"
    case hard = "Difícil"
}

class MemoryGameViewModel: ObservableObject {
    @Published var cards: [CardModel] = []
    @Published var score: Int = 0
    @Published var selectedDifficulty: Difficulty = .easy
    @Published var isResetting: Bool = false
    @Published var isInteractionDisabled: Bool = false // Controla la interacción del usuario

    private var flippedCards: [CardModel] = []
    private let animalImages = [
        "lion", "tiger", "elephant", "giraffe", "monkey",
        "zebra", "panda", "fox", "dog", "cat"
    ]
    private var audioPlayer: AVAudioPlayer?

    init() {
        setupGame()
    }

    func setupGame() {
        isResetting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.resetGameLogic()
            self.isResetting = false
        }
    }

    private func resetGameLogic() {
        score = 0
        flippedCards = []
        isInteractionDisabled = false

        let numberOfAnimals: Int
        switch selectedDifficulty {
        case .easy:
            numberOfAnimals = 4
        case .medium:
            numberOfAnimals = 7
        case .hard:
            numberOfAnimals = 10
        }

        let selectedAnimals = Array(animalImages.prefix(numberOfAnimals))
        let shuffledImages = (selectedAnimals + selectedAnimals).shuffled()
        cards = shuffledImages.map { CardModel(imageName: $0) }
    }

    func flipCard(_ card: CardModel) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }),
              !cards[index].isFlipped,
              !cards[index].isMatched,
              !isInteractionDisabled else { return }

        cards[index].isFlipped.toggle()
        flippedCards.append(cards[index])

        if flippedCards.count == 2 {
            isInteractionDisabled = true // Deshabilita la interacción durante la verificación
            checkForMatch()
        }
    }

    private func checkForMatch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard self.flippedCards.count == 2 else {
                self.isInteractionDisabled = false
                return
            }

            let firstCard = self.flippedCards[0]
            let secondCard = self.flippedCards[1]

            if firstCard.imageName == secondCard.imageName {
                self.markCardsAsMatched([firstCard, secondCard])
                self.playSound(named: "match")
                self.triggerHapticFeedback(type: .success)
                self.score += 10
            } else {
                self.unflipCards([firstCard, secondCard])
                self.playSound(named: "no_match")
                self.triggerHapticFeedback(type: .error)
            }

            self.flippedCards = []
            self.isInteractionDisabled = false // Vuelve a habilitar la interacción
        }
    }

    private func markCardsAsMatched(_ cardsToMatch: [CardModel]) {
        for card in cardsToMatch {
            if let index = cards.firstIndex(where: { $0.id == card.id }) {
                cards[index].isMatched = true
            }
        }
    }

    private func unflipCards(_ cardsToUnflip: [CardModel]) {
        for card in cardsToUnflip {
            if let index = cards.firstIndex(where: { $0.id == card.id }) {
                cards[index].isFlipped = false
            }
        }
    }

    private func triggerHapticFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    private func playSound(named soundName: String) {
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "wav") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}
