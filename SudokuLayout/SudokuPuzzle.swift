//
//  SudokuPuzzle.swift
//  SudokuLayout
//
//  Created by Tyler James Bounds on 2/24/17.
//  Copyright © 2017 Tyler James Bounds. All rights reserved.
//

import Foundation

class SudokuPuzzle {
    
    
    
    // Creates empty puzzle.
    init() {
        
    }
    
    // Write to plist compatible array.
    func savedState() -> NSArray {
        
        return [0]
    }
    
    // Read from plist compatible array.
    func setState(puzzleArray: NSString) {
        
    }
    
    // Load new game encoded with given string.
    func loadPuzzle(puzzleString: String) {
        
    }
    
    // Fetch the number stored in the cell at the specified row and column;
    // zero indicates an empty cell or the cell holds penciled in values.
    func numberAtRow(row: Int, column: Int) -> Int {
        
        return 0
    }
    
    // Set the number at the specified cell; assumes the cell does not contain
    // a fixed number.
    func setNumber(number: Int, row: Int, column: Int) {
        
    }
    
    // Determines if cells contains fixed number.
    func numberIsFixedAtRow(row: Int, column: Int) -> Bool {
        
        return false
    }
    
    // Does the number conflict w/ any other numbers in the same row, column, or 3x3
    func isConflictingEntryAtRow(row: Int, column: Int) -> Bool {
        
        return false
    }
    
    // Are there any penciled in values at the given cell? (assumes number == 0)
    func anyPencilSetAtRow(row: Int, column: Int) -> Bool {
        
        return false
    }
    
    // Is the value n penciled in?
    func isSetPencil(n: Int, row: Int, column: Int) -> Bool {
        
        return false
    }
    
    // Pencil the value n in.
    func setPencil(n: Int, row: Int, column: Int) {
        
    }
    
    // Clear pencil value n.
    func clearPencil(n: Int, row: Int, column: Int) {
        
    }
    
    // Clear all penciled in values.
    func clearAllPencils(row: Int, column: Int) {
        
    }

}
