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

class TopRatedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var topRatedTableView: UITableView!
    @IBOutlet weak var networkNoti: UILabel!
    
    let imgAPI  = "http://image.tmdb.org/t/p/w342"
    var topRatedMovies = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topRatedTableView.dataSource = self
        topRatedTableView.delegate = self
        
        loadMovies(hasLoadingHud: true)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadMovies(refreshControl:hasLoadingHud:)), for: UIControlEvents.valueChanged)
        topRatedTableView.insertSubview(refreshControl, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return topRatedMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = topRatedTableView.dequeueReusableCell(withIdentifier: "TopRatedCell") as! TopRatedCell
        
        // img
        loadPosterImg(movie: topRatedMovies[indexPath.section], atCell: cell)
        // title
        cell.titleLabel.text = topRatedMovies[indexPath.section]["title"] as? String
        // voting
        let rating = topRatedMovies[indexPath.section]["vote_average"] as? Float
        cell.ratingLabel.text = String.init(format: "%.2f", rating ?? 0)
        // voting count
        let ratingCount = topRatedMovies[indexPath.section]["vote_count"] as? Float
        cell.ratingCountLabel.text = String.init(format: "%.0f", ratingCount ?? 0)
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let detailViewController = segue.destination as! DetailViewController
        let rowPos = topRatedTableView.indexPathForSelectedRow!.section
        
        // title
        detailViewController.movieTitle = topRatedMovies[rowPos]["title"] as? String
        // release date
        detailViewController.releaseDate = topRatedMovies[rowPos]["release_date"] as? String
        // vote average
        detailViewController.voteAvg = topRatedMovies[rowPos]["vote_average"] as? Float
        // vote count
        detailViewController.voteCount = topRatedMovies[rowPos]["vote_count"] as? Float
        // description
        detailViewController.movieDescription = topRatedMovies[rowPos]["overview"] as? String
        // img
        if let posterPath = topRatedMovies[rowPos]["poster_path"] as? String {
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
                                        self.topRatedMovies = responseDictionary["results"] as! [NSDictionary]
                                        self.topRatedTableView.reloadData()
                                        
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

}
