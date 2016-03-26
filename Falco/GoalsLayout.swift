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
}

class GoalsLayout: UICollectionViewLayout {
    var delegate: GoalLayoutDelegate!
  let numberOfColumns = 12
  var numberOfRows = 0
    var circlePosition = [[Int]]()

  private var cache = [UICollectionViewLayoutAttributes]()

  /// content refers to entire collection of cells
  private var contentHeight: CGFloat = 0
  private var contentWidth: CGFloat {    // columns x cell width
    let insets = collectionView!.contentInset
    return CGRectGetWidth(collectionView!.bounds) - insets.left - insets.right
  }

  // perform prior calculation for layout. like a setup phase
  override func prepareLayout() {
    print("preparing layout")
    if cache.isEmpty {
      let numSections = collectionView!.numberOfSections()
      let numItemsInLastSection = collectionView!.numberOfItemsInSection(numSections - 1)
      numberOfRows = numItemsInLastSection > numberOfColumns ? numSections * 2 : numSections * 2 - 1

      var xOffset = [CGFloat]()
      var yOffset = [CGFloat]()

      // xOffset calculations
      let columnWidth = contentWidth / CGFloat(numberOfColumns)
      let oddRowOffset = columnWidth / 2
      for columnIndex in 0 ..< numberOfColumns {
        xOffset.append(CGFloat(columnIndex) * columnWidth)
      }

      // yOffset calculations
      let rowHeight = columnWidth
      for rowIndex in 0 ..< numberOfRows {
        yOffset.append(CGFloat(rowIndex) * rowHeight)
      }

      let yAdjustment = isometricAdjustment(columnWidth, heightWidthRatio: Float(rowHeight / columnWidth))

      for sectionIndex in 0 ..< numSections {

        for itemIndex in 0 ..< collectionView!.numberOfItemsInSection(sectionIndex) {
          let indexPath = NSIndexPath(forItem: itemIndex, inSection: sectionIndex)
          let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
          let rowNumber = itemIndex < numberOfColumns ? sectionIndex * 2 : sectionIndex * 2 + 1

//          var y = yOffset[rowNumber]
//          var x = xOffset[itemIndex % numberOfColumns]
//
//          if rowNumber % 2 != 0 {
//            x += oddRowOffset
//          }
//
//          if rowNumber != 0 {
//            y -= yAdjustment * CGFloat(rowNumber)
//          }
            
            
            let diameter = delegate.collectionView(collectionView!, diameterForGoalAtIndexPath: indexPath)
            let (x, y) = calculateNextPosition(Int(diameter))

          attributes.frame = CGRect(x: CGFloat(x), y: CGFloat(y), width: diameter, height: diameter)
            circlePosition.append([x, y, Int(diameter)])
          cache.append(attributes)
            contentHeight =  max(contentHeight, CGFloat(y) + diameter)
        }
      }
    }

  }

  // dimension of entire content, not just visible
  override func collectionViewContentSize() -> CGSize {
    /// todo: adjust content height to be tighter
    return CGSize(width: contentWidth, height: contentHeight)
  }

  // determines the items which are visible in the viewport
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    for attr in cache {
      if CGRectIntersectsRect(attr.frame, rect) {
        layoutAttributes.append(attr)
      }
    }
    return layoutAttributes
  }

  private func isometricAdjustment(diameter: CGFloat, heightWidthRatio: Float) -> CGFloat {
    let diagonalLengthOfCell = sqrt(pow(diameter, 2) * 2)
    let cellCornerToNearestArcDistance = (diagonalLengthOfCell - diameter) / 2
    let yAdjustment = CGFloat(cos(atan(heightWidthRatio))) * cellCornerToNearestArcDistance
    return yAdjustment
  }
    
    private func calculateNextPosition(diameter: Int) -> (Int, Int){
        var xValue = 0
        var minYValue = Int(contentHeight)
        let maxXValue = Int(contentWidth) - diameter
        
        for currX in 0..<maxXValue {
            var currY = minYValue
            var intersection = false
            while (currY >= 0) {
                for circle in circlePosition {
                    if (circleIntersection(circle[0]+circle[2]/2, y1: circle[1]+circle[2]/2, r1: circle[2]/2, x2: currX+diameter/2, y2: currY+diameter/2, r2: diameter/2)) {
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
    
    func circleIntersection(x1: Int, y1: Int, r1: Int, x2: Int, y2: Int, r2: Int) -> Bool {
        let dx = Double(x1) - Double(x2);
        let dy = Double(y1) - Double(y2);
        let distance = sqrt(dx * dx + dy * dy);
        
        if distance <= (Double(r1) + Double(r2)) {
            return true
        } else {
            return false
        }
    }
}
