//
//  BottomView.swift
//  Project2
//
//  Created by virdeshp on 5/8/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import UIKit
import MediaPlayer


//These are the components of the cell - I don't know why I named it Settings
class Setting: NSObject {
    
    let name: String   //the displayed name of the playlist
    let nativeAppimageName: String  //displayed apple/spotify icon
    var addIconimageName: String    //the displayed delete/add icon
    let mediaItem: String               //this is not displayed, its used to access the playlist that is represented by the cell.
    
    init(name: String, nativeAppimageName: String, addIconimageName: String, mediaItem: String){
        self.name = name
        self.nativeAppimageName = nativeAppimageName
        self.addIconimageName = addIconimageName
        self.mediaItem = mediaItem
        
    }
    
}

/*
 
 This is the small view that pops up from the bottom of the screen when the user clicks the 'add' song button. It displays options from the user's streaming service library - to which the user can add the song:
 
    -Library
    -<playlist>
    -<playlist>
    -<playlist>
 
 
 It also checks if song that the user wants to add currently exists in any of these mediaItems or not. If it does, we display a 'delete' icon to show that the song already exists and if it doesn't, we display an 'add' symbol next to it.
 
 So here we -
 
    -Handle the instantiation of the view itself, which is a collection view.
    -Grab all playlists from Spotify/Apple based on user account
    -Figure out if the song is in any of them or not and display the add/delete options accordingly
 
 
 
 
 
 */

class BottomView: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let current_user = "Apple"
    var userDefaults = UserDefaults.standard
    var flag = false
    let blackview = UIView()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    //let playlist_access = UserAccess(musicPlayerController: MPMusicPlayerController.applicationMusicPlayer, myPlaylistQuery: MPMediaQuery.playlists(), myLibrarySongsQuery: MPMediaQuery.songs())
    //let playlist_access = UserAccess(myPlaylistQuery: MPMediaQuery.playlists(), myLibrarySongsQuery: MPMediaQuery.songs(), mypodcastsQuery: MPMediaQuery.podcasts())
    
    let cellID = "cellID"
    let cellHeight: CGFloat = 50
    var song_id = ""
    
    
    //An array for all the library playlists that will be displayed in the view
    var settings: [Setting]  =  {
        return [Setting(name: "Add to library", nativeAppimageName: "apple_logo", addIconimageName: "icons8-add-100", mediaItem: "Library")]
    }()
    
    
    //Get a list of all the playlist names from the users library and ad them to the settings array
    func get_playlist_data() {
        if self.current_user == "Apple"{
//           let list: [String] = playlist_access.getplaylist_title()
//            for i in 1...list.count-1 {
//                settings.append(Setting(name: "Add to " + list[i] , nativeAppimageName: "apple_logo", addIconimageName: "icons8-add-100", mediaItem: list[i]))
//            }
            
        } else{
            let dict: [String : String] = self.userDefaults.object(forKey: "Spotify_playlist_URIs") as! [String : String]
            for i in dict.keys {
                settings.append(Setting(name: "Add to " + i , nativeAppimageName: "apple_logo", addIconimageName: "icons8-add-100", mediaItem: i))
            }
        }
    }
   
    func bringupview(id: String) {
        
        //grab control of the window
        if let window = UIApplication.shared.keyWindow {
            
            print("here atleast")
            self.song_id = id
            //the view that dism out whatever's on the screen
            self.blackview.backgroundColor = UIColor(white: 0, alpha: 0.5)
            self.blackview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissview)))
            //self.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissview)))
            
            
            //add the views to the window
            window.addSubview(blackview)
            window.addSubview(collectionView)
            
            //get the users playlist data
            get_playlist_data()
            //self.playlist_access.getYourSpotifyLibrary()
            print("here atleast 2")
            
            //calculate height of the collection view depending on the number of cells involved
            let height: CGFloat = CGFloat(settings.count) * cellHeight
            let y = window.frame.height - height - 10.5
            collectionView.frame = CGRect(x: 12, y: window.frame.height, width: 351, height: height)
            collectionView.layer.cornerRadius = 10.0
            
            if self.current_user == "Spotify" {
//                self.playlist_access.get_spotify_all_tracks()
//                self.playlist_access.get_spotify_playlists()
            } else if self.current_user == "Apple" {
//                self.playlist_access.getplaylists()
//                self.playlist_access.getpodcasts()
            }
            
            //I forgot why I'm doing this twice, once here and once in dequeue
            for cell in self.collectionView.visibleCells as! [BottomViewCell] {
                var containing_mediaItem: [String] = [""]
                //print ("in dequeuereusable cell")
                if self.current_user == "Apple" {
//                    containing_mediaItem = (playlist_access.check_in_library(trackid: self.song_id))
                }else {
//                    containing_mediaItem = (playlist_access.spotify_check_in_a_playlist(trackURI: self.song_id))
                }
                print(self.song_id)
                print(cell.setting?.mediaItem)
                print(containing_mediaItem)
                if (containing_mediaItem.contains((cell.setting?.mediaItem)!)) {
                    cell.addIconImageView.image = UIImage(named: "icons8-waste-96")
                    print("added waste")
                    /* }else if (containing_mediaItem != "" && cell.setting?.mediaItem == "Library"){
                     cell.addIconImageView.image = UIImage(named: "icons8-waste-96")
                     print("added waste") */
                }else {
                    cell.addIconImageView.image = UIImage(named: "icons8-add-100")
                    print ("added plus")
                }
            }
            //print(self.userDefaults.object(forKey: "Spotify_playlist_URIs") as? [String] )
            //print(self.userDefaults.object(forKey: "Spotify_playlist_names") as? [String])
            
            print("here atleast 3")
            blackview.frame = window.frame
            self.blackview.alpha = 0
            
           
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackview.alpha = 1
                self.collectionView.frame = CGRect(x: 12, y: y, width: 351, height: self.collectionView.frame.height)
            }, completion: nil)
            
        }
    }
    
    @objc func dismissview() {
        print ("in dismiss")
        UIView.animate(withDuration: 0.5) {
            self.blackview.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: 351, height: self.collectionView.frame.height)
            }
        }
        
        while settings.count != 1 {
            settings.remove(at: settings.count-1)
            
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var containing_mediaItem: [String] = [""]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! BottomViewCell
        //print ("in dequeuereusable cell")
        
        //grab the setting for this cell from the settings array that we filled using the User's library and playlists data
        let setting = settings[indexPath.item]
        cell.setting = setting
        
        //We get every mediaItem - Library/playlist - that contains the song
        if self.current_user == "Apple" {
//            containing_mediaItem = (playlist_access.check_in_library(trackid: self.song_id))
        }else {
//            containing_mediaItem = (playlist_access.spotify_check_in_a_playlist(trackURI: self.song_id))
        }
        print(self.song_id)
        print(cell.setting?.mediaItem)
        print(containing_mediaItem)
        
        
        //If the current cells mediaItem is one of the one's that contain the song - use the 'delete' symbol - else use the 'add' symbol
        if (containing_mediaItem.contains((cell.setting?.mediaItem)!)) {
            cell.addIconImageView.image = UIImage(named: "icons8-waste-96")
            print("added waste")
       /* }else if (containing_mediaItem != "" && cell.setting?.mediaItem == "Library"){
            cell.addIconImageView.image = UIImage(named: "icons8-waste-96")
            print("added waste") */
        }else {
            cell.addIconImageView.image = UIImage(named: "icons8-add-100")
            print ("added plus")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    //Add a song to the selected playlist or Library when the user taps on the cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let setting = settings[indexPath.item]
        print("here")
        if self.current_user == "Spotify" {
//            playlist_access.add_spotify_media_item(mediacollection: setting.mediaItem, mediaItem: self.song_id)
        } else {
//            playlist_access.add_to_mediaItem(mediacollection: setting.mediaItem, mediaItem: self.song_id)
        }
        let cell = self.collectionView.cellForItem(at: indexPath) as! BottomViewCell?
        cell?.addIconImageView.image = UIImage(named: "icons8-waste-96")
        
        
    }
    
    override init() {
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BottomViewCell.self, forCellWithReuseIdentifier: cellID)
    }
}
