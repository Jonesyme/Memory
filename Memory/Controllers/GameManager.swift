//
//  GameManager.swift
//  Memory
//
//  Desc: class to manage game board setup and storage
//

import UIKit
import Foundation

open class GameManager {
    
    // public settings
    open var boardSize: Int!                   // size of game board
    open var fastGameAllowed: Bool = true      // whether user can force unflipping of mismatched cards or they have to wait for timer
    open weak var cardBackImage: UIImage?      // back image for all game cards
    
    // internal
    var delegate: GameManagerDelegate?
    
    var artworkList: [AlbumArtwork]!      // array of album artwork
    var gameBoard: [FlipCard] = []        // array of FlipCards representing our game board
    
    private weak var firstCardFlipped: FlipCard?  // first card to be flipped during a turn
    private weak var secondCardFlipped: FlipCard? // second card to be flipped during a turn
    
    private var delayEndOfTurnTimer: Timer?       // timer to delay unflipping of two mismatched cards (so user has time to view)
    private var gameClockTimer: Timer?            // timer to increment game clock every second
    private var gameClockSecondsPassed: UInt = 0  // time in seconds since first card flip
    
    private var endOfTurnInProgress: Bool {
        return firstCardFlipped != nil && secondCardFlipped != nil
    }
    
    // initializer
    init(_ boardSize: Int, cardBackImage: UIImage?, artworkList:[AlbumArtwork]) {
        self.boardSize = boardSize
        self.artworkList = artworkList
        self.cardBackImage = cardBackImage
    }
    
    // select (flip) a specified game card
    open func selectCardAtIndex(_ cardIndex: Int) {
        let selectedCard = gameBoard[cardIndex]
        
        if endOfTurnInProgress {
            if fastGameAllowed {
                // allow user to unflip two mismatched cards without waiting for delayEndOfTurnTimer to expire
                delayEndOfTurnTimer?.invalidate()
                unflipMismatchedCards()
            }
            return
        }
        
        if selectedCard.isFlipped {
            return // you can't flip a flipped card, that's crazy talk...
        }

        selectedCard.isFlipped = true;
        delegate?.gameShouldRedrawGameBoard(self)
        
        if firstCardFlipped == nil { // initial card flip
            if gameClockTimer==nil {
                gameClockSecondsPassed = 0
                gameClockTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.clockTimerCallback), userInfo: nil, repeats: true)
            }
            firstCardFlipped = selectedCard
        } else { // second card flip
            if selectedCard == firstCardFlipped! { // match has been made
                selectedCard.isMatched = true
                firstCardFlipped?.isMatched = true
                firstCardFlipped = nil
                
                // check if game board is solved!
                if self.isGameBoardSolved() {
                    self.gameClockTimer?.invalidate()
                    delegate?.gameHasBeenSolved(self, inTotalSeconds: gameClockSecondsPassed)
                }
            } else {
                // no match - wait X seconds, then unflip both cards (so user has time to view the second card)
                secondCardFlipped = selectedCard
                delayEndOfTurnTimer = Timer.scheduledTimer(timeInterval: 1.1, target: self, selector: #selector(self.unflipMismatchedCards), userInfo: selectedCard, repeats: false)
            }
        }
    }
    
    // end current game and reconfigure board for new game
    open func resetGame() {
        gameClockTimer?.invalidate()
        gameClockTimer = nil
        gameClockSecondsPassed = 0
        delayEndOfTurnTimer?.invalidate()
        
        firstCardFlipped = nil
        secondCardFlipped = nil
        
        generateNewGameBoard()
        delegate?.gameShouldUpdateGameClock(self, withSeconds: 0)
        delegate?.gameShouldRedrawGameBoard(self)
    }
    
    // game timer callback (fires every second post flipping first card)
    @objc private func clockTimerCallback(timer:Timer) {
        gameClockSecondsPassed += 1
        delegate?.gameShouldUpdateGameClock(self, withSeconds: gameClockSecondsPassed)
    }
    
    // unflip two mismatched card picks
    @objc private func unflipMismatchedCards() {
        firstCardFlipped?.isFlipped = false
        firstCardFlipped = nil
        secondCardFlipped?.isFlipped = false
        secondCardFlipped = nil
        delegate?.gameShouldRedrawGameBoard(self)
    }
    
    // generate new game board - shuffled artwork, reset flip cards, shuffle board
    private func generateNewGameBoard(_ shuffle: Bool = true) {

        // check that we have enough album art to fill the game board
        if artworkList.count < boardSize/2 {
            print("Error: insufficient album images to play game") // redundant failure, no need to be graceful
            gameBoard.removeAll()
            return
        }
        if shuffle {
            artworkList.shuffle() // shuffle artwork (assuming we have more images than game cards, this adds variety to each game)
        }
        // initialize new game board with new FlipCards
        gameBoard.removeAll()
        for index in 0...boardSize-1 {
            var artIndex = index
            if artIndex >= boardSize/2 {
                artIndex -= boardSize/2
            }
            let flipCard = FlipCard(cardBackImage, faceImage: artworkList[artIndex].image)
            gameBoard.append(flipCard)
        }
        if shuffle {
            gameBoard.shuffle() // shuffle game board deck
        }
    }
    
    // check whether all cards have been matched
    private func isGameBoardSolved() -> Bool {
        if gameBoard.count == 0 {
            return false
        }
        for flipCardStore in gameBoard {
            if !flipCardStore.isMatched {
                return false
            }
        }
        return true
    }
}


// MARK - GameManagerDelegate Protocol
//        Implement this delegate in order to be notified of game-related events
protocol GameManagerDelegate {
    func gameShouldRedrawGameBoard(_ game:GameManager)
    func gameHasBeenSolved(_ game:GameManager, inTotalSeconds seconds:UInt)
    func gameShouldUpdateGameClock(_ game:GameManager, withSeconds seconds:UInt)
}




