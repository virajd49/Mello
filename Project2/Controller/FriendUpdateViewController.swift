//
//  FriendUpdateViewController.swift
//  Project2
//
//  Created by virdeshp on 6/30/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import UIKit
import MediaPlayer


struct Candy{
    
    var category : String
    var name: String
}


class FriendUpdateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
   
    @IBOutlet weak var tableView: UITableView!
    
    var letsSeeUpdate = ShowUpdateController()
    var filteredCandies = [Candy]()
    let userDefaults = UserDefaults.standard
    var updates: [Update]?
    let searchController = UISearchController(searchResultsController: nil)
    var temp_albumArt_string: String?
    var temp_player_string: String?
    var temp_song_string: String?
    
    
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
        
         
        //let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search Candies"
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
        
        self.fetchUpdates()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = Storyboard.postCellDefaultHeight //estimate the minimum height to  be this value
        self.tableView.rowHeight = UITableViewAutomaticDimension //Actual height resized as per autolayout
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        self.tableView.separatorColor = UIColor.gray //we don't want the default separator between the cells to be seen
        
        self.tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(50, 0, 0, 0)

        // Do any additional setup after loading the view.
        
        setupMenuBar()
        
        
        
    }
    
   
        private func setupMenuBar(){
        
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
    
    @objc func tapEdit(recognizer: UITapGestureRecognizer)  {
        if recognizer.state == UIGestureRecognizerState.ended {
            let tapLocation = recognizer.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if let tappedCell = self.tableView.cellForRow(at: tapIndexPath) as? FriendUpdateCell {
                    //UIApplication.shared.keyWindow?.rootViewController?.present(letsSeeUpdate, animated: true, completion: nil)
                    //letsSeeUpdate.show()
                    temp_albumArt_string = tappedCell.update.albumArt
                    //temp_player_string = tappedCell.update.playerType
                    temp_player_string = "Youtube"
                    temp_song_string = tappedCell.update.SongID
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowUpdateSegue" {
            if let destination = segue.destination as? ShowUpdateController {
                
                destination.albumArt_string =  temp_albumArt_string
                destination.song_name = temp_song_string
                destination.player = temp_player_string
                destination.youtube_player_setup()
                destination.youtubeplayer?.load(withVideoId: "U_xI_vKkkmg" , playerVars: ["playsinline": 1, "showinfo": 0, "modestbranding" : 1, "controls": 1, "start": 26, "end": 84, "rel": 0])
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
    
    
   
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select row at")
        performSegue(withIdentifier: "ShowUpdateSegue", sender: self)
    }
    */
    
    

    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    /*
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredCandies = candies.filter({( candy : Candy) -> Bool in
            return candy.name.lowercased().contains(searchText.lowercased())
        })
        
        //tableView.reloadData()
    }
 */
    
}

/*
extension FriendUpdateViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)

    }
}
*/
