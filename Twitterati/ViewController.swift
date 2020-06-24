//
//  ViewController.swift
//  Twitterati
//
//  Created by Salah Khaled on 6/16/20.
//  Copyright © 2020 Salah Khaled. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    let sentimentClassifier = TweetSentimentClassifier()
    let tweetsCount = 100
    
    let swifter = Swifter(consumerKey: "LTReJyreyyuz4SWjVABuA1WKI", consumerSecret: "ajf107xfd6869heCG8Ptn8iztfFHBWPIxLkFGvsmoEwI7MKZcz")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        fetchTweets()
    }
    
    func fetchTweets() {
        if let searchText = textField.text {
            var editedText = searchText
            if searchText.contains("@") {
                editedText = searchText
            } else {
                editedText = "@\(searchText)"
            }
            swifter.searchTweet(using: editedText, lang: "en", count: tweetsCount, tweetMode: .extended, success: { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                
                for i in 0 ..< self.tweetsCount {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                
                self.makePrediction(with: tweets, name: editedText)
                
            }) { (error) in
                print("Error with the api request: \(error)")
            }
        }
    }
    func makePrediction(with tweets: [TweetSentimentClassifierInput], name: String) {
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            var score = 0
            for prediction in predictions {
                if prediction.label == "Neg" {
                    score -= 1
                } else if prediction.label == "Pos" {
                    score += 1
                }
            }
            
            self.updateUI(with: score, name: name)
            
        } catch {
            print("Error making prediction")
        }
        
        
    }
    func updateUI(with score: Int, name: String) {
        self.textField.text = ""
        
        if score > 20 {
            self.sentimentLabel.text = "😍"
            self.feedbackLabel.text = "\(name) got a very positive feedback"
            self.backgroundView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            
        } else if score > 10 {
            self.sentimentLabel.text = "😄"
            self.feedbackLabel.text = "\(name) got a positive feedback"
            self.backgroundView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            
        } else if score > 0 {
            self.sentimentLabel.text = "😀"
            self.feedbackLabel.text = "\(name) got a nice feedback"
            self.backgroundView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            
        } else if score == 0 {
            self.sentimentLabel.text = "😐"
            self.feedbackLabel.text = "\(name) got a neutral feedback"
            self.backgroundView.backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.631372549, blue: 0.9490196078, alpha: 1)
            
        } else if score > -10 {
            self.sentimentLabel.text = "☹️"
            self.feedbackLabel.text = "\(name) got a bad feedback"
            self.backgroundView.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            
        } else if score > -20 {
            self.sentimentLabel.text = "😡"
            self.feedbackLabel.text = "\(name) got a very bad feedback"
            self.backgroundView.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            
        } else  {
            self.sentimentLabel.text = "🤮"
            self.feedbackLabel.text = "\(name) got an awful feedback"
            self.backgroundView.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            
        }
    }
    
}

