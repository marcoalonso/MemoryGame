//
//  CardModel.swift
//  MemoryGame
//
//  Created by Marco Alonso Rodriguez on 16/12/24.
//

import Foundation

struct CardModel: Identifiable {
    let id = UUID()
    let imageName: String
    var isFlipped: Bool = false
    var isMatched: Bool = false
}


