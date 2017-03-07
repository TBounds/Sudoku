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
    var gameWon = false
    var showConflictingCells: Bool = true
    
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
        let tinyFont = UIFont(name: "Helvetica", size: 15)
        
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
            if !self.gameWon {
                if selected.row >= 0 && selected.column >= 0 {
                    UIColor.yellow.setFill()
                    let x = boardRect.origin.x + CGFloat(selected.column)*distBetweenLines
                    let y = boardRect.origin.y + CGFloat(selected.row)*distBetweenLines
                    context.fill(CGRect(x: x, y: y, width: distBetweenLines - 0.5, height: distBetweenLines - 0.5))
                }
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
           
            
            // Draw values of cells
            for row in 0 ..< 9 {
                for col in 0 ..< 9 {
                    
                    if puzzle!.puzzle[row][col].number != 0 {
                        let text = "\(puzzle!.puzzle[row][col].number)" as NSString
                        let textSize = text.size(attributes: fixedAttributes)
                        let x = gridOrigin.x + CGFloat(col)*d + 0.5*(d - textSize.width)
                        let y = gridOrigin.y + CGFloat(row)*d + 0.5*(d - textSize.height)
                        let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
                        
                        // Draw fixed numbers in cell.
                        if puzzle!.puzzle[row][col].isFixed {
                            text.draw(in: textRect, withAttributes: fixedAttributes)
                        }
                        // Draw non-fixed numbers in cell.
                        else /*if !(puzzle!.anyPencilSetAtCell(row: row, column: col))*/ {  // Commented this out so that user can overwrite pencil values with a guess/answer. 
                                                                                            // Pencil values remain but are not visible.
                            if puzzle!.puzzle[row][col].isConflicting && showConflictingCells {
                                text.draw(in: textRect, withAttributes: conflictingNonFixedAttributes)
                            }
                            else{
                                text.draw(in: textRect, withAttributes: nonFixedAttributes)
                            }
                            
                        }
                        
                    }
                    
                    // Draw penciled values.
                    else if (puzzle!.anyPencilSetAtCell(row: row, column: col)) {
                        
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
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}
