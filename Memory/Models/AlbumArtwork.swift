//
//  AlbumArtwork.swift
//  Memory
//
//  Desc: container for one album artwork link and image - equatable, hashable
//

import UIKit
import Foundation

struct AlbumArtwork : Equatable, Hashable {
    
    let artworkURL: String
    var image: UIImage?
    
    var imageData: Data? {
        guard let image = image else {
            return nil
        }
        return UIImagePNGRepresentation(image)
    }
    var imageSize: Int {
        guard let data = imageData else {
            return 0;
        }
        return data.count
    }
    var hashValue: Int {
        return imageSize
    }
}

// compares image sizes first, then actual image contents
func ==(lhs: AlbumArtwork, rhs: AlbumArtwork) -> Bool {
    let areEqual = lhs.imageSize == rhs.imageSize && lhs.imageData == rhs.imageData
    return areEqual
}

