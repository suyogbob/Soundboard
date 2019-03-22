//
//  SongViewController.swift
//  Stripify
//
//  Created by Yagil Burowski on 26/09/2016.
//  Copyright © 2016 CIS 195 University of Pennsylvania. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

@available(iOS 10.3, *)
class SongViewController: UIViewController {
    

    var audioPlayer : AVPlayer?
    var songURL: String?
    var artworkURL: String?
    var artworkImg: MPMediaItemArtwork?
    var image: UIImage?
    var song: Song?
    var isPlaying : Bool = true
    var isLocal : Bool = false
    var netManager : NetworkManager?
    var fireManager: FirebaseManager?
    var myMediaPlayer : MPMusicPlayerApplicationController?
    
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        setupPlayer()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        if audioPlayer != nil {
            audioPlayer?.pause()
        }
    }

    
    
    func setupPlayer() {
        // MARK: - TODO: Implement setupPlayer()
        var url : NSURL?
        if let songUrl = songURL {
            url = NSURL(string: songUrl)
        }
        if let artworkURL = artworkURL {
            let imgUrl = NSURL(string: artworkURL)!
            netManager?.getSongArtwork(url: imgUrl as URL, closure: { (results) in
                // getting the image
                self.image = UIImage(data: results)
                
                //displaying the image
                DispatchQueue.main.async {
                    self.artwork.image = self.self.image
                }
            })
        }
        if let artworkImg = artworkImg {
            self.image = artworkImg.image(at: CGSize(width: artwork.frame.width, height: artwork.frame.height))
            //displaying the image
            DispatchQueue.main.async {
                self.artwork.image = self.self.image
            }
        }
        
        DispatchQueue.main.async() {
            if let url = url {
                self.audioPlayer = AVPlayer(url: url as URL)
                self.audioPlayer?.play()
//                self.audioPlayer?.actionAtItemEnd = AVPlayerActionAtItemEnd.advance
            } else {
                self.myMediaPlayer?.play()
            }
            self.titleLabel.text = self.song?.name
            self.artistLabel.text = self.song?.artist
            
            // This code handles updating the view periodically
            let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
         
            self.audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: nil, using: { (time : CMTime) in
                
                self.updateCurrentProgress(time)
                // Read this: https://developer.apple.com/reference/avfoundation/avplayer/1385829-addperiodictimeobserver
                
            })
            
            self.populateSongDurationLabel()
            
        }
        
    }
    
    func getSongData(song: Song) {
        songURL = song.previewUrl
        artworkURL = song.artworkUrl
        let url = NSURL(string: songURL!)
        if let artworkURL = artworkURL {
            let imgUrl = NSURL(string: artworkURL)!
            netManager?.getSongArtwork(url: imgUrl as URL, closure: { (results) in
                // getting the image
                self.image = UIImage(data: results)

                //displaying the image
                DispatchQueue.main.async {
                    self.artwork.image = self.self.image
                }
            })
        }
        if let artworkImg = artworkImg {
            self.image = artworkImg.image(at: CGSize(width: artwork.frame.width, height: artwork.frame.height))
            //displaying the image
            DispatchQueue.main.async {
                self.artwork.image = self.self.image
            }
        }

        DispatchQueue.main.async() {
            if url != nil {
                self.audioPlayer?.replaceCurrentItem(with: AVPlayerItem(url: url! as URL))
                self.audioPlayer?.play()
            } else {
                self.myMediaPlayer?.play()
            }
            self.titleLabel.text = song.name
            self.artistLabel.text = song.artist

            self.populateSongDurationLabel()
            self.audioPlayer?.play()
        }
    }
    
    @IBAction func didPressPlayPause(_ sender: Any) {
        if !isLocal {
            
            if (audioPlayer!.rate != 0 && audioPlayer!.error == nil) {
                audioPlayer?.pause()
            } else {
                audioPlayer?.play()
            }
        } else {
            if myMediaPlayer!.currentPlaybackRate != 0 {
                myMediaPlayer?.pause()
            } else {
                myMediaPlayer?.play()
            }
        }
        
    }
    
    
    func populateSongDurationLabel() {
        
        // MARK: - TODO: complete this function
        
        if let totalSeconds = audioPlayer?.currentItem?.asset.duration.seconds {
            
            /* When we load the song we want to indicate it's duration.
               We set the right hand label to the total duration of the song
               in the form: m:ss
               
               Reminder: 3600 seconds is 60 minutes
             
             */
            let secs = Int(round(totalSeconds.truncatingRemainder(dividingBy: 60.0)))
            let mins = (Int(totalSeconds) - secs) / 60
            let time: String = "\(mins):\(secs)"
            endTimeLabel.text = time
            
        }
        
        if let totalSeconds = myMediaPlayer?.nowPlayingItem?.playbackDuration {
            let secs = Int(round(totalSeconds.truncatingRemainder(dividingBy: 60.0)))
            let mins = (Int(totalSeconds) - secs) / 60
            let time: String = "\(mins):\(secs)"
            endTimeLabel.text = time
        }
    }
    
    
    func updateCurrentProgress(_ time : CMTime) {
        
        // MARK: - TODO: update view
        if (!isLocal) {
            progressBar.setProgress(Float(CMTimeGetSeconds((audioPlayer?.currentTime())!) / (audioPlayer?.currentItem?.asset.duration.seconds)!), animated: true)
        } else {
            if let current = myMediaPlayer?.currentPlaybackTime, let total = myMediaPlayer?.nowPlayingItem?.playbackDuration {
                print("\(current)/\(total)")
                progressBar.setProgress(Float(current / total), animated: true)
            }
            
        }
        
    }
    
    
    @IBAction func nextInQueue(_ sender: Any) {
        if !((netManager?.queue.isEmpty)!) {
            netManager?.queue.remove(at: 0)
            if !((netManager?.queue.isEmpty)!) {
                if let song = netManager?.queue[0] {
                    getSongData(song: song)
                }
            }
        }
    }
    
    
    // setup song segue stuff
//    func getSongItems() -> [AVPlayerItem] {
//        var list : [AVPlayerItem] = []
//        if let queue = netManager?.queue {
//            for song in queue {
//                let url = NSURL(string: song.previewUrl)
//                let item = AVPlayerItem(url: url! as URL)
//                list.append(item)
//            }
//        }
//        return list
//    }
}
