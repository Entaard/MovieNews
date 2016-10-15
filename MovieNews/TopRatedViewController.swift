//
//  TopRatedViewController.swift
//  MovieNews
//
//  Created by Enta'ard on 10/13/16.
//  Copyright © 2016 Enta'ard. All rights reserved.
//

import UIKit
import AFNetworking
import ARSLineProgress

class TopRatedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    let imgAPI  = "http://image.tmdb.org/t/p/w342"
    let searchBar = UISearchBar()

    @IBOutlet weak var topRatedTableView: UITableView!
    @IBOutlet weak var networkNoti: UILabel!
    
    var searchResults = [NSDictionary]()
    var movies = [NSDictionary]()
    var topRatedMovies = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSearchBar()

        topRatedTableView.dataSource = self
        topRatedTableView.delegate = self
        
        loadMovies(hasLoadingHud: true)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadMovies(refreshControl:hasLoadingHud:)), for: UIControlEvents.valueChanged)
        topRatedTableView.insertSubview(refreshControl, at: 0)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
        searchMovies(withSearchTerm: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let searchTerm = searchBar.text ?? ""
//        searchMovies(withSearchTerm: searchTerm)
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        searchMovies(withSearchTerm: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = topRatedTableView.dequeueReusableCell(withIdentifier: "TopRatedCell") as! TopRatedCell
        
        // img
        loadPosterImg(movie: movies[indexPath.section], atCell: cell)
        // title
        cell.titleLabel.text = movies[indexPath.section]["title"] as? String
        // voting
        let rating = movies[indexPath.section]["vote_average"] as? Float
        cell.ratingLabel.text = String.init(format: "%.2f", rating ?? 0)
        // voting count
        let ratingCount = movies[indexPath.section]["vote_count"] as? Float
        cell.ratingCountLabel.text = String.init(format: "%.0f", ratingCount ?? 0)
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchBar.endEditing(true)
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let detailViewController = segue.destination as! DetailViewController
        let rowPos = topRatedTableView.indexPathForSelectedRow!.section
        
        // title
        detailViewController.movieTitle = movies[rowPos]["title"] as? String
        // release date
        detailViewController.releaseDate = movies[rowPos]["release_date"] as? String
        // vote average
        detailViewController.voteAvg = movies[rowPos]["vote_average"] as? Float
        // vote count
        detailViewController.voteCount = movies[rowPos]["vote_count"] as? Float
        // description
        detailViewController.movieDescription = movies[rowPos]["overview"] as? String
        // img
        if let posterPath = movies[rowPos]["poster_path"] as? String {
            let posterURL = imgAPI + posterPath
            let imgView = UIImageView()
            imgView.setImageWith(URL(string: posterURL)!)
            detailViewController.postImg = imgView.image
        } else {
            detailViewController.postImg = nil
        }
        detailViewController.hidesBottomBarWhenPushed = true
    }
    
    func loadMovies(refreshControl: UIRefreshControl? = nil, hasLoadingHud: Bool) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/top_rated?api_key=\(apiKey)")
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
                                        self.topRatedTableView.reloadData()
                                        self.topRatedMovies = self.movies
                                        
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
    
    private func loadPosterImg(movie: NSDictionary, atCell cell: TopRatedCell) {
        guard let imgPath = movie["poster_path"] as? String else {
            cell.posterImgView.image = UIImage(named: "default-poster")
            return
        }
        let posterURL = imgAPI + imgPath
        cell.posterImgView.setImageWith(URL(string: posterURL)!)
    }
    
    func createSearchBar() {
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Enter movie title here..."
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    
    func searchMovies(withSearchTerm searchTerm: String) {
        let searchText = searchTerm.trimmingCharacters(in: NSCharacterSet.whitespaces)
        
        if searchText == "" {
            movies = topRatedMovies
            topRatedTableView.reloadData()
        } else {
            searchResults = [NSDictionary]()
            for movie in topRatedMovies {
                let title = movie["title"] as! String
                if (title.lowercased().range(of: searchText.lowercased()) != nil) {
                    searchResults.append(movie)
                }
            }
            movies = searchResults
            topRatedTableView.reloadData()
        }
    }

}
