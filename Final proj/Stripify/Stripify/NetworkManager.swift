//
//  NetworkManager.swift
//  Stripify
//
//  Created by Yagil Burowski on 26/09/2016.
//  Copyright © 2016 CIS 195 University of Pennsylvania. All rights reserved.
//

import Foundation
import UIKit

class NetworkManager {
    
    var songs = [Song]()
    var queue = [Song]()
    /* 
     // MARK: - TODO: implement NetworkManager methods
       This class is responsible for querying iTunes API
       You need to use closures/completion handlers to define this function.
    
       Completion handlers: https://thatthinginswift.com/completion-handlers/
       
       Function body help: https://gist.github.com/yagil/d35b419410a2677ba04dcf6f04197444
     
     */
    
    func querySong(term: String, closure: @escaping (_ results: Data) -> ()) {
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        
        var dataTask: URLSessionDataTask?
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        let expectedCharSet = CharacterSet.urlQueryAllowed
        let searchTerm = term.addingPercentEncoding(withAllowedCharacters: expectedCharSet)!
        
        let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=\(searchTerm)")
        
        dataTask = defaultSession.dataTask(with: url!, completionHandler: {
            data, response, error in
            if error != nil {
                
                print(error!.localizedDescription)
                closure(Data.init())
                
            } else if let httpResponse = response as? HTTPURLResponse {
                
                if httpResponse.statusCode == 200 {
                    
                    if let songData = data {
                        closure(songData)
                    }
                    
                }
            }
        })
        
        dataTask?.resume()
        
    }
    
    func getSongArtwork(url: URL, closure: @escaping (_ results: Data) -> ()) {
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        let getImageFromUrl = defaultSession.dataTask(with: url) { (data, response, error) in
            
            //if there is any error
            if let e = error {
                //displaying the message
                print("Error Occurred: \(e)")
                
            } else {
                //checking if the response contains an image
                if let imageData = data {
                    let image = UIImage(data: imageData)
                    if (image == nil) {
                        print("image was nil")
                    }
                    closure(imageData)
                } else {
                    print("Image file is currupted")
                }
            }
        }
        getImageFromUrl.resume()
    }
    
    func setSongs(songList: [Song]) -> () {
        songs = songList
    }
    
    func getSong(index: Int) -> Song {
        let song = songs[index]
        return song
    }
    
    func addToQueue(_ song: Song) -> () {
        queue.insert(song, at: 0)
        print ("added to queue")
    }
}
