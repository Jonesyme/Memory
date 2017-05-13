//
//  FlipCard.swift
//  Memory
//
//  Desc: container / state manager for a flippable game card
//

import UIKit

// flippable game card store
class FlipCard : Equatable {
    
    var isMatched: Bool = false
    var isFlipped: Bool = false // if true, faceImage is showing
    
    var faceImage: UIImage?
    var backImage: UIImage?
    
    init(_ backImage: UIImage?, faceImage: UIImage?) {
        self.faceImage = faceImage
        self.backImage = backImage
    }
}

// custom equality overload - compares the faceImage instances of two flip cards
func ==(lhs: FlipCard, rhs: FlipCard) -> Bool {
    return lhs.faceImage === rhs.faceImage
}

// adds shuffle() member to MutableCollections
//   Admittedly swiped from the following source:
//     stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift/24029847#24029847
extension MutableCollection where Indices.Iterator.Element == Index {
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}
