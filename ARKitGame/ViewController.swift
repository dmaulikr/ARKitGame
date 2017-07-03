//
//  ViewController.swift
//  ARKitGame
//
//  Created by Tyler Jaacks on 7/1/17.
//  Copyright © 2017 Tyler Jaacks. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    var score:Int = 0 {
        didSet {
            counterLabel.text = "\(score)"
        }
    }
    
    var timeLeft:Int = 60 {
        didSet {
            timerLabel.text = "Time Left: " + "\(timeLeft)"
        }
    }
    
    var gameTime = Timer()
    
    var highScore:Int = 0
    
    var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let key = UserDefaults.standard.object(forKey: "highscore") {
            highScore = loadHighScore()
        } else {
            saveHighScore()
        }
        
        highScore = loadHighScore()
        
        let scene = SCNScene()
        
        sceneView.scene = scene
        
        gameTime = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ViewController.action), userInfo:nil, repeats:true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingSessionConfiguration()
        
        sceneView.session.run(configuration)
        
        addObject()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: sceneView)
            
            let hits = sceneView.hitTest(location, options: nil)
            
            if let hitObject = hits.first {
                let node = hitObject.node
                
                if node.name == "ARShip" {
                    score += 1
                    node.removeFromParentNode()
                    addObject()
                }
            }
        }
    }
    
    @objc func action() {
        if (timeLeft > 0) {
            timeLeft -= 1;
        } else if (score <= highScore) {
            scoreAlert()
            
            self.gameTime.invalidate()
            self.score = 0
            self.timeLeft = 60
            
        } else if (score > highScore) {
            highScoreAlert()
            
            saveHighScore()
            
            self.gameTime.invalidate()
            self.score = 0
            self.timeLeft = 60
        }
    }
    
    func addObject() {
        let ship = Spaceship()
        ship.loadModel()
        
        let xPos = randomPosition(lowerBound: -1.5, upperBound: 1.5)
        let yPos = randomPosition(lowerBound: -1.5, upperBound: 1.5)
        
        ship.position = SCNVector3(xPos, yPos, -1)
        
        sceneView.scene.rootNode.addChildNode(ship)
    }
    
    func scoreAlert() {
        let title:String = "Your ARKit Game Score!"
        let message: String = "Score is " + "\(score)"
        let scoreAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        scoreAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            scoreAlert.dismiss(animated: true, completion: nil)
            
            self.gameTime = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ViewController.action), userInfo:nil, repeats:true)
        }))
        
        self.present(scoreAlert, animated: true, completion: nil)
    }
    
    func highScoreAlert() {
        let title:String = "You Broke the ARKit Game High Score!"
        let message: String = "Score is " + "\(score)"
        let scoreAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        scoreAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            scoreAlert.dismiss(animated: true, completion: nil)
            
            self.gameTime = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ViewController.action), userInfo:nil, repeats:true)
        }))
        
        self.present(scoreAlert, animated: true, completion: nil)
    }
    
    func loadHighScore() -> Int {
        print(defaults.integer(forKey: "highscore"))
        return defaults.integer(forKey: "highscore")
    }
    
    func saveHighScore() {
        highScore = score
        defaults.set(highScore, forKey: "highscore")
    }
    
    func randomPosition (lowerBound lower:Float, upperBound upper:Float) -> Float {
        return Float(arc4random()) / Float(UInt32.max) * (lower - upper) + upper
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
