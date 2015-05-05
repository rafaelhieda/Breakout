//
//  GameScene.swift
//  Breakout
//
//  Created by Rafael  Hieda on 05/05/15.
//  Copyright (c) 2015 Rafael Hieda. All rights reserved.
//



import SpriteKit

let BallCategoryName = "ball"
let PaddleCategoryName = "paddle"
let BlockCategoryName = "block"
let BlockNodeCategoryName = "blockNode"

let BallCategory   : UInt32 = 0x1 << 0 // 00000000000000000000000000000001
let BottomCategory : UInt32 = 0x1 << 1 // 00000000000000000000000000000010
let BlockCategory  : UInt32 = 0x1 << 2 // 00000000000000000000000000000100
let PaddleCategory : UInt32 = 0x1 << 3 // 00000000000000000000000000001000

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var isFingerOnPaddle = false
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        self.createBall()
        self.createWall()
        
        let bottomRect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFromRect: bottomRect)
        addChild(bottom)

        
        let paddle = childNodeWithName(PaddleCategoryName) as! SKSpriteNode
        bottom.physicsBody?.categoryBitMask = BottomCategory
        paddle.physicsBody?.categoryBitMask = PaddleCategory
        
        //importante
        physicsWorld.contactDelegate = self
        loadBlocks()
        
        
    }
    
    func loadBlocks() {
        // 1. Store some useful constants
        let numberOfBlocks = 5
        
        let blockWidth = SKSpriteNode(imageNamed: "block.png").size.width
        let totalBlocksWidth = blockWidth * CGFloat(numberOfBlocks)
        
        let padding: CGFloat = 10.0
        let totalPadding = padding * CGFloat(numberOfBlocks - 1)
        
        // 2. Calculate the xOffset
        let xOffset = (CGRectGetWidth(frame) - totalBlocksWidth - totalPadding) / 2
        
        // 3. Create the blocks and add them to the scene
        for i in 0..<numberOfBlocks {
            let block = SKSpriteNode(imageNamed: "block.png")
            block.position = CGPointMake(xOffset + CGFloat(CGFloat(i) + 0.5)*blockWidth + CGFloat(i-1)*padding, CGRectGetHeight(frame) * 0.8)
            block.physicsBody = SKPhysicsBody(rectangleOfSize: block.frame.size)
            block.physicsBody!.allowsRotation = false
            block.physicsBody!.friction = 0.0
            block.physicsBody!.affectedByGravity = false
            block.name = BlockCategoryName
            block.physicsBody!.categoryBitMask = BlockCategory
            block.physicsBody?.dynamic = false
            addChild(block)
            
        }
    }
    
    func createWall(){
        //setando uma physicsbody com as bordas da scene e atribuindo a physicsbody da scene
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
    }
    
    func createBall() {
        //removo a gravidade da scene, aplico uma impulsão a ela, sem isso ela fica imóvel!
        physicsWorld.gravity = CGVectorMake(0, 0)
        let ball = childNodeWithName(BallCategoryName) as! SKSpriteNode
        ball.physicsBody!.applyImpulse(CGVectorMake(10, -10))
        ball.physicsBody?.categoryBitMask = BallCategory
        ball.physicsBody?.contactTestBitMask = BottomCategory | BlockCategory
        //todas as properties da ball foram feitas no .sks
    }
    
    func isGameWon() -> Bool {
        var numberOfBricks = 0
        self.enumerateChildNodesWithName(BlockCategoryName) {
            node, stop in
            numberOfBricks = numberOfBricks + 1
        }
        return numberOfBricks == 0
    }
    
    // #pragma contact delegate methods
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory
        {
            println("contato realizado!")
            if let mainView = view {
                let gameOverScene = GameOverScene.unarchiveFromFile("GameOverScene") as! GameOverScene
                gameOverScene.gameWon = false
                mainView.presentScene(gameOverScene)
                
            }
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory {
            secondBody.node?.removeFromParent()
            if isGameWon() {
                if let mainView = view {
                    let gameOverScene = GameOverScene.unarchiveFromFile("GameOverScene") as! GameOverScene
                    gameOverScene.gameWon = true
                    mainView.presentScene(gameOverScene)
                }
            }
        }
    }
    
    // #pragma touches delegate methods
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        //pega o primeiro toque e sua localização
        var touch = touches.first as! UITouch
        var touchLocation = touch.locationInNode(self)
        //passa o corpo no physicsWorld se o tal corpo for PaddleCategoryName
        if let body = physicsWorld.bodyAtPoint(touchLocation) {
            if body.node?.name == PaddleCategoryName {
                print("começaram os toques na paddle")
                isFingerOnPaddle = true
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if isFingerOnPaddle {
            var touch = touches.first as! UITouch
            var touchLocation = touch.locationInNode(self)
            var previousLocation = touch.previousLocationInNode(self)
            var paddle = childNodeWithName(PaddleCategoryName) as! SKSpriteNode
            
            paddle.physicsBody?.categoryBitMask = PaddleCategory

            var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
            
            //limitação de espaço do paddle na scene
            paddleX = max(paddleX, paddle.size.width/2)
            paddleX = min(paddleX, size.width - paddle.size.width/2)
            //atualiza posicão da paddle
            paddle.position = CGPointMake(paddleX, paddle.position.y)
        }
        
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        isFingerOnPaddle = false
    }
    
    
    override func update(currentTime: NSTimeInterval) {
        let ball = self.childNodeWithName(BallCategoryName) as! SKSpriteNode
        
        let maxSpeed: CGFloat = 1000.0
        let speed = sqrt(ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx + ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy)
        
        if speed > maxSpeed {
            ball.physicsBody!.linearDamping = 0.4
        }
        else {
            ball.physicsBody!.linearDamping = 0.0
        }
    }
    
    
    
}
