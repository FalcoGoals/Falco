//
//  MainViewController.swift
//  Falco
//
//  Created by Gerald on 30/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit
import SpriteKit

protocol GoalModelDelegate {
    func didUpdateGoal(goal: Goal)
    func didCompleteGoal(goal: Goal)
    func getGoalWithIdentifier(goalId: String) -> Goal?
}

class BubblesViewController: UIViewController, GoalEditDelegate, UIPopoverPresentationControllerDelegate {
    private var scene: BubblesScene!
    private var texture = [SKTexture]()

    var delegate: GoalModelDelegate!
    var initialGoals: GoalCollection?

    // MARK: Init

    override func viewDidLoad() {
        super.viewDidLoad()

        scene = BubblesScene(size: view.bounds.size)
        scene.scaleMode = .ResizeFill

        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
        skView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BubblesViewController.bubbleTapped(_:))))
        skView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action:
            #selector(BubblesViewController.bubbleLongPressed(_:))))
        
        let bubbleAnimatedAtlas = SKTextureAtlas(named: "bubble")
        
        for i in 0...(bubbleAnimatedAtlas.textureNames.count - 1) {
            let bubbleTextureName = "bubble\(i).png"
            texture.append(SKTexture(imageNamed: bubbleTextureName))
        }
    }

    override func viewDidAppear(animated: Bool) {
        self.becomeFirstResponder()

        if let goals = initialGoals {
            addGoalsToScene(goals)
            initialGoals = nil
        }
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEditView" {
            let nc = segue.destinationViewController as! UINavigationController
            let evc = nc.topViewController as! GoalEditViewController

            let location = sender!.locationInView(sender!.view)
            let touchLocation = scene.convertPointFromView(location)
            var node = scene.nodeAtPoint(touchLocation)
            while !(node is GoalBubble) && node.parent != nil {
                if let parent = node.parent {
                    node = parent
                } else {
                    break
                }
            }

            nc.popoverPresentationController!.sourceView = sender!.view
            nc.popoverPresentationController!.delegate = self
            if let node = node as? GoalBubble {
                evc.goal = delegate.getGoalWithIdentifier(node.id)
                nc.popoverPresentationController!.sourceRect = CGRect(origin: location, size: node.frame.size)
            } else {
                evc.goal = nil
                nc.popoverPresentationController!.sourceRect.offsetInPlace(dx: location.x, dy: location.y)
            }
            evc.delegate = self
            pauseScene()
        }
    }

    // MARK: Public methods

    func addGoalsToScene(goals: GoalCollection) {
        goals.sortGoalsByWeight()
        scene.addGoals(goals)
    }

    // MARK: Gesture recognisers

    func bubbleTapped(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier("showEditView", sender: sender)
    }
    
    func bubbleLongPressed(sender: UILongPressGestureRecognizer) {
        let longPressRecognizerView = sender.view
        let longPressPoint = sender.locationInView(longPressRecognizerView)
        let scenePoint = scene.convertPointFromView(longPressPoint)
        var node = scene.nodeAtPoint(scenePoint)
        while !(node is GoalBubble) && node.parent != nil {
            if let parent = node.parent {
                node = parent
            } else {
                break
            }
        }

        if let node = node as? GoalBubble {
            completeGoal(node)
        }
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        let children = scene.children
        for node in children {
            if (node.name != "background" && node.name != "camera") {
                node.removeFromParent()
            }
        }
//        addGoalsToScene(goals)
    }

    // MARK: GoalEditDelegate

    func didSave(goal: Goal) {
        scene.updateGoal(goal)
        delegate.didUpdateGoal(goal)
        playScene()
    }

    // MARK: UIPopoverPresentationControllerDelegate

    func popoverPresentationControllerDidDismissPopover(_: UIPopoverPresentationController) {
        playScene()
    }

    // MARK: IB Actions

    @IBAction func cancelGoalEdit(segue: UIStoryboardSegue) { playScene() }

    // MARK: Helper methods
    
    private func completeGoal(goalBubble: GoalBubble) {
        let goalId = goalBubble.id
        if let goal = delegate.getGoalWithIdentifier(goalId) {
            delegate.didCompleteGoal(goal)
        }

        let circle = goalBubble.circle
        let bubbleSpriteNode = SKSpriteNode(imageNamed: "default-bubble.png")
        bubbleSpriteNode.size = circle.frame.size
        circle.removeAllChildren()
        circle.addChild(bubbleSpriteNode)
        circle.fillTexture = nil
        circle.fillColor = UIColor.clearColor()
        bubbleSpriteNode.runAction(SKAction.sequence([
            SKAction.animateWithTextures(texture, timePerFrame: 0.2, resize: false, restore: true),
            SKAction.removeFromParent()]))
        circle.runAction(SKAction.sequence([
            SKAction.waitForDuration(1.0),
            SKAction.removeFromParent()]))
    }

    private func pauseScene() {
        self.scene.view?.paused = true
    }

    private func playScene() {
        self.scene.view?.paused = false
    }
}

extension BubblesViewController {
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
