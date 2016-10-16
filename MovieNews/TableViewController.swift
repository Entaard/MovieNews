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

    let lowResImgAPI  = "https://image.tmdb.org/t/p/w45"
    let highResImgAPI = "https://image.tmdb.org/t/p/original"
    
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
    
    // Color bug: everything turns white if I set color like this
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let deselectedCell = tableView.cellForRow(at: indexPath)
//        deselectedCell?.backgroundColor = UIColor(red: 255, green: 86, blue: 185, alpha: 1)
//    }
    
    // Color bug: everything turns white if I set color like this
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedCell = tableView.cellForRow(at: indexPath)
//        selectedCell?.backgroundColor = UIColor(red: 255, green: 120, blue: 255, alpha: 1)
//    }
    
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
        let currentCell = movieTable.cellForRow(at: indexPath!) as! MovieCell
        detailVC.postImg = currentCell.posterView.image
        
        detailVC.hidesBottomBarWhenPushed = true
    }
    
    func loadPosterImg(movie: NSDictionary, atCell cell: MovieCell) {
        guard let imgPath = movie["poster_path"] as? String else {
            cell.posterView.image = UIImage(named: "default-poster")
            return
        }
        let lowResURL = lowResImgAPI + imgPath
        let highResURL = highResImgAPI + imgPath
        let lowResRequest = URLRequest(url: URL(string: lowResURL)!)
        let highResRequest = URLRequest(url: URL(string: highResURL)!)
        
        // fade in loading img
        cell.posterView.setImageWith(
            lowResRequest,
            placeholderImage: nil,
            success: { (imgRequest, imgResponse, img) in
                if imgResponse != nil {
                    // img is not cached, fade in new img
                    cell.posterView.alpha = 0
                    cell.posterView.image = img
                    let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: {
                        cell.posterView.alpha = 1
                    })
                    animator.startAnimation()
                    // add completion to animator, in order to load highResImg
                    animator.addCompletion({ (sucess) in
                        cell.posterView.setImageWith(
                            highResRequest,
                            placeholderImage: nil,
                            success: { (imgRequest, responseRequest, img) in
                                cell.posterView.image = img
                            }, failure: { (imgRequest, imgResponse, error) in
                                return
                        })
                    })
                } else {
                    // Image was cached
                    cell.posterView.setImageWith(URL(string: highResURL)!)
                }
            },
            failure: { (imgRequest, imgResponse, error) in
                cell.posterView.image = UIImage(named: "default-poster")
        })
    }

}
