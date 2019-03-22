//
//  FirebaseManager.swift
//  Stripify
//
//  Created by Suyog Bobhate on 06/04/18.
//  Copyright © 2018 CIS 195 University of Pennsylvania. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CoreLocation

struct SongLoc {
    var SongName: String
    var Location: CLLocation
    
}

protocol FirebaseManagerDelegate {
    func didUpdateLocations()
}

class FirebaseManager {
    
    var ref: DatabaseReference!
    var locations: [SongLoc] = []
    var currLoc : CLLocation?
    var delegate : FirebaseManagerDelegate?
    
    
    init() {
        ref = Database.database().reference()
        self.ref.child("Locations")
    }
    
    func observeLocations() {
        
        ref.observe(.childAdded) { (snapshot) in
            if snapshot.exists() {
                if let locationData = snapshot.value as? [String: String] {
                    let location = CLLocation(latitude: Double(locationData["latitude"]!)!, longitude: Double(locationData["longitude"]!)!)
                    let song = locationData["song"]!
                    let songLoc = SongLoc(SongName: song, Location: location)
                    self.locations.append(songLoc)
                    self.delegate?.didUpdateLocations()
                }
            }
        }
    }

    func stopObservingLocations() {
        ref.removeAllObservers()
    }

    func configureDefaultReference() {
        ref = Database.database().reference().child("Locations")
    }

    func addSongLoc(songLoc: SongLoc) {
        let songDict = ["latitude": String(songLoc.Location.coordinate.latitude),
                       "longitude": String(songLoc.Location.coordinate.longitude),
                       "song": songLoc.SongName]
        ref.childByAutoId().setValue(songDict)
    }
    
    
}
