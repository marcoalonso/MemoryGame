//
//  CardView.swift
//  MemoryGame
//
//  Created by Marco Alonso Rodriguez on 16/12/24.
//

import SwiftUI

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


