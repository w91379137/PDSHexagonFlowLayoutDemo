//
//  PDSHexagonFlowLayout.swift
//  PDSHexagonFlowLayoutDemo
//
//  Created by yc on 2017/8/4.
//  Copyright © 2017年 yc. All rights reserved.
//

import UIKit

protocol PDSHexagonFlowLayoutDelegate: UICollectionViewDelegate {
    
}

class PDSHexagonFlowLayout: UICollectionViewFlowLayout {
    
    var gap: CGFloat = 0
    var delegate: PDSHexagonFlowLayoutDelegate? = nil
    
    private var sectionCount = 0
    private var cellCount = 0
    private var cellCountPerSection = [Int]()
    private var cellsPerLine = 0
    
    //Life Cycle
    override func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView else {
            return
        }
        
        // Section count
        self.sectionCount = collectionView.numberOfSections
        
        // Cell counts
        var cellCount = 0
        var cellCountPerSection = [Int]()
        for idx in 0..<self.sectionCount {
            
            let cellCountInSection = collectionView.numberOfItems(inSection: idx)
            
            cellCount += cellCountInSection
            cellCountPerSection.append(cellCountInSection)
        }
        
        self.cellCount = cellCount
        self.cellCountPerSection = cellCountPerSection
        
        // Cells per line
        if (self.scrollDirection == .vertical) {
            
            let availableWidth = collectionView.bounds.width - self.sectionInset.left - self.sectionInset.right
            let eachItemWidth = self.itemSize.width + self.minimumLineSpacing
            
            self.cellsPerLine = Int(floor(availableWidth / eachItemWidth))
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override var collectionViewContentSize: CGSize {
        
        var width = CGFloat(0)
        var height = CGFloat(0)
        
        guard let collectionView = self.collectionView else {
            return CGSize(width: width, height: height)
        }
        
        if self.scrollDirection == .horizontal {
            
            width += self.headerReferenceSize.width * CGFloat(self.sectionCount)
            width += (self.sectionInset.left + self.sectionInset.right) * CGFloat(self.sectionCount)
            for idx in 0..<self.sectionCount {
                width += self.itemSize.width * CGFloat(self.cellCountPerSection[idx])
                width += self.minimumLineSpacing * CGFloat(self.cellCountPerSection[idx] - 1)
            }
            width += self.footerReferenceSize.width * CGFloat(self.sectionCount)
            
            height = collectionView.bounds.height
        }
        else {
            
            width = collectionView.bounds.width
            
            height += self.headerReferenceSize.height * CGFloat(self.sectionCount)
            height += (self.sectionInset.top + self.sectionInset.bottom) * CGFloat(self.sectionCount)
            for idx in 0..<self.sectionCount {
                height += self.itemSize.height * CGFloat(self.cellCountPerSection[idx])
                height += self.minimumLineSpacing * CGFloat(self.cellCountPerSection[idx] - 1)
            }
            height += self.footerReferenceSize.height * CGFloat(self.sectionCount)
        }
        
        //print("collectionViewContentSize \(width) \(height)")
        return CGSize(width: width, height: height)
    }
    
    let reserved_cells = CGFloat(10) //這個 計算有問題 沒考慮 header Footer 跟形狀
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var allAttributes = [UICollectionViewLayoutAttributes]()
        
        var start: Int
        var end: Int
        
        //這個 計算有問題
        if self.scrollDirection == .horizontal {
            
            start = Int(max(rect.minX / (self.itemSize.width + self.minimumInteritemSpacing) - reserved_cells, CGFloat(0)))
            end = Int(min(rect.maxX / (self.itemSize.width + self.minimumInteritemSpacing) + reserved_cells, CGFloat(self.cellCount)))
            
        }
        else {
            
            start = Int(max(rect.minY / (self.itemSize.height + self.minimumLineSpacing) - reserved_cells, CGFloat(0)))
            end = Int(min(rect.maxY / (self.itemSize.height + self.minimumLineSpacing) + reserved_cells, CGFloat(self.cellCount)))
            
        }
        
        // Find first index item and section
        var item = start
        var section = 0
        while true {
            let count = self.cellCountPerSection[section]
            if item >= count {
                item -= count
                section += 1
            }
            else {
                break
            }
        }
        
        // Loop over attributes
        for _ in start..<end {
            
            let indexPath = IndexPath(item: item, section: section)
            
            if item == 0 {
                let kind = UICollectionElementKindSectionHeader
                if let attributes = self.layoutAttributesForSupplementaryView(ofKind: kind, at: indexPath) {
                    allAttributes.append(attributes)
                }
            }
            if item == self.cellCountPerSection[section] - 1 {
                let kind = UICollectionElementKindSectionFooter
                
                if let attributes = self.layoutAttributesForSupplementaryView(ofKind: kind, at: indexPath) {
                    allAttributes.append(attributes)
                }
            }
            
            if let attributes = self.layoutAttributesForItem(at: indexPath) {
                allAttributes.append(attributes)
            }
            
            if item >= self.cellCountPerSection[section] - 1{
                section += 1
                item = 0
            }
            else {
                item += 1
            }
        }
        
        return allAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: indexPath)
        
        let x = self.centerXForItemAtIndexPath(indexPath: indexPath)
        let y = self.centerYForItemAtIndexPath(indexPath: indexPath)
        attributes?.center = CGPoint(x: x, y: y)
        print(indexPath, x, y)
        
        return attributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        return attributes
    }
    
    //MARK: - Utils
    func centerXForItemAtIndexPath(indexPath: IndexPath) -> CGFloat {
        var x = CGFloat(0)
        
        // Compute y position according to scroll direction
        if self.scrollDirection == .horizontal {
            
            // Section header
            x += self.headerReferenceSize.width * CGFloat(indexPath.section + 1)
            
            // Section left inset
            x += self.sectionInset.left * CGFloat(indexPath.section + 1)
            
            // Previous sections hexagons
            for idx in 0..<indexPath.section {
                
                // Cells pure width
                x += self.itemSize.width * CGFloat(self.cellCountPerSection[idx])
                
                // Inter item spaces
                x += self.minimumLineSpacing * CGFloat(self.cellCountPerSection[idx] - 1)
            }
            
            // Current section hexagons pure width and inter item spaces
            x += self.itemSize.width * (indexPath.item + 1).cgfloat - self.itemSize.width / 2
            x += self.minimumInteritemSpacing * indexPath.item.cgfloat
            
            x += self.sectionInset.right * indexPath.section.cgfloat
            x += self.footerReferenceSize.width * indexPath.section.cgfloat
        }
        else {
            
            let indexInLine = (indexPath.item % self.cellsPerLine).cgfloat
            
            x += self.itemSize.width * indexInLine + self.itemSize.width / 2
            x += self.minimumInteritemSpacing * indexInLine
            x += self.sectionInset.left
        }
        
        return x
    }
    
    func centerYForItemAtIndexPath(indexPath: IndexPath) -> CGFloat {
        
        var y = CGFloat(0)
        
        // Compute y position according to scroll direction
        if self.scrollDirection == .horizontal {
            y = self.itemSize.height / 2 + ((indexPath.item % 2) == 0 ? 0 : self.gap) + self.sectionInset.top
        }
        else {
            
            y += self.headerReferenceSize.height * (indexPath.section + 1).cgfloat
            y += self.sectionInset.top * (indexPath.section + 1).cgfloat
            
            for idx in 0..<indexPath.section {
                y += self.cellsHeightForSection(section: idx)
            }
            
            let currentLine = floor(indexPath.item.cgfloat / self.cellsPerLine.cgfloat)
            
            y += self.itemSize.height * currentLine + self.itemSize.height / 2
            y += self.minimumLineSpacing * currentLine
            
            let indexInLine = indexPath.item % self.cellsPerLine
            
            y += indexInLine % 2 == 0 ? 0 : self.gap
            y += self.sectionInset.bottom * indexPath.section.cgfloat
            y += self.footerReferenceSize.height * indexPath.section.cgfloat
        }
        
        return y
    }
    
    func cellsHeightForSection(section: Int) -> CGFloat {
        
        var height = 0.cgfloat
        
        if self.scrollDirection == .horizontal {
            height = self.collectionView!.bounds.height
        }
        else {
            
            let cellsInSection = self.cellCountPerSection[section]
            let linesInSection = ceil(cellsInSection.cgfloat / self.cellsPerLine.cgfloat)
            
            if cellsInSection == 0 {
                return 0
            }
            else if cellsInSection == 1 {
                return self.itemSize.height
            }
            else if cellsInSection % self.cellsPerLine == 1 {
                height += (linesInSection - 1) * self.itemSize.height
                height += self.itemSize.height
                height += self.minimumLineSpacing * (linesInSection - 1)
            }
            else {
                height += linesInSection * self.itemSize.height
                height += (linesInSection - 1) * self.minimumLineSpacing
                height += self.gap
            }
        }
        
        return height
    }
}



