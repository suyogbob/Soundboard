//
//  Song.swift
//  Stripify
//
//  Created by Yagil Burowski on 26/09/2016.
//  Copyright © 2016 CIS 195 University of Pennsylvania. All rights reserved.
//

import Foundation
import MediaPlayer

struct SongsWrapper: Decodable {
    
    let resultCount : Int
    let results: [Song]
}

class Song: Decodable {
    var name : String = ""
    var artist : String = ""
    var album: String = ""
    var previewUrl : String = ""
    var artworkUrl : String = ""
    var artwork: MPMediaItemArtwork? = nil
    
    
    convenience init(name : String, artist : String, previewUrl : String, artworkUrl: String, album: String) {
        self.init()
        self.name = name
        self.artist = artist
        self.previewUrl = previewUrl
        self.artworkUrl = artworkUrl
        self.album = album
    }
    
    convenience init(name: String, artist: String, artwork: MPMediaItemArtwork, album: String) {
        self.init()
        self.name = name
        self.artist = artist
        self.album = album
        self.artwork = artwork
    }
    
    // This lets us map property names in our model to JSON keys when the names and keys aren’t the same.
    enum CodingKeys : String, CodingKey {
        case name = "trackName"
        case artist = "artistName"
        case previewUrl = "previewUrl"
        case artworkUrl = "artworkUrl100"
        case album = "collectionName"
    }
    
    /*
    Get song data from MediaItem
    */
    static func mediaItemToSongs(items: [MPMediaItem]) -> [Song]? {
        var songs: [Song] = []
        for item in items {
            let song = Song(name: item.title!, artist: item.artist!, artwork: item.artwork!, album: item.albumTitle!)
            songs.append(song)
        }
        return songs
    }
    
    /*
     JSON Decode version of function
     */
    static func dataToSongsDecode(data: Data?) -> [Song]? {
        guard let data = data else {
            print("Error: Nothing to decode")
            return nil
        }
        guard let songWrapper = try? JSONDecoder().decode(SongsWrapper.self, from: data) else {
            print(data)
            print("Error: Unable to decode songs data to Songs")
            return nil
        }
        print("Success")
        
        return songWrapper.results
    }
    
    /*
     
    This method takes in NSData optional and returns an array of objects of class Song.
     
    */
    static func dataToSongs(_ data : Data?) -> [Song]? {
        // Inspired by: https://www.raywenderlich.com/110458/nsurlsession-tutorial-getting-started
        var searchResults = [Song]()
        do {
            if let data = data, let response = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue:0)) as? [String: AnyObject] {
                
                // Get the results array
                if let array: AnyObject = response["results"] {
                    for songDictonary in array as! [AnyObject] {
                        if let songDictonary = songDictonary as? [String: AnyObject], let previewUrl = songDictonary["previewUrl"] as? String {
                            // Parse the search result
                            let name = songDictonary["trackName"] as? String
                            let artist = songDictonary["artistName"] as? String
                            let artworkUrl = songDictonary["artworkUrl100"] as? String
                            let album = songDictonary["collectionName"] as? String
                            searchResults.append(Song(name: name!, artist: artist!, previewUrl: previewUrl, artworkUrl: artworkUrl!, album: album!))
                        } else {
                            print("Not a dictionary")
                        }
                    }
                } else {
                    print("Results key not found in dictionary")
                }
                
                return searchResults
                
            } else {
                print("JSON Error")
            }
        } catch let error as NSError {
            print("Error parsing results: \(error.localizedDescription)")
        }
        return nil
    }
}
