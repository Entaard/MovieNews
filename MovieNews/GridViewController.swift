//
//  GridViewController.swift
//  MovieNews
//
//  Created by Enta'ard on 10/15/16.
//  Copyright © 2016 Enta'ard. All rights reserved.
//

import UIKit
import AFNetworking

class GridViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    let imgAPI  = "http://image.tmdb.org/t/p/w342"
    
    @IBOutlet weak var movieGrid: UICollectionView!
    
    var movies = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        movieGrid.dataSource = self
        movieGrid.delegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(nil, action: #selector(MovieViewController.loadMovies(refreshControl:hasLoadingHud:)), for: UIControlEvents.valueChanged)
        movieGrid.insertSubview(refreshControl, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = movieGrid.dequeueReusableCell(withReuseIdentifier: "movieGridCell", for: indexPath) as! MovieGridCell
        loadPosterImg(movie: movies[indexPath.row], atCell: cell)
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let movieViewController = self.parent as! MovieViewController
        movieViewController.searchBar.endEditing(true)
        
        let detailVC = segue.destination as! DetailViewController
        let indexPath = movieGrid.indexPathsForSelectedItems?[0]
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
    
    func loadPosterImg(movie: NSDictionary, atCell cell: MovieGridCell) {
        guard let imgPath = movie["poster_path"] as? String else {
            cell.posterView.image = UIImage(named: "default-poster")
            return
        }
        let posterURL = imgAPI + imgPath
        cell.posterView.setImageWith(URL(string: posterURL)!)
    }

}
