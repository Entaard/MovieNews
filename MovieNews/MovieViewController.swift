//
//  MovieViewController.swift
//  MovieNews
//
//  Created by Enta'ard on 10/11/16.
//  Copyright © 2016 Enta'ard. All rights reserved.
//

import UIKit
import ARSLineProgress

class MovieViewController: UIViewController, UISearchBarDelegate {

    let searchBar = UISearchBar()
    
    @IBOutlet weak var layoutControl: UISegmentedControl!
    @IBOutlet weak var layoutControlButtons: UIBarButtonItem!
    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var gridContainer: UIView!
    @IBOutlet weak var networkNoti: UILabel!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    var storedLayoutButtons = UIBarButtonItem()
    var storedSearchButton = UIBarButtonItem()
    var movies = [NSDictionary]()
    var searchResults = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storedLayoutButtons = layoutControlButtons
        storedSearchButton = searchButton
        
        createSearchBar()
        
        loadMovies(hasLoadingHud: true)
        chooseLayout(selectedSegmentIndex: layoutControl.selectedSegmentIndex)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeLayout(_ sender: AnyObject) {
        chooseLayout(selectedSegmentIndex: layoutControl.selectedSegmentIndex)
    }
    
    @IBAction func showSearchBar(_ sender: AnyObject) {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.titleView = searchBar
        searchBar.showsCancelButton = true
        searchBar.text = ""
        searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.leftBarButtonItem = storedLayoutButtons
        self.navigationItem.rightBarButtonItem = storedSearchButton
        self.navigationItem.titleView = nil
        searchBar.endEditing(true)
        
        searchMovies(withSearchTerm: "")
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let searchTerm = searchBar.text ?? ""
//        searchMovies(withSearchTerm: searchTerm)
        searchBar.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchMovies(withSearchTerm: searchText)
    }
    
    func loadMovies(refreshControl: UIRefreshControl? = nil, hasLoadingHud: Bool) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = URLRequest(
            url: url!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        // display loading HUD
        if hasLoadingHud {
            ARSLineProgress.show()
        }
        
        let task: URLSessionDataTask =
            session.dataTask(with: request,
                             completionHandler: { (dataOrNil, response, error) in
                                if let data = dataOrNil {
                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                        with: data, options:[]) as? NSDictionary {
                                        
                                        self.movies = responseDictionary["results"] as! [NSDictionary]
                                        
                                        let tableViewController = self.childViewControllers[0] as! TableViewController
                                        tableViewController.movies = self.movies
                                        tableViewController.movieTable.reloadData()
                                        
                                        let gridViewController = self.childViewControllers[1] as! GridViewController
                                        gridViewController.movies = self.movies
                                        gridViewController.movieGrid.reloadData()
                                        
                                        // display success loaded HUD
                                        if hasLoadingHud {
                                            ARSLineProgressConfiguration.checkmarkAnimationDrawDuration = 0.2
                                            ARSLineProgressConfiguration.successCircleAnimationDrawDuration = 0.2
                                            ARSLineProgress.showSuccess()
                                        }
                                        // turn of network error noti
                                        self.networkNoti.isHidden = true
                                        // end refresh spining
                                        refreshControl?.endRefreshing()
                                        
                                    }
                                } else {
                                    // display fail loaded HUD
                                    if hasLoadingHud {
                                        ARSLineProgress.showFail()
                                    }
                                    self.networkNoti.isHidden = false
                                }
            })
        task.resume()
    }
    
    func chooseLayout(selectedSegmentIndex index: Int) {
        let animator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut, animations: {
            if index == 0 {
                self.tableContainer.alpha = 1
                self.gridContainer.alpha = 0
            } else {
                self.tableContainer.alpha = 0
                self.gridContainer.alpha = 1
            }
        })
        animator.startAnimation()
    }
    
    func createSearchBar() {
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Enter movie title here..."
        searchBar.delegate = self
    }
    
    func searchMovies(withSearchTerm searchTerm: String) {
        let tableViewController = self.childViewControllers[0] as! TableViewController
        let gridViewController = self.childViewControllers[1] as! GridViewController
        let searchText = searchTerm.trimmingCharacters(in: NSCharacterSet.whitespaces)
        
        if searchText == "" {
            tableViewController.movies = movies
            tableViewController.movieTable.reloadData()
            
            gridViewController.movies = movies
            gridViewController.movieGrid.reloadData()
        } else {
            searchResults = [NSDictionary]()
            for movie in movies {
                let title = movie["title"] as! String
                if (title.lowercased().range(of: searchText.lowercased()) != nil) {
                    searchResults.append(movie)
                }
            }
            if layoutControl.selectedSegmentIndex == 0 {
                tableViewController.movies = searchResults
                tableViewController.movieTable.reloadData()
            } else {
                gridViewController.movies = searchResults
                gridViewController.movieGrid.reloadData()
            }
        }
    }

}
