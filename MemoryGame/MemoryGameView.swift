//
//  MemoryGameView.swift
//  MemoryGame
//
//  Created by Marco Alonso Rodriguez on 16/12/24.
//

import SwiftUI

struct MemoryGameView: View {
    @StateObject private var viewModel = MemoryGameViewModel()
    
    private let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    
    var body: some View {
        VStack {
            Text("Memory Game")
                .font(.title)
                
            Text("Score: \(viewModel.score)")
                .font(.title2)
                .foregroundStyle(.green)
            
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.cards) { card in
                    CardView(card: card)
                        .onTapGesture {
                            viewModel.flipCard(card)
                        }
                }
            }
            .padding()
            
            Button("Restart Game") {
                viewModel.setupGame()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}

struct CardView: View {
    let card: CardModel
    
    var body: some View {
        ZStack {
            if card.isFlipped || card.isMatched {
                Image(card.imageName)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray)
                    .overlay(
                        Text("?")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )
            }
        }
        .frame(width: 80, height: 100)
        .shadow(radius: 4)
        .animation(.spring(), value: card.isFlipped)
    }
}

#Preview {
    MemoryGameView()
}
