//
//  AVQueuePlayerPrevious.swift
//  AudioQueuePlayer
//
//  Created by Lyt on 17/05/16.
//  Copyright © 2016 Lyt. All rights reserved.
//

import Foundation
import AVFoundation

class AVQueuePlayerPrevious : AVQueuePlayer {
    
    public var nowPlayingIndex = 0
    public var playlist: NSMutableArray = NSMutableArray()
    var isCalledFromPlayPreviousItem = false
    
    override init() {
        super.init()
    }
    
    override convenience init(URL: NSURL) {
        self.init(items: [AVPlayerItem(URL: URL)])
    }
    
    override convenience init(playerItem item: AVPlayerItem) {
        self.init(items: [item])
    }
    
    override init(items: [AVPlayerItem]) {
        super.init(items: items)
        self.playlist = NSMutableArray(array: items)
        for item in items {
            NSNotificationCenter.defaultCenter()
                .addObserver(self, selector: #selector(onAdvancedToNextItem), name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
        }
    }
    
    public func rewindToPreviousItem() {
        if (isAtBeginning()) {
            self.seekToTime(kCMTimeZero)
        } else {
            self.pause()
            self.seekToTime(kCMTimeZero)
            let tmpNowPlayingIndex = nowPlayingIndex
            let tmpPlaylist = NSMutableArray(array: playlist)
            self.removeAllItems()
            
            isCalledFromPlayPreviousItem = true
            let newQueueRange = NSRange(location: tmpNowPlayingIndex - 1, length: playlist.count - tmpNowPlayingIndex)
            for item in tmpPlaylist.subarrayWithRange(newQueueRange) as! [AVPlayerItem] {
                self.insertItem(item, afterItem: nil)
            }
            isCalledFromPlayPreviousItem = false
            
            nowPlayingIndex = tmpNowPlayingIndex - 1
            self.seekToTime(kCMTimeZero)
            self.play()
        }
    }
    
    public func isAtBeginning() -> Bool {
        return nowPlayingIndex == 0
    }
    
    func onAdvancedToNextItem() {
        if (nowPlayingIndex < playlist.count - 1) {
            nowPlayingIndex += 1
        }
    }
    
    
    //MARK: --- Overridden AVQueuePlayer methods
    
    override func removeAllItems() {
        super.removeAllItems()
        nowPlayingIndex = 0
        playlist.removeAllObjects()
    }
    
    override func removeItem(item: AVPlayerItem) {
        super.removeItem(item)
        let curItem = playlist[nowPlayingIndex]
        playlist.removeObject(item)
        nowPlayingIndex = playlist.indexOfObject(curItem)
    }
    
    override func advanceToNextItem() {
        super.advanceToNextItem()
        onAdvancedToNextItem()
    }
    
    override func insertItem(item: AVPlayerItem, afterItem: AVPlayerItem?) {
        super.insertItem(item, afterItem: afterItem)
        let curItem = playlist[nowPlayingIndex]
        
        if (afterItem != nil && playlist.containsObject(afterItem!)) {
            playlist.insertObject(item, atIndex: playlist.indexOfObject(afterItem!) + 1)
        } else {
            playlist.addObject(item)
        }
        nowPlayingIndex = playlist.indexOfObject(curItem)
    }
}