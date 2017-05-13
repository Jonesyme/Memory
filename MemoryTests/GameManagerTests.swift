//
//  GameControllerTests.swift
//  Memory
//

import XCTest
import UIKit
import Foundation

@testable import Memory

class GameControllerTests: XCTestCase {
    
    var gameManager: GameManager!
    
    override func setUp() {
        super.setUp()
        
        // instantiate GameManager
        let gameBoardSize = 16
        let cardBackImage = UIImage(named: "cardBack")
        let artworkList = [AlbumArtwork(artworkURL:"https://i1.sndcdn.com/artworks-uSPXMM8aakxl-0-large.jpg", image:UIImage(named:"artwork01")),
                           AlbumArtwork(artworkURL:"https://i1.sndcdn.com/artworks-uSPXMM8aakxl-0-large.jpg", image:UIImage(named:"artwork02")),
                           AlbumArtwork(artworkURL:"https://i1.sndcdn.com/artworks-uSPXMM8aakxl-0-large.jpg", image:UIImage(named:"artwork03")),
                           AlbumArtwork(artworkURL:"https://i1.sndcdn.com/artworks-uSPXMM8aakxl-0-large.jpg", image:UIImage(named:"artwork04")),
                           AlbumArtwork(artworkURL:"https://i1.sndcdn.com/artworks-uSPXMM8aakxl-0-large.jpg", image:UIImage(named:"artwork05")),
                           AlbumArtwork(artworkURL:"https://i1.sndcdn.com/artworks-uSPXMM8aakxl-0-large.jpg", image:UIImage(named:"artwork06")),
                           AlbumArtwork(artworkURL:"https://i1.sndcdn.com/artworks-uSPXMM8aakxl-0-large.jpg", image:UIImage(named:"artwork07")),
                           AlbumArtwork(artworkURL:"https://i1.sndcdn.com/artworks-uSPXMM8aakxl-0-large.jpg", image:UIImage(named:"artwork08"))]
        gameManager = GameManager(gameBoardSize, cardBackImage:cardBackImage, artworkList: artworkList)
        gameManager.resetGame()
    }

    func testSelectedCardIsFlipped() {
        gameManager.selectCardAtIndex(0)
        XCTAssert(gameManager.gameBoard[0].isFlipped)
    }
    
    func testSelectedCardsAreMatched() {
        gameManager.resetGame()
        gameManager.selectCardAtIndex(0)
        gameManager.selectCardAtIndex(1)
        XCTAssert(gameManager.gameBoard[0].isMatched)
        XCTAssert(gameManager.gameBoard[1].isMatched)
    }
    
    func testGameManagerDelegate_gameShouldRedrawGameBoard() {
        let spyDelegate = GameManagerSpyDelegate()
        gameManager.delegate = spyDelegate
        let exp = expectation(description: "gameShouldRedrawGameBoardExpectation")
        spyDelegate.gameShouldRedrawGameBoardExpectation = exp

        gameManager.resetGame()
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testGameManagerDelegate_gameShouldUpdateGameClock() {
        let spyDelegate = GameManagerSpyDelegate()
        gameManager.delegate = spyDelegate
        let exp = expectation(description: "gameShouldUpdateGameClockExpectation")
        spyDelegate.gameShouldUpdateGameClockExpectation = exp
        
        gameManager.resetGame()
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testGameManagerDelegate_gameHasBeenSolved() {
        let spyDelegate = GameManagerSpyDelegate()
        gameManager.delegate = spyDelegate
        let exp = expectation(description: "gameHasBeenSolvedExpectation")
        spyDelegate.gameHasBeenSolvedExpectation = exp
        
        // solve game
        gameManager.resetGame()
        for index in 0...gameManager.gameBoard.count-3 { // flip all but two cards
            gameManager.gameBoard[index].isMatched = true
        }
        // now flip last two cards
        gameManager.selectCardAtIndex(gameManager.gameBoard.count-2)
        gameManager.selectCardAtIndex(gameManager.gameBoard.count-1)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testResetGameFailure() {
        let artworkList = [AlbumArtwork(artworkURL:"https://i1.sndcdn.com/artworks-uSPXMM8aakxl-0-large.jpg", image:nil)]
        gameManager.artworkList = artworkList
        gameManager.resetGame() // should fail to populate board with only 1 artwork link
        XCTAssert(gameManager.gameBoard.count==0)
    }
}



// SpyDelegate class to test GameManagerDelegate
class GameManagerSpyDelegate: GameManagerDelegate {

    var gameShouldRedrawGameBoardExpectation: XCTestExpectation?
    var gameShouldUpdateGameClockExpectation: XCTestExpectation?
    var gameHasBeenSolvedExpectation: XCTestExpectation?
    
    func gameShouldRedrawGameBoard(_ game:GameManager) {
        guard let expectation = gameShouldRedrawGameBoardExpectation else {
            return
        }
        expectation.fulfill()
    }
    func gameShouldUpdateGameClock(_ game:GameManager, withSeconds seconds:UInt) {
        guard let expectation = gameShouldUpdateGameClockExpectation else {
            return
        }
        expectation.fulfill()
    }
    func gameHasBeenSolved(_ game:GameManager, inTotalSeconds seconds:UInt) {
        guard let expectation = gameHasBeenSolvedExpectation else {
            return
        }
        expectation.fulfill()
    }
}
