//
//  PuzzleView.swift
//  SudokuLayout
//
//  Created by Tyler James Bounds on 2/23/17.
//  Copyright © 2017 Tyler James Bounds. All rights reserved.
//

import UIKit

class PuzzleView: UIView {
    
    var selected: (row: Int, column: Int) = (row: -1, column: -1)
    var showConflictingCells: Bool = false
    var conflictingCellsCount: Int = 0
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        addMyTapGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addMyTapGestureRecognizer()
    }
    
    func boardRect() -> CGRect {
        let margin : CGFloat = 10
        let size = ceil((min(self.bounds.width, self.bounds.height) - margin)/8.0)*8.0
        let center = CGPoint(x: self.bounds.width/2,
                             y :self.bounds.height/2)
        let boardRect = CGRect(x: center.x - size/2,
                               y: center.y - size/2,
                               width: size, height: size)
        return boardRect
    }
    
    func addMyTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PuzzleView.handleTap(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func handleTap(_ sender : UIGestureRecognizer) {
        let tapPoint = sender.location(in: self)
        // ... compute gridOrigin and d as done in drawRect ...
        let boardRect = self.boardRect()
        let gridOrigin = boardRect.origin
        
        let gridSize = boardRect.width
        let delta = gridSize/3
        let d = delta/3
        // let s = d/3
        
        let col = Int((tapPoint.x - gridOrigin.x)/d)
        let row = Int((tapPoint.y - gridOrigin.y)/d)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let puzzle = appDelegate.sudoku // fetch model data
        if 0 <= col && col < 9 && 0 <= row && row < 9 { // if inside puzzle bounds
            if (!(puzzle?.numberIsFixedAtRow(row: row, column: col))!) { // and not a "fixed number"
                if (row != selected.row || col != selected.column) {// and not already selected
                    
                    selected.row = row  // then select cell
                    selected.column = col
                    
                    NSLog("PuzzleView. row = \(selected.row), column = \(selected.column)")
                    
                    setNeedsDisplay()   // request redraw 
                    
                }
            }
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let puzzle = appDelegate.sudoku // fetch model data

        
        // Drawing code
        let boldFont = UIFont(name: "Helvetica", size: 30)
        let tinyFont = UIFont(name: "Helvetica", size: 10)
        
        let fixedAttributes = [NSFontAttributeName : boldFont!, NSForegroundColorAttributeName: UIColor.black]
        let nonFixedAttributes = [NSFontAttributeName : boldFont!, NSForegroundColorAttributeName: UIColor.darkGray]
        let conflictingNonFixedAttributes = [NSFontAttributeName : boldFont!, NSForegroundColorAttributeName: UIColor.red]
        let pencilAttributes = [NSFontAttributeName : tinyFont!, NSForegroundColorAttributeName: UIColor.darkGray]

        
        let boardRect = self.boardRect()
        
        // ...
        let gridSize = boardRect.width
        let delta = gridSize/3
        let d = delta/3
        let s = d/3
        
        let gridOrigin = (x: boardRect.origin.x, y: boardRect.origin.y)
        
        if let context = UIGraphicsGetCurrentContext() {
            
            
            // Sets grid line color.
            UIColor.black.setStroke()
            
            let lineLength = boardRect.size.width
            let distBetweenLines = boardRect.size.width/9
            
            // Highlights selected cell.
            if selected.row >= 0 && selected.column >= 0 {
                UIColor.red.setFill()
                let x = boardRect.origin.x + CGFloat(selected.column)*distBetweenLines
                let y = boardRect.origin.y + CGFloat(selected.row)*distBetweenLines
                context.fill(CGRect(x: x, y: y, width: distBetweenLines - 0.5, height: distBetweenLines - 0.5))
            }
            
            // Draw the grid rows.
            for r in 0 ..< 10 {
                
                if r % 3 == 0 {
                   context.setLineWidth(2.5)
                }
                else {
                    context.setLineWidth(1.0)
                }
                context.stroke(CGRect(x: boardRect.origin.x,
                                      y: boardRect.origin.y + CGFloat(r)*distBetweenLines,
                                      width: lineLength, height: 0))
            }
            
            // Draw the grid columns.
            for c in 0 ..< 10 {
                
                if c % 3 == 0 {
                    context.setLineWidth(2.5)
                }
                else {
                    context.setLineWidth(1.0)
                }
                context.stroke(CGRect(x: boardRect.origin.x + CGFloat(c)*distBetweenLines,
                                      y: boardRect.origin.y,
                                      width: 0, height: lineLength))
            }
           
            
            // Draw values of cells (non-penciled values)
            for row in 0 ..< 9 {
                for col in 0 ..< 9 {
                    
                    if puzzle!.puzzle[row][col].number != 0 {
                        let text = "\(puzzle!.puzzle[row][col].number)" as NSString
                        let textSize = text.size(attributes: fixedAttributes)
                        let x = gridOrigin.x + CGFloat(col)*d + 0.5*(d - textSize.width)
                        let y = gridOrigin.y + CGFloat(row)*d + 0.5*(d - textSize.height)
                        let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
                        
                        // Draw fixed numbers in cell.
                        if puzzle!.puzzle[row][col].isFixed{
                            text.draw(in: textRect, withAttributes: fixedAttributes)
                        }
                        // Draw non-fixed numbers in cell.
                        else if !(puzzle!.anyPencilSetAtCell(row: row, column: col)) {
                            if puzzle!.puzzle[row][col].isConflicting && showConflictingCells {
                                text.draw(in: textRect, withAttributes: conflictingNonFixedAttributes)
                            }
                            else{
                                text.draw(in: textRect, withAttributes: nonFixedAttributes)
                            }
                            
                        }
                        
                    }
                    
                    // Draw penciled values.
                    if (puzzle!.anyPencilSetAtCell(row: row, column: col)) {
                        
                        // puzzle!.puzzle[row][col].pencils[i]
                        // let s2 = s*CGFloat(i)
                        
                        var index = 1
                        
                        for r in 0 ..< 3 {
                            for c in 0 ..< 3 {
                                
                                if puzzle!.isSetPencil(n: index, row: row, column: col) {
                                    
                                    let text = "\(index)" as NSString
                                    let textSize = text.size(attributes: pencilAttributes)
                                    
                                    
                                    let sr = s*2*CGFloat(r) + s
                                    let sc = s*2*CGFloat(c) + s
                                    
                                    let x = gridOrigin.x + CGFloat(col)*d + 0.5*(sc - textSize.width)
                                    let y = gridOrigin.y + CGFloat(row)*d + 0.5*(sr - textSize.height)
                                    let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
                                    
                                    text.draw(in: textRect, withAttributes: pencilAttributes)
                                    
                                }
                                
                                index += 1
                                
                            }
                            
                            // NSLog("should print pencil value: \(i)")
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    //---------------------------------------------------//
    //----- Programmtically managing button layout. -----//
    //---------------------------------------------------//
    let buttonTagsPortrait = [  // 2x6 button layout
        [1, 2, 3, 4, 5, 11],    // tags assigned in IB
        [6, 7, 8, 9, 10, 12]
    ]
    
    let buttonTagsPortraitTall = [[1, 2, 3, 4],         // 3 x 4 layout
                                  [5, 6, 7, 8],
                                  [9, 10, 11, 12]]
    
    let buttonTagsLandscape = [[1, 6],                  // 6 x 2 layout
                               [2, 7],
                               [3, 8],
                               [4, 9],
                               [5, 10],
                               [11, 12]]
    
    let buttonTagsLandscapeTall = [[1, 2, 3],           // 4 x 3 layout
                                   [4, 5, 6],
                                   [7, 8, 9],
                                   [10, 11, 12]]
    
    let aspectRatiosForLayouts : [Float] = [
        3.0,    // 2 x 6
        4.0/3,  // 3 x 4
        1.0/3,  // 6 x 2
        3.0/4   // 4 x 3
    ]
    
    override func layoutSubviews() {
        super.layoutSubviews() // let Auto Layout finish
        let aspectRatio = Float(self.bounds.size.width / self.bounds.size.height)
        var closestLayout = 0
        var closestLayoutDiff = fabsf(aspectRatio - aspectRatiosForLayouts[0])
        for i in 1 ..< 4 {
            let diff = fabsf(aspectRatio - aspectRatiosForLayouts[i])
            if (diff < closestLayoutDiff) {
                closestLayout = i
                closestLayoutDiff = diff
            }
        }
        let buttonTagsFlavors = [
            buttonTagsPortrait, buttonTagsPortraitTall, buttonTagsLandscape, buttonTagsLandscapeTall
        ]
        let buttonTags = buttonTagsFlavors[closestLayout]
        func integersWithSum(sum : Int, count : Int) -> [Int] {
            var ints = [Int](repeating: sum / count, count: count)
            let r = sum % count
            for i in 0 ..< r {ints[i] += 1}
            return ints
        }
        let inset = 1
        let W = Int(self.bounds.width) - 2*inset, H = Int(self.bounds.height) - 2*inset
        let numColumns = buttonTags[0].count, numRows = buttonTags.count
        let widths  = integersWithSum(sum: W, count: numColumns)
        let heights = integersWithSum(sum: H, count: numRows)
        var y = CGFloat(inset)
        for r in 0 ..< numRows {
            let h = CGFloat(heights[r])
            var x = CGFloat(inset)
            for c in 0 ..< numColumns {
                let w = CGFloat(widths[c])
                let button = self.viewWithTag(buttonTags[r][c])
                button?.bounds = CGRect(x: 0, y: 0, width: w, height: h)
                button?.center = CGPoint(x: (x + w/2), y: (y + h/2))
                x += w
            }
            y += h
        }
    }
    
    
    
 

}

