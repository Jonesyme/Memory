//
//  SCWebServiceTests.swift
//  Memory
//

import XCTest
import UIKit
import Foundation

@testable import Memory

class SCWebServiceTests: XCTestCase {
    
    let defaultGameBoardSize: Int = 16
    var WSManager: SCWebService = SCWebService()
    
    override func setUp() {
        super.setUp()
        WSManager = SCWebService()
    }
    
    func testFetchRemotePlaylistAndArtwork() {
        let expect1 = expectation(description: "fetchPlaylist")
        let expect2 = expectation(description: "fetchAllArtwork")
        
        // fetch playlist
        WSManager.fetchAndParsePlaylist(completion: { (error) in
            if error != nil {
                XCTFail()
            }
            XCTAssert(self.WSManager.albumArtworkList.count > 0)
            expect1.fulfill()
            
            // fetch artwork
            self.WSManager.fetchAllAlbumArtwork(self.defaultGameBoardSize/2, completion: { (albumArtworkList, error) in
                if error != nil {
                    XCTFail()
                    return
                }
                XCTAssertNotNil(albumArtworkList)
                XCTAssert(albumArtworkList!.count > 0)
                expect2.fulfill()
            })
        })
        
        waitForExpectations(timeout: 25.0) { (error) in
            if error != nil {
                XCTFail(error!.localizedDescription)
            }
        }
    }
    
}
