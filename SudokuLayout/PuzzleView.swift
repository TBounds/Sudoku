//
//  PuzzleView.swift
//  SudokuLayout
//
//  Created by Tyler James Bounds on 2/23/17.
//  Copyright © 2017 Tyler James Bounds. All rights reserved.
//

import UIKit

class PuzzleView: UIView {
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    

//    func handleTap(sender : UIGestureRecognizer) {
//        let tapPoint = sender.location(in: self)
//        // ... compute gridOrigin and d as done in drawRect ...
//        let gridSize = self.bounds.width - 8
//        let delta = gridSize/3
//        let d = delta/3
//        let s = d/3
//        
//        let gridOrigin = getGridOrigin()
//        
//        let col = Int((tapPoint.x - gridOrigin.x)/d)
//        let row = Int((tapPoint.y - gridOrigin.y)/d)
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let puzzle = appDelegate.sudoku // fetch model data
//        if 0<=col&&col<9&&0<=row&&row<9{ //ifinsidepuzzlebounds
//            if (!puzzle.numberIsFixedAtRow(row, column: col)) { // and not a "fixed number"
//                if (row != selected.row || col != selected.column) {// and not already selected
//                    selected.row = row  // then select cell
//                    selected.column = col
//                    setNeedsDisplay()   // request redraw
//                    
//                    
//                }
//            }
//        }
//    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        // Drawing code
        let boldFont = UIFont(name: "Helvetica", size: 30)
        let fixedAttributes = [NSFontAttributeName : boldFont!, NSForegroundColorAttributeName: UIColor.black]
        
        let boardRect = self.boardRect()
        
        // ...
        let gridSize = self.bounds.width - 8
        let delta = gridSize/3
        let d = delta/3
        // let s = d/3
        
        let gridOrigin = (x: boardRect.origin.x, y: boardRect.origin.y)
        
        if let context = UIGraphicsGetCurrentContext() {
            
            
            
            
            
            // Sets grid line color.
            UIColor.black.setStroke()
            
            let lineLength = boardRect.size.width
            let distBetweenLines = boardRect.size.width/9
            
            // Draw the grid rows.
            for r in 0 ..< 10 {
                
                if r % 3 == 0 {
                   context.setLineWidth(3.0)
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
                    context.setLineWidth(3.0)
                }
                else {
                    context.setLineWidth(1.0)
                }
                context.stroke(CGRect(x: boardRect.origin.x + CGFloat(c)*distBetweenLines,
                                      y: boardRect.origin.y,
                                      width: 0, height: lineLength))
            }
            
            let number = 0 // XXX TEMP, REMOVE
            let col = 1
            let row = 0
            
            let text = "\(number)" as NSString
            let textSize = text.size(attributes: fixedAttributes)
            let x = gridOrigin.x + CGFloat(col)*d + 0.5*(d - textSize.width)
            let y = gridOrigin.y + CGFloat(row)*d + 0.5*(d - textSize.height)
            let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
            text.draw(in: textRect, withAttributes: fixedAttributes)
        }
        
    }
    
    
    
    
    
    
 

}

