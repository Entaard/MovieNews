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

    let lowResImgAPI  = "https://image.tmdb.org/t/p/w45"
    let highResImgAPI = "https://image.tmdb.org/t/p/original"
    
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
        let currentCell = movieGrid.cellForItem(at: indexPath!) as! MovieGridCell
        detailVC.postImg = currentCell.posterView.image
        
        detailVC.hidesBottomBarWhenPushed = true
    }
    
    func loadPosterImg(movie: NSDictionary, atCell cell: MovieGridCell) {
        guard let imgPath = movie["poster_path"] as? String else {
            cell.posterView.image = UIImage(named: "default-poster")
            return
        }
        let lowResURL = lowResImgAPI + imgPath
        let highResURL = highResImgAPI + imgPath
        let lowResRequest = URLRequest(url: URL(string: lowResURL)!)
        let highResRequest = URLRequest(url: URL(string: highResURL)!)
        
        cell.posterView.setImageWith(
            lowResRequest,
            placeholderImage: nil,
            success: { (imgRequest, imgResponse, img) in
                if imgResponse != nil {
                    cell.posterView.alpha = 0
                    cell.posterView.image = img
                    let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: {
                        cell.posterView.alpha = 1
                    })
                    animator.startAnimation()
                    
                    animator.addCompletion({ (success) in
                        cell.posterView.setImageWith(
                            highResRequest,
                            placeholderImage: nil,
                            success: { (imgRequest, imgResponse, img) in
                                cell.posterView.image = img
                            },
                            failure: { (imgRequest, imgResponse, error) in
                                return
                        })
                    })
                } else {
                    cell.posterView.setImageWith(URL(string: highResURL)!)
                }
            },
            failure: { (imgRequest, imgResponse, error) in
                cell.posterView.image = UIImage(named: "default-poster")
        })
    }
    
}
