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
    @Published var cards: [CardModel] = []            // Lista de cartas visibles en la vista
    @Published var score: Int = 0                    // Puntuación del jugador
    @Published var selectedDifficulty: Difficulty = .easy // Nivel de dificultad seleccionado
    @Published var isResetting: Bool = false         // Controla el estado de reseteo (para animaciones)

    private var flippedCards: [CardModel] = []       // Cartas actualmente volteadas
    private let animalImages = [                    // Lista de imágenes de animales
        "lion", "tiger", "elephant", "giraffe", "monkey",
        "zebra", "panda", "fox", "dog", "cat"
    ]
    private var audioPlayer: AVAudioPlayer?         // Reproductor de sonidos

    // Inicialización del ViewModel
    init() {
        setupGame()
    }

    // Configura el juego según el nivel de dificultad seleccionado
    func setupGame() {
        isResetting = true // Indica que se está reseteando el juego
        
        // Espera un poco antes de reiniciar la lógica del juego para permitir la animación
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.resetGameLogic() // Reinicia la lógica del juego
            self.isResetting = false // Indica que el reseteo ha terminado
        }
    }

    // Lógica principal para resetear el juego
    private func resetGameLogic() {
        score = 0
        flippedCards = []

        // Determina cuántos animales usar según la dificultad
        let numberOfAnimals: Int
        switch selectedDifficulty {
        case .easy:
            numberOfAnimals = 4
        case .medium:
            numberOfAnimals = 7
        case .hard:
            numberOfAnimals = 10
        }

        // Selecciona y mezcla los animales
        let selectedAnimals = Array(animalImages.prefix(numberOfAnimals))
        let shuffledImages = (selectedAnimals + selectedAnimals).shuffled()
        cards = shuffledImages.map { CardModel(imageName: $0) }
    }

    // Voltea una carta seleccionada por el usuario
    func flipCard(_ card: CardModel) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }),
              !cards[index].isFlipped,
              !cards[index].isMatched else { return }
        
        cards[index].isFlipped.toggle()
        flippedCards.append(cards[index])
        
        // Si hay dos cartas volteadas, verifica si coinciden
        if flippedCards.count == 2 {
            checkForMatch()
        }
    }

    // Verifica si las dos cartas volteadas forman un par
    private func checkForMatch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard self.flippedCards.count == 2 else { return }
            
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
        }
    }

    // Marca las cartas como emparejadas
    private func markCardsAsMatched(_ cardsToMatch: [CardModel]) {
        for card in cardsToMatch {
            if let index = cards.firstIndex(where: { $0.id == card.id }) {
                cards[index].isMatched = true
            }
        }
    }

    // Devuelve las cartas a su estado inicial si no coinciden
    private func unflipCards(_ cardsToUnflip: [CardModel]) {
        for card in cardsToUnflip {
            if let index = cards.firstIndex(where: { $0.id == card.id }) {
                cards[index].isFlipped = false
            }
        }
    }

    // Genera retroalimentación háptica
    private func triggerHapticFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    // Reproduce sonidos (éxito o error)
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
