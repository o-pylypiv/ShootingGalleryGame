//
//  GameScene.swift
//  ShhotingGallery
//
//  Created by Olha Pylypiv on 18.04.2024.
//

import SpriteKit

class GameScene: SKScene {
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var timerLabel: SKLabelNode!
    var time = 60 {
        didSet {
            if time >= 10 {
                timerLabel.text = "00:\(time)"
            } else {
                timerLabel.text = "00:0\(time)"
            }
        }
    }
    var isGameOver = false
    var gameTimer: Timer?
    var restartGame: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 300)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        timerLabel = SKLabelNode(fontNamed: "Chalkduster")
        timerLabel.position = CGPoint(x: 980, y: 720)
        timerLabel.text = "00:60"
        timerLabel.horizontalAlignmentMode = .right
        timerLabel.fontSize = 48
        timerLabel.fontColor = .darkText
        addChild(timerLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 16, y: 40)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontSize = 48
        scoreLabel.fontColor = .darkText
        addChild(scoreLabel)
        
        restartGame = SKSpriteNode(imageNamed: "restart")
        restartGame.position = CGPoint(x: 26, y: 740)
        restartGame.setScale(0.14)
        addChild(restartGame)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(createSprite), userInfo: nil, repeats: true)
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            [weak self] in
            if ((self?.isGameOver) == true) {
                self?.action(forKey: "countdown")?.speed = 0.0
            } else {
                self?.countdown()
            }
        } , SKAction.wait(forDuration: 1)])), withKey: "countdown")
    }
    
    @objc func createSprite() {
        var velocityForSmaller = 1.0
        var sprite = SKSpriteNode()
        if Int.random(in: 0...2) == 0 {
            sprite = SKSpriteNode(imageNamed: "bigBug")
            sprite.name = "bigBug"
            sprite.setScale(0.22)
            velocityForSmaller = 1
        } else if Int.random(in: 0...2) == 1 {
            sprite = SKSpriteNode(imageNamed: "smallBug")
            sprite.name = "smallBug"
            sprite.setScale(0.2)
            velocityForSmaller = 1.6
        } else {
            sprite = SKSpriteNode(imageNamed: "butterfly")
            sprite.name = "butterfly"
            sprite.setScale(0.3)
            velocityForSmaller = 1
        }
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        
        if Int.random(in: 0...2) == 0 {
            sprite.position = CGPoint(x: 0, y: 630)
            sprite.physicsBody?.velocity = CGVector(dx: 300 * velocityForSmaller, dy: 0)
        } else if Int.random(in: 0...2) == 1 {
            sprite.position = CGPoint(x: 1024, y: 384)
            sprite.physicsBody?.velocity = CGVector(dx: -300 * velocityForSmaller, dy: 0)
        } else {
            sprite.position = CGPoint(x: 0, y: 200)
            sprite.physicsBody?.velocity = CGVector(dx: 300 * velocityForSmaller, dy: 0)
        }
        
        sprite.physicsBody?.linearDamping = 0
        addChild(sprite)
    }
    
    func countdown() {
        time -= 1
        if time <= 0 {
            endGame()
        }
    }
    
    func endGame() {
        isGameOver = true
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: 512, y: 384)
        addChild(gameOver)
        
        let finalScore = SKLabelNode(fontNamed: "Chalkduster")
        finalScore.text = "Your final score: \(score)"
        finalScore.position = CGPoint(x: 512, y: 300)
        finalScore.horizontalAlignmentMode = .center
        finalScore.fontSize = 48
        finalScore.fontColor = .darkText
        addChild(finalScore)

        gameTimer?.invalidate()
    }
    
    func newGame() {
        isGameOver = false
        score = 0
        for node in children {
            node.removeFromParent()
        }
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = self.scaleMode
        let animation = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(newScene, transition: animation)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        
        for node in tappedNodes {
            if node.name == "bigBug" {
                score += 3
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                explosion.position = node.position
                addChild(explosion)
                node.removeFromParent()
            } else if node.name == "smallBug" {
                score += 6
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                explosion.position = node.position
                addChild(explosion)
                node.removeFromParent()
            } else if node.name == "butterfly" {
                score -= 5
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
                explosion.position = node.position
                addChild(explosion)
                node.removeFromParent()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if restartGame.contains(location) {
                newGame()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            } else if node.position.x > 1100 {
                node.removeFromParent()
            }
        }
    }
}
