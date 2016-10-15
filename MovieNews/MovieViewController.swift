//
//  MovieViewController.swift
//  MovieNews
//
//  Created by Enta'ard on 10/11/16.
//  Copyright © 2016 Enta'ard. All rights reserved.
//

import UIKit
import ARSLineProgress

class MovieViewController: UIViewController {

    @IBOutlet weak var layoutControl: UISegmentedControl!
    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var gridContainer: UIView!
    @IBOutlet weak var networkNoti: UILabel!
    
//    var movies = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                                        
                                        let tableViewController = self.childViewControllers[0] as! TableViewController
                                        tableViewController.movies = responseDictionary["results"] as! [NSDictionary]
                                        tableViewController.movieTable.reloadData()
                                        
                                        let gridViewController = self.childViewControllers[1] as! GridViewController
                                        gridViewController.movies = responseDictionary["results"] as! [NSDictionary]
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

}
