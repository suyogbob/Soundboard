//
//  SearchViewController.swift
//  Stripify
//
//  Created by Yagil Burowski on 26/09/2016.
//  Copyright © 2016 CIS 195 University of Pennsylvania. All rights reserved.
//

import UIKit
import CoreLocation


@available(iOS 10.3, *)
class SearchViewController: UITableViewController {
    
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 270, height: 20))
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    var netManager : NetworkManager?
    var selectedSong : Song?
    var lastQueued : Song?
    var iPath : IndexPath?
    var fireManager : FirebaseManager?
    lazy var menuLauncher: MenuLauncher = {
        let launcher = MenuLauncher()
        launcher.searchController = self
        return launcher
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        netManager = NetworkManager.init()
        fireManager = FirebaseManager()
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        fireManager?.configureDefaultReference()
        fireManager?.observeLocations()
        
    }
    
    override func awakeFromNib() {
        // setup search bar
        let leftNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        
    }

    @IBAction func search(_ sender: AnyObject) {
        if let term = searchBar.text {  // Xcode gives a warning becuase "term" is not used anywhere yet
            // TODO: - implement querying song by term
            netManager?.querySong(term: term, closure: { (results) in
                if results.isEmpty {
                    print("error found")
                } else {
                    if let songs = Song.dataToSongsDecode(data: results) {
                        self.netManager?.setSongs(songList: songs)
                        DispatchQueue.main.async() {
                            self.tableView.reloadData()
                        }
                    }
                }
            })
            /*
 
             When you (a) query and (b) parse your results,
             Call the following code snippet in your completion handler:
             
             dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
             }
             
             Read more: https://thatthinginswift.com/background-threads/
             
            */
            
        }
    }
    
    @IBAction func mapSearch(segue: UIStoryboardSegue) {
        if let source = segue.source as? MapViewController {
            if let term = source.term {
                netManager?.querySong(term: term, closure: { (results) in
                    if results.isEmpty {
                        print("error found")
                    } else {
                        if let songs = Song.dataToSongsDecode(data: results) {
                            self.netManager?.setSongs(songList: songs)
                            DispatchQueue.main.async() {
                                self.tableView.reloadData()
                            }
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func handleMenu(_ sender: Any) {
        menuLauncher.showMenu()
        
    }
    
    func showControllerForMusic(menuItem: MenuItem) {
        if (menuItem.name == "Local Music") {
            performSegue(withIdentifier: "toLibrary", sender: Any?.self)
        }
        if (menuItem.name == "Music Near Me") {
            performSegue(withIdentifier: "toNearMe", sender: Any?.self)
        }
        // stuff
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (netManager?.songs.count)!
    }
    
    
    // MARK: - TODO: implement the delegate and datasource methods
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
     // Configure the cell...
        if let songCell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongTableViewCell {
            if let song = netManager?.songs[indexPath.row] {
                songCell.songName.text = song.name
                songCell.artistName.text = song.artist
                songCell.albumName.text = " ~ " + song.album
                // add gesture recognizer
               // return
                return songCell
            }
        }
        return UITableViewCell()
     }
    
//    @objc func didSwipe(recognizer: UIGestureRecognizer) -> () {
//        // check for two taps
//        if recognizer.state == .ended {
//            lastQueued = netManager?.getSong(index: iPath!.row)
//            netManager?.addToQueue(lastQueued!)
//        }
//    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .normal, title: "Add to Queue", handler: didSwipeForQueue)
        return [action]
    }
    
    func didSwipeForQueue(_ rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void {
        lastQueued = netManager?.getSong(index: indexPath.row)
        netManager?.addToQueue(lastQueued!)
    }
    
    
    override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    // Do something when cell is selected...
        selectedSong = netManager?.getSong(index: indexPath.row)
        netManager?.addToQueue(selectedSong!)
        performSegue(withIdentifier: "songPlayer", sender: self)
        
    }
    

    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if let destination = segue.destination as? SongViewController {
            // Pass the selected object to the new view controller.
            if let previewUrl = selectedSong?.previewUrl {
                destination.songURL = previewUrl
            }
            if let artworkUrl = selectedSong?.artworkUrl {
                destination.artworkURL = artworkUrl
            }
            destination.song = selectedSong
            destination.isLocal = false
            destination.netManager = self.netManager
            if let location = fireManager?.currLoc {
                let songLoc = SongLoc(SongName: (selectedSong?.name)!, Location: location)
                fireManager?.addSongLoc(songLoc: songLoc)
            }
            destination.fireManager = self.fireManager
        }
        if let destination = segue.destination as? MapViewController {
            destination.firebaseManager = self.fireManager
        }
    }

}
