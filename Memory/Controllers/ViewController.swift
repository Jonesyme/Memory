//
//  ViewController.swift
//  Memory
//
//  Desc: primary ViewController for app - contains 4x4 game board
//

import UIKit
import Foundation


class ViewController: UIViewController {

    
    @IBOutlet var collectionView: UICollectionView! // main 4x4 grid game board
    @IBOutlet var activityView: UIActivityIndicatorView! // initial download spinner
    @IBOutlet var gameClockLabel: UILabel!          // top-left game clock
    @IBOutlet var resetButton: UIButton!            // btn to reset game board
    @IBOutlet var retryButton: UIButton!            // btn to retry album artwork download
    
    let gameBoardSize = 16
    let cardBackImage = UIImage(named: "cardBack")
    
    var WSManager = SCWebService()   // web service manager
    var gameManager: GameManager?    // memory game manager

    override func viewDidLoad() {
        super.viewDidLoad()
        downloadAlbumArtwork()
    }

    // detect when device is rotated and notify UICollectionView to reload
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        })
    }

    // fetch playlist and album artwork from remote webservice
    private func downloadAlbumArtwork() {
        retryButton.isHidden = true
        resetButton.isHidden = true
        activityView.startAnimating()
        
        // first, fetch playlist in JSON format
        WSManager.fetchAndParsePlaylist(completion: { [unowned self] (error) in
            if error != nil {
                self.displayDownloadFailureRetryMessage(error as! SCAPIError)
                return
            }
            
            // second, fetch album artwork via links parsed from playlist
            self.WSManager.fetchAllAlbumArtwork(self.gameBoardSize/2, completion: { [unowned self] (albumArtworkList, error) in
                if error != nil {
                    self.displayDownloadFailureRetryMessage(error as! SCAPIError)
                    return
                }
                
                // successfull download, setup game board
                self.gameManager = GameManager(self.gameBoardSize, cardBackImage:self.cardBackImage, artworkList: albumArtworkList!)
                self.gameManager?.delegate = self
                self.gameManager?.resetGame()
                
                // hide spinner, reload CollectionView
                DispatchQueue.main.async() {
                    self.resetButton.isHidden = false
                    self.activityView.stopAnimating()
                    self.collectionView.reloadData()
                }
            })
        })
    }
    
    // display download retry button
    private func displayDownloadFailureRetryMessage(_ error: SCAPIError) {
        DispatchQueue.main.async() {
            // show retry button, display error message in alert
            self.resetButton.isHidden = true
            self.retryButton.isHidden = false
            self.activityView.stopAnimating()
            let alert = UIAlertController(title: "Failed Download", message: error.description, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    // format game time in seconds for display
    internal func formattedGameTimeString(_ totalSeconds:UInt) -> String{
        let minutes = String(format: "%02d", totalSeconds / 60)
        let seconds = String(format: "%02d", totalSeconds % 60)
        return "\(minutes):\(seconds)"
    }

    // reset game
    @IBAction func resetGame() {
        gameManager?.resetGame()
    }
    
    // retry webservice download
    @IBAction func retryDownloadBtnTapped() {
        self.downloadAlbumArtwork()
    }
}

// MARK: - GameManagerDelegate
extension ViewController: GameManagerDelegate {
    func gameShouldRedrawGameBoard(_ game:GameManager) {
        DispatchQueue.main.async() {
            self.collectionView.reloadData()
        }
    }
    func gameHasBeenSolved(_ game:GameManager, inTotalSeconds seconds:UInt) {
        DispatchQueue.main.async() {
            let formattedTime = self.formattedGameTimeString(seconds)
            let alert = UIAlertController(title: "Hooray", message: "You solved the puzzle in \(formattedTime)! Would you like to play again?", preferredStyle: .alert)
            let alertActionYes = UIAlertAction(title: "Yes", style: .destructive, handler: { [unowned self] action in
                self.resetGame()
            })
            alert.addAction(UIAlertAction(title: "No", style: .destructive, handler:nil))
            alert.addAction(alertActionYes)
            self.present(alert, animated: true, completion: nil)
        }
    }
    func gameShouldUpdateGameClock(_ game:GameManager, withSeconds seconds:UInt) {
        DispatchQueue.main.async() {
            self.gameClockLabel.text = self.formattedGameTimeString(seconds)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let _ = gameManager else {
            return 0
        }
        return gameBoardSize
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let flipCardCell = collectionView.dequeueReusableCell(withReuseIdentifier: "flipCardCell", for: indexPath) as! FlipCardCollectionViewCell
        if self.gameManager!.gameBoard.count > indexPath.row { // double check game board is allocated
            flipCardCell.flipCardStore = self.gameManager!.gameBoard[indexPath.row];
            flipCardCell.refreshCellContent()
        }
        return flipCardCell;
    }
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        gameManager?.selectCardAtIndex(indexPath.row)
    }
}

// MARK: - UICollectionViewFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // size game board using shortest screen side to ensure board is always square
        let minFrameWidth = min(collectionView.frame.width, collectionView.frame.height)
        let cellSize = (minFrameWidth / 4) - 2
        return CGSize(width: cellSize, height: cellSize)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let leftRightInset = CGFloat(1.00)
        return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset)
    }
}


