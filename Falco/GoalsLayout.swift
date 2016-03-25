//
//  GoalsLayout.swift
//  Pegasus
//
//  Created by Gerald on 17/3/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import UIKit

class GoalsLayout: UICollectionViewLayout {
  let numberOfColumns = 12
  var numberOfRows = 0

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

          var y = yOffset[rowNumber]
          var x = xOffset[itemIndex % numberOfColumns]

          if rowNumber % 2 != 0 {
            x += oddRowOffset
          }

          if rowNumber != 0 {
            y -= yAdjustment * CGFloat(rowNumber)
          }

          attributes.frame = CGRect(x: x, y: y, width: columnWidth, height: rowHeight)
          cache.append(attributes)
        }
      }
      contentHeight =  CGFloat(numberOfRows) * (rowHeight - yAdjustment)
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
}
