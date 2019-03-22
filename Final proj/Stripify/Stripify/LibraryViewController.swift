//
//  LibraryViewController.swift
//  Stripify
//
//  Created by Suyog Bobhate on 09/04/18.
//  Copyright © 2018 CIS 195 University of Pennsylvania. All rights reserved.
//

import UIKit
import MediaPlayer

@available(iOS 10.3, *)
class LibraryViewController: UITableViewController {
    
    var netManager : NetworkManager?
    var fireManager : FirebaseManager?
    var selectedSong : Song?
    var myMediaPlayer : MPMusicPlayerApplicationController?
    var itemMedia : [MPMediaItem] = []
    var idx : Int?
    
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 270, height: 20))
    lazy var menuLauncher: MenuLauncher = {
        let launcher = MenuLauncher()
        launcher.libraryController = self
        return launcher
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        netManager = NetworkManager.init()
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        tableView.rowHeight = 100
        // Instantiate a new music player
        myMediaPlayer = MPMusicPlayerApplicationController.applicationQueuePlayer
        // myMediaPlayer.setQueue(with: MPMediaQuery.songs())
        // Start playing from the beginning of the queue
        // myMediaPlayer.play()
        
        
    }
    
    
    override func awakeFromNib() {
        // setup search bar
        let leftNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        
    }
    
    @IBAction func search(_ sender: AnyObject) {
        if let term = searchBar.text {  // Xcode gives a warning becuase "term" is not used anywhere yet
            // TODO: - implement querying song by term
            let pred1 = MPMediaPropertyPredicate(value: term, forProperty: "title", comparisonType: .contains)
//            let pred3 = MPMediaPropertyPredicate(value: term, forProperty: "ablumTitle", comparisonType: .contains)
            let query = MPMediaQuery.init(filterPredicates: [pred1])
            if let mediaItems = query.items {
                if let songs = Song.mediaItemToSongs(items: mediaItems) {
                    self.itemMedia = mediaItems
                    self.netManager?.setSongs(songList: songs)
                    DispatchQueue.main.async() {
                        self.tableView.reloadData()
                    }
                }
            }
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
    
    
    //
    // Functions for Menu Handling
    //
    
    @IBAction func handleMenu(_ sender: Any) {
        resignFirstResponder()
        menuLauncher.showMenu()
        
    }
    
    func showControllerForMusic(menuItem: MenuItem) {
        if (menuItem.name == "Samples from iTunes") {
            performSegue(withIdentifier: "toSearch", sender: Any?.self)
        }
        if (menuItem.name == "Music Near Me") {
            performSegue(withIdentifier: "toNearMe", sender: Any?.self)
        }
        // stuff
    }
    
    //
    // Functions for tableview
    //
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (netManager?.songs.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        if let songCell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongTableViewCell {
            if let song = netManager?.songs[indexPath.row] {
                songCell.songName.text = song.name
                songCell.artistName.text = song.artist
                songCell.albumName.text = " ~ " + song.album
                return songCell
            }
        }
        return UITableViewCell()
    }
    
    override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Do something when cell is selected...
        selectedSong = netManager?.getSong(index: indexPath.row)
        idx = indexPath.row
         myMediaPlayer?.nowPlayingItem = itemMedia[idx!]
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
            if let artwork = selectedSong?.artwork {
                destination.artworkImg = artwork
            }
            destination.song = selectedSong
            destination.isLocal = true
            destination.netManager = self.netManager
            destination.myMediaPlayer = self.myMediaPlayer
        }
    }

}
