//
//  MemoryGameViewModel.swift
//  MemoryGame
//
//  Created by Marco Alonso Rodriguez on 16/12/24.
//

import Foundation
import SwiftUI

class MemoryGameViewModel: ObservableObject {
    @Published var cards: [CardModel] = []
    @Published var score: Int = 0
    
    private var flippedCards: [CardModel] = []
    private let animalImages = [
        "lion", "tiger", "elephant", "giraffe", "monkey",
        "zebra", "panda", "fox"
    ]
    
    init() {
        setupGame()
    }
    
    func setupGame() {
        score = 0
        flippedCards = []
        let shuffledImages = (animalImages + animalImages).shuffled()
        cards = shuffledImages.map { CardModel(imageName: $0) }
    }
    
    func flipCard(_ card: CardModel) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }),
              !cards[index].isFlipped,
              !cards[index].isMatched else { return }
        
        cards[index].isFlipped.toggle()
        flippedCards.append(cards[index])
        
        if flippedCards.count == 2 {
            checkForMatch()
        }
    }
    
    private func checkForMatch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard self.flippedCards.count == 2 else { return }
            
            let firstCard = self.flippedCards[0]
            let secondCard = self.flippedCards[1]
            
            if firstCard.imageName == secondCard.imageName {
                self.markCardsAsMatched([firstCard, secondCard])
                self.score += 10
            } else {
                self.unflipCards([firstCard, secondCard])
                self.score -= 2
            }
            self.flippedCards = []
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
}
