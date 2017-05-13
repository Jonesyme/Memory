//
//  SCWebService.swift
//  Memory
//
//  Desc: class to manage webservice requests to SoundCloud API
//

import UIKit
import Foundation

// errors specific to webservice request failures
enum SCAPIError: Error {
    case Connection
    case Parsing
    case InsufficientArtwork
    
    var description: String {
        switch self {
        case .Connection:
            return "Unable to connect to SoundCloud server"
        case .Parsing:
            return "Failed to parse playlist"
        case .InsufficientArtwork:
            return "Playlist contained insufficient unique artwork"
        }
    }
}

open class SCWebService {

    // SoundCloud API Endpoint
    private let playlistEndpointURL = "http://api.soundcloud.com/playlists/79670980?client_id="
    private let clientID = "aa45989bb0c262788e2d11f1ea041b65"
    
    // album artwork links and images
    var albumArtworkList: [AlbumArtwork] = []

    init() {}

    // download playlist JSON and parse album artwork URLs for each track
    func fetchAndParsePlaylist(completion:@escaping (_ error: Error?) -> Void) {
        
        let url = URL(string: playlistEndpointURL + clientID)
        
        // fetch JSON-formatted playlist
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
                print("Failed to connect to endpoint: \(String(describing: error!.localizedDescription))")
                completion(SCAPIError.Connection)
            } else {
                
                do {
                    // parse album artwork URLs
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    let trackArr = parsedData["tracks"] as! [[String:Any]]
                    
                    // loop through tracks
                    for trackData in trackArr {
                        guard let artwork_url = trackData["artwork_url"] as! String? else {
                            continue;
                        }
                        // store artwork link
                        let albumArtwork = AlbumArtwork(artworkURL: artwork_url, image: nil)
                        self.albumArtworkList.append(albumArtwork)
                    }
                    completion(nil)
                    
                } catch let error as NSError {
                    print("Failed to parse JSON: \(error.localizedDescription)")
                    completion(SCAPIError.Parsing)
                }
            }
        }.resume()
    }

    // download album images for each track listed in the playlist
    func fetchAllAlbumArtwork(_ minArtworkRequired: Int, completion:@escaping (_ albumArtworkList:[AlbumArtwork]?, _ error: Error?) -> Void) {
        
        let taskGroup = DispatchGroup() // use group of async tasks to fetch images simultaneously
        
        for index in 0...albumArtworkList.count-1 { // loop through album artwork links
            
            taskGroup.enter() // begin subtask
            
            let albumArtwork = albumArtworkList[index]
            let url = URL(string: albumArtwork.artworkURL)
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else {
                        taskGroup.leave() // notify subtask completion
                        return
                    }
                
                self.albumArtworkList[index].image = image // success, store image
                
                defer {
                    taskGroup.leave() // notify subtask completion
                }
            }.resume()
        }
        
        // fires once all download tasks have completed
        taskGroup.notify(queue: .main) { [weak self] in
            
            // remove any duplicate album images from list
            self!.albumArtworkList = Array(Set(self!.albumArtworkList))
            
            // verify we have a sufficient number of album images as specified by 'minArtworkRequired'
            var error: Error? = nil
            if self!.albumArtworkList.count < minArtworkRequired {
                error = SCAPIError.InsufficientArtwork
            }
            completion(self?.albumArtworkList, error)
        }
    }

}

