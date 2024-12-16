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

// Enum para representar los niveles de dificultad
enum Difficulty: String, CaseIterable {
    case easy = "Fácil"
    case medium = "Intermedio"
    case hard = "Difícil"
}

// ViewModel que gestiona la lógica del juego
class MemoryGameViewModel: ObservableObject {
    @Published var cards: [CardModel] = [] // Lista de cartas visibles en la vista
    @Published var score: Int = 0 // Puntuación actual del jugador
    @Published var selectedDifficulty: Difficulty = .easy // Nivel de dificultad seleccionado por el usuario
    @Published var isResetting: Bool = false // Controla el estado de reseteo para las animaciones
    @Published var isInteractionDisabled: Bool = false // Deshabilita la interacción del usuario durante verificaciones
    
    private var flippedCards: [CardModel] = [] // Lista temporal de cartas volteadas para verificar pares
    private let animalImages = [ // Lista de nombres de imágenes de animales
        "lion", "tiger", "elephant", "giraffe", "monkey",
        "zebra", "panda", "fox", "dog", "cat"
    ]
    private var audioPlayer: AVAudioPlayer? // Reproductor de sonidos para efectos de audio

    // Inicializa el ViewModel configurando el juego por primera vez
    init() {
        setupGame()
        playFirstLaunchSound()
    }
    
    // Reproduce un sonido la primera vez que se abre la app
    private func playFirstLaunchSound() {
        let defaults = UserDefaults.standard
        let hasLaunchedBefore = defaults.bool(forKey: "hasLaunchedBefore") // Verificar si ya se abrió antes
        
        if !hasLaunchedBefore {
            playSound(named: "welcome") // Reproduce el sonido
            defaults.set(true, forKey: "hasLaunchedBefore") // Marcar como abierto
        }
    }

    // Configura el juego, mezclando las cartas y reiniciando el estado
    func setupGame() {
        isResetting = true // Activa el estado de reseteo para animaciones
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.resetGameLogic() // Resetea la lógica del juego después de un breve retraso
            self.isResetting = false // Finaliza el estado de reseteo
        }
    }

    // Resetea la lógica del juego: mezcla las cartas y reinicia el puntaje
    private func resetGameLogic() {
        score = 0 // Reinicia el puntaje
        flippedCards = [] // Limpia las cartas volteadas
        isInteractionDisabled = false // Habilita la interacción del usuario

        // Determina el número de animales según la dificultad seleccionada
        let numberOfAnimals: Int
        switch selectedDifficulty {
        case .easy:
            numberOfAnimals = 4 // Fácil: 4 animales
        case .medium:
            numberOfAnimals = 7 // Intermedio: 7 animales
        case .hard:
            numberOfAnimals = 10 // Difícil: 10 animales
        }

        // Selecciona y mezcla las imágenes para generar pares
        let selectedAnimals = Array(animalImages.prefix(numberOfAnimals))
        let shuffledImages = (selectedAnimals + selectedAnimals).shuffled()
        cards = shuffledImages.map { CardModel(imageName: $0) } // Crea las cartas a partir de las imágenes
    }

    // Voltea una carta seleccionada por el usuario
    func flipCard(_ card: CardModel) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }),
              !cards[index].isFlipped, // No permitir voltear cartas ya volteadas
              !cards[index].isMatched, // No permitir voltear cartas emparejadas
              !isInteractionDisabled else { return } // No permitir interacción si está deshabilitada

        cards[index].isFlipped.toggle() // Voltea la carta
        cards[index].flipCount += 1 // Incrementa el contador de veces que se ha volteado
        flippedCards.append(cards[index]) // Agrega la carta a la lista de cartas volteadas

        if flippedCards.count == 2 {
            isInteractionDisabled = true // Deshabilita la interacción mientras se verifica el par
            checkForMatch() // Verifica si las cartas forman un par
        }
    }

    // Verifica si las dos cartas volteadas forman un par
    private func checkForMatch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Agrega un retraso para permitir al jugador ver las cartas volteadas
            guard self.flippedCards.count == 2 else {
                self.isInteractionDisabled = false // Vuelve a habilitar la interacción si no hay dos cartas volteadas
                return
            }

            let firstCard = self.flippedCards[0]
            let secondCard = self.flippedCards[1]

            if firstCard.imageName == secondCard.imageName {
                // Si las cartas coinciden
                self.markCardsAsMatched([firstCard, secondCard]) // Marca las cartas como emparejadas
                self.playSound(named: "match") // Reproduce el sonido de éxito
                self.triggerHapticFeedback(type: .success) // Genera retroalimentación háptica de éxito

                // Calcula la puntuación basada en las veces que las cartas se voltearon
                let firstCardPoints = max(10 - firstCard.flipCount + 1, 1)
                let secondCardPoints = max(10 - secondCard.flipCount + 1, 1)
                self.score += firstCardPoints + secondCardPoints // Suma la puntuación calculada
            } else {
                // Si las cartas no coinciden
                self.unflipCards([firstCard, secondCard]) // Voltea las cartas de nuevo
                self.playSound(named: "no_match") // Reproduce el sonido de error
                self.triggerHapticFeedback(type: .error) // Genera retroalimentación háptica de error
            }

            self.flippedCards = [] // Limpia la lista de cartas volteadas
            self.isInteractionDisabled = false // Habilita la interacción nuevamente
        }
    }

    // Marca las cartas como emparejadas para que no puedan ser volteadas nuevamente
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

    // Genera retroalimentación háptica para el jugador
    private func triggerHapticFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    // Reproduce un sonido (éxito o error) usando un archivo de audio
    private func playSound(named soundName: String) {
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}
