//
//  TableViewController.swift
//  MovieNews
//
//  Created by Enta'ard on 10/14/16.
//  Copyright © 2016 Enta'ard. All rights reserved.
//

import UIKit
import AFNetworking

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let imgAPI  = "http://image.tmdb.org/t/p/w342"
    
    @IBOutlet weak var movieTable: UITableView!
    
    var movies = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        movieTable.dataSource = self
        movieTable.delegate = self
        
        let refreshControl = UIRefreshControl()
        // Magic appears in this func ??? T.T
        // Why target is MovieViewController, not this "self"?
        refreshControl.addTarget(nil, action: #selector(MovieViewController.loadMovies(refreshControl:hasLoadingHud:)), for: UIControlEvents.valueChanged)
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
        loadPosterImg(movie: movies[indexPath.row], atCell: cell)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let movieViewController = self.parent as! MovieViewController
        movieViewController.searchBar.endEditing(true)
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
        if let posterPath = movies[rowPos]["poster_path"] as? String {
            let posterURL = imgAPI + posterPath
            let imgView = UIImageView()
            imgView.setImageWith(URL(string: posterURL)!)
            detailVC.postImg = imgView.image
        } else {
            detailVC.postImg = nil
            return
        }
        
        detailVC.hidesBottomBarWhenPushed = true
    }
    
    func loadPosterImg(movie: NSDictionary, atCell cell: MovieCell) {
        guard let imgPath = movie["poster_path"] as? String else {
            cell.posterView.image = UIImage(named: "default-poster")
            return
        }
        let posterURL = imgAPI + imgPath
        cell.posterView.setImageWith(URL(string: posterURL)!)
    }

}
