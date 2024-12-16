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
        ScrollView {
            VStack {
                
                
                Text("Memory Game")
                    .font(.title2)
                    .padding()
                
                Text("Score: \(viewModel.score)")
                    .font(.headline)
                    .padding(.bottom)
                
                // Grid de cartas con animación
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.cards) { card in
                        CardView(card: card)
                            .opacity(viewModel.isResetting ? 0 : 1) // Animar opacidad
                            .scaleEffect(viewModel.isResetting ? 0.5 : 1) // Escalar durante el reseteo
                            .animation(.easeInOut(duration: 0.3), value: viewModel.isResetting)
                            .onTapGesture {
                                viewModel.flipCard(card)
                            }
                    }
                }
                .padding()
                
                // Botón de reinicio con imagen
                Button(action: {
                    viewModel.setupGame()
                }) {
                    Image("replayButton") // Usar la imagen de Assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 60) // Tamaño del botón
                        .padding()
                }
                .buttonStyle(PlainButtonStyle()) // Evitar estilo predeterminado
                
                // Selector de dificultad
                Picker("Dificultad", selection: $viewModel.selectedDifficulty) {
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        Text(difficulty.rawValue).tag(difficulty)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: viewModel.selectedDifficulty) { _, _ in
                    viewModel.setupGame() // Reiniciar el juego al cambiar de dificultad
                }
            }
            .frame(maxWidth: .infinity)
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
