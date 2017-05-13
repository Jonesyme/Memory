//
//  ViewControllerTests.swift
//  Memory
//

import XCTest
import UIKit
import Foundation

@testable import Memory

class ViewControllerTests: XCTestCase {
    
    var viewController: ViewController!
    
    override func setUp() {
        super.setUp()
        
        // instantiaite viewController
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        viewController = navigationController.topViewController as! ViewController
        
        UIApplication.shared.keyWindow!.rootViewController = viewController
        
        // ensure view is loaded
        let _ = navigationController.view
        let _ = viewController.view
        
        // setup GameManager
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
        viewController.gameManager = GameManager(gameBoardSize, cardBackImage:cardBackImage, artworkList: artworkList)
        
    }
    
    func testViewControllerViewExists() {
        XCTAssertNotNil(viewController.view, "ViewController should contain a view")
    }
    
    func testViewControllerOutlets() {
        XCTAssertNotNil(viewController.collectionView, "collectionView must be linked in storyboard")
        XCTAssertNotNil(viewController.activityView, "activityView must be linked in storyboard")
        XCTAssertNotNil(viewController.gameClockLabel, "gameClockLabel must be linked in storyboard")
        XCTAssertNotNil(viewController.resetButton, "resetButton must be linked in storyboard")
        XCTAssertNotNil(viewController.retryButton, "retryButton must be linked in storyboard")
    }
    
    func testCollectionViewDequeueReusableCells() {
        var cell: FlipCardCollectionViewCell?
        cell = viewController.collectionView.dequeueReusableCell(withReuseIdentifier: "flipCardCell", for: IndexPath(row:0, section:0)) as? FlipCardCollectionViewCell
        XCTAssertNotNil(cell)
        cell = viewController.collectionView.dequeueReusableCell(withReuseIdentifier: "flipCardCell", for: IndexPath(row:1, section:0)) as? FlipCardCollectionViewCell
        XCTAssertNotNil(cell)
        cell = viewController.collectionView.dequeueReusableCell(withReuseIdentifier: "flipCardCell", for: IndexPath(row:2, section:0)) as? FlipCardCollectionViewCell
        XCTAssertNotNil(cell)
    }
    
    func testFormattingGameTimeString() {
        let output = viewController.formattedGameTimeString(59)
        XCTAssert(output == "00:59", "Game-time formatting is off")
    }

}


