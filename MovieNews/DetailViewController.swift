//
//  DetailViewController.swift
//  MovieNews
//
//  Created by Enta'ard on 10/11/16.
//  Copyright © 2016 Enta'ard. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var movieScrollView: UIScrollView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var voteAvgLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var fullPosterView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var movieTitle: String!
    var releaseDate: String!
    var voteAvg: Float!
    var voteCount: Float!
    var movieDescription: String!
    var postImg: UIImage!
    var bottomPos: CGRect!
    var movieViewX: CGFloat!
    var movieViewShortY: CGFloat!
    var movieViewFullY: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initDetailValues()
        resizeMovieScrollViewHeight()
        initMovieScrollViewPos()
    }

    @IBAction func showDescriptionOnTap(_ sender: AnyObject) {
        let velocity = CGVector(dx: 13, dy: 13)
        
        let springParameters = UISpringTimingParameters(mass: 2.5, stiffness: 100, damping: 55, initialVelocity: velocity)
        
        let animator = UIViewPropertyAnimator(duration: 0.3, timingParameters: springParameters)
        animator.addAnimations {
            self.animateMovieScrollView()
        }
        animator.startAnimation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initDetailValues() {
        movieTitleLabel.text = movieTitle
        releaseDateLabel.text = releaseDate
        voteAvgLabel.text = String.init(format: "%.2f", voteAvg)
        voteCountLabel.text = String.init(format: "%.0f", voteCount)
        descriptionLabel.text = movieDescription
        fullPosterView.image = postImg
    }
    
    func resizeMovieScrollViewHeight() {
        let initTextHeight = descriptionLabel.bounds.height
        descriptionLabel.sizeToFit()
        let trueTextHeight = descriptionLabel.bounds.height
        
        let contentWidth = movieScrollView.bounds.width
        let contentHeight = movieScrollView.bounds.height - initTextHeight + trueTextHeight
        movieScrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
    }
    
    func initMovieScrollViewPos() {
        movieViewX = movieScrollView.frame.origin.x
        movieViewShortY = movieScrollView.frame.origin.y
        movieViewFullY = movieViewShortY - movieScrollView.frame.height + movieTitleLabel.frame.height
    }
    
    func animateMovieScrollView() {
        let height = movieScrollView.frame.height
        let width = movieScrollView.frame.width
        
        let currentY = self.movieScrollView.frame.origin.y
        if currentY == self.movieViewShortY {
            self.movieScrollView.frame = CGRect(x: self.movieViewX, y: self.movieViewFullY, width: width, height: height)
        } else {
            self.movieScrollView.frame = CGRect(x: self.movieViewX, y: self.movieViewShortY, width: width, height: height)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
