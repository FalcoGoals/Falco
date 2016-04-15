//
//  MainViewController.swift
//  Falco
//
//  Created by Gerald on 30/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit
import SpriteKit

class BubblesViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    private var scene: BubblesScene!
    private var bubblePopTextures = [SKTexture]()
    private var isGroup: Bool {
        return currentGroup != nil
    }

    var delegate: ModelDelegate!
    var initialGoals: GoalCollection?
    var currentGroup: Group?

    // MARK: Init

    override func viewDidLoad() {
        super.viewDidLoad()

        let bubblePopAnimatedAtlas = SKTextureAtlas(named: "bubble-pop")
        for textureName in bubblePopAnimatedAtlas.textureNames.sort() {
            bubblePopTextures.append(SKTexture(imageNamed: textureName))
        }
    }

    override func viewWillAppear(animated: Bool) {
        guard scene == nil else {
            return
        }

        scene = BubblesScene(size: view.bounds.size)

        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        skView.allowsTransparency = true
        skView.presentScene(scene)
        skView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BubblesViewController.bubbleTapped(_:))))
        skView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action:
            #selector(BubblesViewController.bubbleLongPressed(_:))))
        if (isGroup) {
            scene.addChat()
        }

        if let goals = initialGoals {
            addGoalsToScene(goals)
            initialGoals = nil
        }
    }

    override func viewDidAppear(animated: Bool) {
        self.becomeFirstResponder()

        playScene()
    }

    override func viewDidDisappear(animated: Bool) {
        pauseScene()
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.goalEditSegue {
            let nc = segue.destinationViewController as! UINavigationController
            let goalEditHolderController = nc.topViewController as! GoalEditHolderController
            if isGroup {
                goalEditHolderController.group = currentGroup
            }

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
                goalEditHolderController.goal = delegate.getGoal(node.id, groupId: currentGroup?.id)
                nc.popoverPresentationController!.sourceRect = CGRect(origin: location, size: node.frame.size)
            } else {
                goalEditHolderController.goal = nil
                nc.popoverPresentationController!.sourceRect.offsetInPlace(dx: location.x, dy: location.y)
            }
            goalEditHolderController.saveDelegate = self
            pauseScene()
        } else if segue.identifier == Constants.groupChatSegue {
            let nc = segue.destinationViewController as! UINavigationController
            let cvc = nc.topViewController as! GroupChatViewController
            
            let location = sender!.locationInView(sender!.view)
            let touchLocation = scene.convertPointFromView(location)
            let node = scene.nodeAtPoint(touchLocation)
            
            nc.popoverPresentationController!.sourceView = sender!.view
            nc.popoverPresentationController!.delegate = self
            nc.popoverPresentationController!.sourceRect = CGRect(origin: location, size: node.frame.size)
            
            cvc.initialize(currentGroup!, localUser: Server.instance.user)
            cvc.preferredContentSize = CGSizeMake(view.frame.width, view.frame.height/2)
        }
    }

    // MARK: Public methods

    func addGoalsToScene(goals: GoalCollection) {
        goals.sortGoalsByWeight()
        scene.addGoals(goals)
    }

    // MARK: Gesture recognisers

    func bubbleTapped(sender: UITapGestureRecognizer) {
        let location = sender.locationInView(sender.view)
        let touchLocation = scene.convertPointFromView(location)
        let node = scene.nodeAtPoint(touchLocation)
        if (node.name == "chat") {
            performSegueWithIdentifier(Constants.groupChatSegue, sender: sender)
        } else {
            performSegueWithIdentifier(Constants.goalEditSegue, sender: sender)
        }
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
        addGoalsToScene(delegate.getGoals())
    }

    // MARK: UIPopoverPresentationControllerDelegate

    func popoverPresentationControllerDidDismissPopover(_: UIPopoverPresentationController) {
        playScene()
    }

    // MARK: IB Actions

    @IBAction func cancelGoalEdit(segue: UIStoryboardSegue) { playScene() }

    // MARK: Helper methods
    
    private func completeGoal(goalBubble: GoalBubble) {
        delegate.didCompleteGoal(goalBubble.id, groupId: currentGroup?.id)

        let circle = goalBubble.circle
        let label = goalBubble.label
        let bubbleSpriteNode = SKSpriteNode(imageNamed: "bubble")
        bubbleSpriteNode.size = circle.frame.size
        bubbleSpriteNode.setScale(1/circle.xScale)
        circle.removeAllChildren()
        circle.addChild(bubbleSpriteNode)
        circle.fillTexture = nil
        circle.fillColor = UIColor.clearColor()
        bubbleSpriteNode.runAction(SKAction.sequence([
            SKAction.animateWithTextures(bubblePopTextures, timePerFrame: 0.1, resize: false, restore: true),
            SKAction.removeFromParent()]))
        circle.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(0.5),
            SKAction.removeFromParent()]))
        label.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(0.5),
            SKAction.removeFromParent()]))
    }

    private func pauseScene() {
        self.scene.view?.paused = true
    }

    private func playScene() {
        self.scene.view?.paused = false
    }
}

extension BubblesViewController: Savable {
    func didSave(goal: Goal) {
        scene.updateGoal(goal)
        delegate.didUpdateGoal(goal)
        playScene()
    }
}