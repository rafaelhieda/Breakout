//
//  GameOverScene.swift
//  Breakout
//
//  Created by Rafael  Hieda on 05/05/15.
//  Copyright (c) 2015 Rafael Hieda. All rights reserved.
//

import Foundation
import SpriteKit

let GameOverLabelCategoryName = "gameOverLabel"

class GameOverScene: SKScene {
    var gameWon:Bool = false {
        didSet {
            let gameOverLabel = childNodeWithName(GameOverLabelCategoryName) as! SKLabelNode
            gameOverLabel.text = gameWon ? "You WIN!" : "Game Over :["
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        The didSet observer attached to the gameWon property is a Swift particularity called Property Observer. With that you can observe changes in the value of a property and react accordingly. There are two property observers: willSet is called just before a property value change occurs, whereas didSet occurs just after.
//        
        if let view = view {
            let gameScene = GameScene.unarchiveFromFile("GameScene") as! GameScene
            // When the user taps anywhere in the GameOver scene, this code just presents the Game scene again. Note how it instantiates a new GameScene object by unarchiving the Sprite Kit Scene you built with the Visual Editor, referencing it by its name without the .sks extension.
            view.presentScene(gameScene)
        }
    }
}