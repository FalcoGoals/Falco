//
//  GoalsLayout.swift
//  Falco
//
//  Created by Gerald on 17/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

protocol GoalLayoutDelegate {
    func collectionView(collectionView:UICollectionView, diameterForGoalAtIndexPath indexPath:NSIndexPath) -> CGFloat
    
    func getName(indexPath: NSIndexPath) -> String
}

class GoalsLayout: UICollectionViewLayout {
    var delegate: GoalLayoutDelegate!
    var circlePosition = [[Int]]()
    var dynamicAnimator: UIDynamicAnimator!
    var animatorSet = false
    
    private var oldCellInformation = [String: UICollectionViewLayoutAttributes]()
    private var cellInformation = [String: UICollectionViewLayoutAttributes]()
    private var oldCellArray = [String: CGPoint]()
    private var newCellArray = [String: CGPoint]()
    
    /// content refers to entire collection of cells
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat = 0
    //    private var contentWidth: CGFloat {
    //        let insets = collectionView!.contentInset
    //        return CGRectGetWidth(collectionView!.bounds) - insets.left - insets.right
    //    }
    
    override init() {
        super.init()
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        
        self.dynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
    }
    
    // perform prior calculation for layout. like a setup phase
    override func prepareLayout() {
        print("preparing layout")
        
        contentWidth = collectionView!.bounds.size.width
        contentHeight = 0
        circlePosition.removeAll()
        let numSections = collectionView!.numberOfSections()
        var localCellInformation = [String: UICollectionViewLayoutAttributes]()
        var localCellArray = [String: CGPoint]()
        //   dynamicAnimator.removeAllBehaviors()
        oldCellInformation = cellInformation
        oldCellArray = newCellArray
        
        for sectionIndex in 0 ..< numSections {
            for itemIndex in 0 ..< collectionView!.numberOfItemsInSection(sectionIndex) {
                let indexPath = NSIndexPath(forItem: itemIndex, inSection: sectionIndex)
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                
                
                let diameter = delegate.collectionView(collectionView!, diameterForGoalAtIndexPath: indexPath)
                let (x, y) = calculateNextPosition(Int(diameter))
                
                attributes.frame = CGRect(x: CGFloat(x), y: CGFloat(y), width: diameter, height: diameter)
                circlePosition.append([x, y, Int(diameter)])
                localCellInformation[delegate.getName(indexPath)] = attributes
                localCellArray[delegate.getName(indexPath)] = attributes.center
                contentHeight =  max(contentHeight, CGFloat(y) + diameter)
            }
        }
        cellInformation = localCellInformation
        newCellArray = localCellArray
        
        //        if (!animatorSet) {
        //            for (name, cell) in cellInformation {
        //                let attributes = cell
        //                let center = cell.center
        //                let springBehavior = UIAttachmentBehavior(item: attributes, attachedToAnchor: center)
        //                springBehavior.length = 0
        //                springBehavior.damping = 0.8
        //                springBehavior.frequency = 1
        //                dynamicAnimator.addBehavior(springBehavior)
        //            }
        //            animatorSet = true
        //        } else {
        //            for (index, springBehavior) in self.dynamicAnimator!.behaviors.enumerate() {
        //
        //                let currItem = (springBehavior as! UIAttachmentBehavior).items[0] as! UICollectionViewLayoutAttributes
        //                let currCenter = currItem.center
        //                var cellName = ""
        //
        //                for (name, center) in oldCellArray {
        //                    if (center == currCenter) {
        //                        print(name)
        //                        cellName = name
        //                        break
        //                    }
        //                }
        //
        //                let newCenter = newCellArray[cellName]
        //                currItem.center = newCenter!
        //                
        //                self.dynamicAnimator?.updateItemUsingCurrentState(currItem)
        //                
        //            }
        //        }
    }
    
    // dimension of entire content, not just visible
    override func collectionViewContentSize() -> CGSize {
        /// todo: adjust content height to be tighter
        return CGSize(width: contentWidth, height: contentHeight)
    }

    // determines the items which are visible in the viewport
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for (_, attr) in cellInformation {
            if CGRectIntersectsRect(attr.frame, rect) {
                layoutAttributes.append(attr)
            }
        }
        return layoutAttributes
    }

    //    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    //        let dynamic = dynamicAnimator.itemsInRect(rect)
    //        var layoutAttributes = [UICollectionViewLayoutAttributes]()
    //        for item in dynamic {
    //            let center = item.center
    //            for (name, attr) in cellInformation {
    //                if (center == attr.center) {
    //                    layoutAttributes.append(attr)
    //                    break
    //                }
    //            }
    //        }
    //        return layoutAttributes
    //    }
    //
    //    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    //        return dynamicAnimator.layoutAttributesForCellAtIndexPath(indexPath)
    //    }
    
    
    private func calculateNextPosition(diameter: Int) -> (Int, Int){
        var xValue = 0
        var minYValue = Int(contentHeight)
        let maxXValue = Int(self.collectionView!.bounds.size.width) - diameter
        
        for currX in 0..<maxXValue {
            var currY = minYValue
            var intersection = false
            while (currY >= 0) {
                for circle in circlePosition {
                    if (circleIntersection(circle[0]+circle[2]/2, y1: circle[1]+circle[2]/2,
                        r1: circle[2]/2, x2: currX+diameter/2, y2: currY+diameter/2, r2: diameter/2)) {
                        intersection = true
                        break
                    }
                }
                if (intersection) {
                    break
                } else {
                    currY -= 1
                }
            }
            if (currY < minYValue) {
                xValue = currX
                minYValue = currY
            }
        }
        
        return (xValue, minYValue)
    }
    
    private func circleIntersection(x1: Int, y1: Int, r1: Int, x2: Int, y2: Int, r2: Int) -> Bool {
        let dx = Double(x1) - Double(x2);
        let dy = Double(y1) - Double(y2);
        let distance = sqrt(dx * dx + dy * dy);
        
        if distance <= (Double(r1) + Double(r2)) {
            return true
        } else {
            return false
        }
    }}
