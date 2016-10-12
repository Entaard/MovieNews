//
//  MovieViewController.swift
//  MovieNews
//
//  Created by Enta'ard on 10/11/16.
//  Copyright © 2016 Enta'ard. All rights reserved.
//

import UIKit
import AFNetworking
import ARSLineProgress

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var movieTable: UITableView!
    @IBOutlet weak var networkNoti: UILabel!
    
    let baseURL  = "http://image.tmdb.org/t/p/w342"
    var movies = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        movieTable.dataSource = self
        movieTable.delegate = self
        
        loadMovies(hasLoadingHud: true)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadMovies(refreshControl:hasLoadingHud:)), for: UIControlEvents.valueChanged)
        movieTable.insertSubview(refreshControl, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = movieTable.dequeueReusableCell(withIdentifier: "movieCell") as! MovieCell
        
        // title
        cell.titleLabel?.text = movies[indexPath.row]["title"] as? String
        // overview (description)
        cell.descriptionLabel?.text = movies[indexPath.row]["overview"] as? String
        // img
        guard let posterPath = movies[indexPath.row]["poster_path"] as? String else {
            cell.posterView.image = UIImage(named: "default-poster")
            return cell
        }
        let posterURL = baseURL + posterPath
        cell.posterView.setImageWith(URL(string: posterURL)!)
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as! DetailViewController
        let indexPath = movieTable.indexPathForSelectedRow
        let rowPos: Int = (indexPath?.row)!
        
        // title
        detailVC.movieTitle = movies[rowPos]["title"] as? String
        // release date
        detailVC.releaseDate = movies[rowPos]["release_date"] as? String
        // vote average
        detailVC.voteAvg = movies[rowPos]["vote_average"] as? Float
        // vote count
        detailVC.voteCount = movies[rowPos]["vote_count"] as? Float
        // description
        detailVC.movieDescription = movies[rowPos]["overview"] as? String
        // img
        guard let posterPath = movies[rowPos]["poster_path"] as? String else {
            detailVC.postImg = nil
            return
        }
        let posterURL = baseURL + posterPath
        let imgView = UIImageView()
        imgView.setImageWith(URL(string: posterURL)!)
        detailVC.postImg = imgView.image
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
                                        self.movieTable.reloadData()
                                        
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

}
