//
//  VideoTableViewCell.swift
//  BraidMaster
//
//  Created by Kirill Lukyanov on 21.06.2018.
//  Copyright © 2018 Kirill Lukyanov. All rights reserved.
//

import UIKit
import AVFoundation

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var videoPlayerSuperView: UIView!{
        didSet {
            videoPlayerSuperView.translatesAutoresizingMaskIntoConstraints = false
            
        }
    }
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var paused: Bool = false
//    var videoResolution: CGSize?
    var videoPlayerItem: AVPlayerItem? = nil {
        didSet {
            avPlayer?.replaceCurrentItem(with: self.videoPlayerItem)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupMoviePlayer()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
    func setupMoviePlayer(){
        print("setup")
        self.avPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resize
        avPlayer?.volume = 0
        
        avPlayer?.actionAtItemEnd = .none
//        if let resolution = videoResolution {
//            let const = resolution.height / resolution.width
//            let height = ceil(self.frame.width * const)
//            avPlayerLayer?.frame.size.width = self.frame.width
//            self.frame.size.height = height
//            avPlayerLayer?.frame.size.height = height
//        }
        avPlayerLayer?.frame.size.width = self.frame.width
        avPlayerLayer?.frame.size.height = self.frame.height
        self.backgroundColor = .clear
        self.videoPlayerSuperView.layer.insertSublayer(avPlayerLayer!, at: 0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer?.currentItem)
        //        self.avPlayer?.play()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
//        videoFrame()
        avPlayerLayer?.frame.size.width = self.frame.width
        avPlayerLayer?.frame.size.height = self.frame.height
    }
    
//    func videoFrame()  {
//        if let resolution = videoResolution {
//            let const = resolution.height / resolution.width
//            let height = ceil(self.frame.width * const)
//            avPlayerLayer?.frame.size.width = self.frame.width
//            self.frame.size.height = height
//            avPlayerLayer?.frame.size.height = height
//            self.backgroundColor = .clear
//        }
//    }
//
    func stopPlayback(){
        self.avPlayer?.pause()
    }
    
    func startPlayback(){
        self.avPlayer?.play()
    }
    
    // A notification is fired and seeker is sent to the beginning to loop the video again
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero)
    }

}
