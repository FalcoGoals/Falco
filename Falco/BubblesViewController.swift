//
//  MainViewController.swift
//  Falco
//
//  Created by Gerald on 30/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit
import SpriteKit

class BubblesViewController: UIViewController {
    private var scene: BubblesScene!
    private var bubblePopTextures = [SKTexture]()
    private var isGroupBubblesView: Bool {
        return groupId != nil
    }
    private var pinchedBubble: GoalBubble?

    @IBOutlet weak var sceneView: SKView!
    @IBOutlet weak var personalOrAllSelector: UISegmentedControl!

    var delegate: ModelDelegate!
    var initialGoals: GoalCollection?
    var groupId: String?

    // MARK: Init

    override func viewDidLoad() {
        super.viewDidLoad()

        let bubblePopAnimatedAtlas = SKTextureAtlas(named: "bubble-pop")
        for textureName in bubblePopAnimatedAtlas.textureNames.sort() {
            bubblePopTextures.append(SKTexture(imageNamed: textureName))
        }

        if isGroupBubblesView {
            personalOrAllSelector.setTitle("All Goals", forSegmentAtIndex: 0)
            personalOrAllSelector.setTitle("Goals I'm Assigned", forSegmentAtIndex: 1)
        }
    }

    override func viewWillAppear(animated: Bool) {
        guard scene == nil else {
            return
        }

        scene = BubblesScene(size: sceneView.frame.size)

        let skView = sceneView
        skView.ignoresSiblingOrder = true
        skView.allowsTransparency = true
        skView.presentScene(scene)
        
        skView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BubblesViewController.bubbleTapped(_:))))
        skView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action:
            #selector(BubblesViewController.bubbleLongPressed(_:))))
        skView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(BubblesViewController.bubblePinched(_:))))
        
        if isGroupBubblesView {
            scene.addChatBubble()
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

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition(nil) { context in
            for child in self.scene.children where child is GoalBubble {
                let bubble = child as! GoalBubble
                if !self.scene.intersectsNode(bubble.circle) {
                    print("readding \(bubble.name)")
                    bubble.removeFromParent()
                    if let goal = self.delegate.getGoal(bubble.id, groupId: bubble.groupId) {
                        self.scene.addGoal(goal)
                    }
                }
            }
        }
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.goalEditSegue {
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
                evc.goal = delegate.getGoal(node.id, groupId: node.groupId)
                if let groupId = node.groupId {
                    evc.group = delegate.getGroup(groupId)
                }
                nc.popoverPresentationController!.sourceRect = CGRect(origin: location, size: node.frame.size)
            } else {
                evc.goal = nil
                if let groupId = groupId {
                    evc.group = delegate.getGroup(groupId)
                }
                nc.popoverPresentationController!.sourceRect.offsetInPlace(dx: location.x, dy: location.y)
            }
            evc.delegate = self

        } else if segue.identifier == Constants.groupChatSegue {
            let nc = segue.destinationViewController as! UINavigationController
            let cvc = nc.topViewController as! GroupChatViewController
            
            let location = sender!.locationInView(sender!.view)
            let touchLocation = scene.convertPointFromView(location)
            let node = scene.nodeAtPoint(touchLocation)
            
            nc.popoverPresentationController!.sourceView = sender!.view
            nc.popoverPresentationController!.delegate = self
            nc.popoverPresentationController!.sourceRect = CGRect(origin: location, size: node.frame.size)

            let group = delegate.getGroup(groupId!)!
            cvc.initialize(group, localUser: Storage.instance.user)
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
        if node.name == "chat" {
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

    func bubblePinched(sender: UIPinchGestureRecognizer) {
        if sender.state == .Began {
            let pinchRecognizerView = sender.view
            let pinchPoint = sender.locationInView(pinchRecognizerView)
            let scenePoint = scene.convertPointFromView(pinchPoint)
            var node = scene.nodeAtPoint(scenePoint)
            while !(node is GoalBubble) && node.parent != nil {
                if let parent = node.parent {
                    node = parent
                } else {
                    break
                }
            }
            if let bubble = node as? GoalBubble {
                pinchedBubble = bubble
                bubble.beginScaling(sender.scale)
            }
        } else {
            if let bubble = pinchedBubble {
                if sender.state == .Changed {
                    bubble.scaleTo(sender.scale)
                } else {
                    bubble.finishScaling(sender.scale)
                    if var goal = delegate.getGoal(bubble.id, groupId: bubble.groupId) {
                        goal.priority = priorityForTargetRadius(bubble.radius)
                        delegate.didUpdateGoal(goal)
                    }
                    pinchedBubble = nil
                }
            }
        }
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        reloadWithAppropriateGoals()
    }

    // MARK: IB Actions

    @IBAction func selectionChanged(sender: UISegmentedControl) {
        reloadWithAppropriateGoals()
    }
    
    @IBAction func cancelGoalEdit(segue: UIStoryboardSegue) { playScene() }

    // MARK: Helper methods

    private func reloadWithAppropriateGoals() {
        let children = scene.children
        for node in children {
            if node.name != "background" && node.name != "camera" {
                node.removeFromParent()
            }
        }

        let selectionIndex = personalOrAllSelector.selectedSegmentIndex
        let reloadedGoals: GoalCollection?
        if let groupId = groupId {
            if selectionIndex == 0 {
                reloadedGoals = delegate.getGoals(groupId)
            } else {
                reloadedGoals = delegate.getGoals(groupId)?.assignedGroupGoals
            }
        } else {
            if selectionIndex == 0 {
                reloadedGoals = delegate.getAllGoals()?.relevantGoals
            } else {
                reloadedGoals = delegate.getGoals(nil)
            }
        }
        if let reloadedGoals = reloadedGoals {
            addGoalsToScene(reloadedGoals.incompleteGoals)
        }
    }

    private func completeGoal(goalBubble: GoalBubble) {
        let updatedGoal = delegate.didCompleteGoal(goalBubble.id, groupId: goalBubble.groupId)!
        scene.updateGoal(updatedGoal) // update ring if necessary

        if updatedGoal.isCompleted { // if fully complete group goal or personal goal - remove bubble
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
    }

    private func pauseScene() {
        self.scene.view?.paused = true
    }

    private func playScene() {
        self.scene.view?.paused = false
    }

    private func priorityForTargetRadius(radius: CGFloat) -> Double {
        return (Double(radius * 2) - 80) / 50 - 1
    }
}

private typealias PopoverDelegate = BubblesViewController
extension PopoverDelegate: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerDidDismissPopover(_: UIPopoverPresentationController) {
        playScene()
    }

    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
        pauseScene()
    }
}

extension BubblesViewController: Savable {
    func didSaveGoal(goal: Goal) {
        scene.updateGoal(goal)
        delegate.didUpdateGoal(goal)
        playScene()
    }
    func didSaveGroup(group: Group) {
        // nil
    }
}