//
//  FriendUpdateViewController.swift
//  Project2
//
//  Created by virdeshp on 6/30/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import UIKit
import MediaPlayer

/*
 
    This is the Search/Friend updates view controller. Only the FriendUpdates part of it has been implemented to some extent.
 
    The friend updates load in the table view and the user can tap on any one of them to view them full screen. The updates are hardcoded right now. The full screen view is displyed by segueing to ShowUpdateController
 
 */


class FriendUpdateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
   
    @IBOutlet weak var tableView: UITableView!
    var letsSeeUpdate = ShowUpdateController()
    let userDefaults = UserDefaults.standard
    var updates: [Update]?
    let searchController = UISearchController(searchResultsController: nil)
    var temp_albumArt_string: String?
    var temp_player_string: String?
    var temp_song_ID: String?
    var temp_start_float: Float?
    var temp_end_float: Float?
    var temp_lyric_var: String?
    let imageCacheManager = ImageCacheManager()
    
    
    struct Storyboard {
        
        static let FriendUpdateCell = "FriendUpdateCell"
        static let postCellDefaultHeight: CGFloat = 70.00
    }
    
    let menuBar: MenuBar = {
        let mb = MenuBar()
        return mb
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         /*
            This search bar does nothing right now, ignore all the search controller part
        */
        //let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search Posts"
        //self.searchBar = searchController.searchBar
        //navigationItem.searchController = searchController
        //self. = searchController.searchBar
        //self.tableView.tableHeaderView = searchController.searchBar
        navigationItem.titleView = searchController.searchBar
        //navigationItem.titleView?.backgroundColor = UIColor.init(red: (247.0/255.0), green: (247.0/255.0), blue: (247.0/255.0), alpha: 1.0)
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
    
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
        
        self.tableView.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self as? UIGestureRecognizerDelegate
        
        self.fetchUpdates() //pull all the firend updates and load them into the table
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = Storyboard.postCellDefaultHeight //estimate the minimum height to  be this value
        self.tableView.rowHeight = UITableView.automaticDimension //Actual height resized as per autolayout
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        self.tableView.separatorColor = UIColor.gray //we don't want the default separator between the cells to be seen
        
        self.tableView.contentInset = UIEdgeInsets.init(top: 50, left: 0, bottom: 0, right: 0)
        self.tableView.scrollIndicatorInsets = UIEdgeInsets.init(top: 50, left: 0, bottom: 0, right: 0)

        // Do any additional setup after loading the view.
        
        setupMenuBar()
        
        
        
    }
    
   
    private func setupMenuBar() {
        
        view.addSubview(menuBar)
        view.addConstraintWithFormat(format: "H:|[v0]|", views: menuBar)
        view.addConstraintWithFormat(format: "V:|-75-[v0(50)]", views: menuBar)
        
        
    }
 


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchUpdates()
    {
        self.updates = Update.fetch_update()
        self.tableView.reloadData()
        
    }
    
    
    //When user taps on an update - grab all the update details from the cell on temp variables so we can pass them on in prepareforsegue
    @objc func tapEdit(recognizer: UITapGestureRecognizer)  {
        if recognizer.state == UIGestureRecognizer.State.ended {
            let tapLocation = recognizer.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if let tappedCell = self.tableView.cellForRow(at: tapIndexPath) as? FriendUpdateCell {
                    //UIApplication.shared.keyWindow?.rootViewController?.present(letsSeeUpdate, animated: true, completion: nil)
                    //letsSeeUpdate.show()
                    temp_albumArt_string = tappedCell.update.albumArt
                    temp_player_string = tappedCell.update.playerType
                    temp_song_ID = tappedCell.update.SongID
                    temp_start_float = tappedCell.update.start_time
                    temp_end_float = tappedCell.update.end_time
                    temp_lyric_var = tappedCell.update.lyric
                    print(tappedCell.update.albumArt)
                    print(temp_albumArt_string)
                    
                    performSegue(withIdentifier: "ShowUpdateSegue", sender: self)
                    /*
                    self.navigationController?.navigationBar.isHidden = true
                        self.tabBarController?.tabBar.isHidden = true
                    */
                    
                }
            }
        }
    }
    
    //pass all the update/post details on to ShowUpdateController and setup app/spotify players
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowUpdateSegue" {
            if let destination = segue.destination as? ShowUpdateController {
                
                destination.song_ID = temp_song_ID
                imageCacheManager.fetchImage(url: URL(string: temp_albumArt_string!)!, completion: { (image) in
                    destination.albumArt.image = image
                })
                //destination.albumArt_string =  temp_albumArt_string
                destination.player = temp_player_string
                destination.update_start = temp_start_float
                destination.update_end = temp_end_float
                destination.lyric_text = temp_lyric_var
                if destination.player == "Youtube"{
                destination.youtube_player_setup()
                }else if destination.player == "Spotify"{
                    destination.Spotifyplayer.queueSpotifyURI(destination.song_ID, callback: { (error) in
                        if (error == nil) {
                            print("queued!")
                        }
                        
                    })
                }else {
                    destination.apple_music_player.setQueue(with: [destination.song_ID])
                }
            }
        }
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        print("yes 1")
        if let updates = updates {  //because it is optional
            return updates.count   //number of sections = number of updates
        }
        return 0
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("yes 2")
        if let _ = updates {
            return 1    //there is only one row in every section
        }
        else {
            return 0
        }
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("yes 3")
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.FriendUpdateCell, for: indexPath) as! FriendUpdateCell
        cell.update = self.updates?[indexPath.section]
        cell.selectionStyle = .none
        return cell
    }

    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
   
    
}

