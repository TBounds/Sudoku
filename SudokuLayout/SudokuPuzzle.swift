//
//  SudokuPuzzle.swift
//  SudokuLayout
//
//  Created by Tyler James Bounds on 2/24/17.
//  Copyright © 2017 Tyler James Bounds. All rights reserved.
//

import Foundation

class SudokuPuzzle {
    
    enum CellConflictType {
        case noConflict, oldConflict, newConflict, removedConflict
    }
    
    var conflictType : CellConflictType?
    
    struct PuzzleCell {
        var pencils: [Int] = Array(repeating: 0, count: 10) // Array of zeros to hold pencil values for a vell.
        var number: Int = 0
        var isFixed: Bool = false
        var isConflicting: Bool = false
        
    }
    
    var puzzle : [[PuzzleCell]] = []
    
    // Creates empty puzzle.
    init() {
        self.puzzle = Array(repeating: Array(repeating: PuzzleCell(), count: 9), count: 9)
    }
    
    // Write to plist compatible array.
    func savedState() -> NSArray {
        
        return [0]
    }
    
    // Read from plist compatible array.
    func setState(puzzleArray: NSString) {
        
    }
    
    // Returns a puzzle as a string of 81 chaarcters.
    func getPuzzles(name : String) -> [String] {
        let path = Bundle.main.path(forResource: name, ofType: "plist")
        let array = NSArray(contentsOfFile: path!)
        return array as! [String]
    }
    
    // Load new game encoded with given string.
    func loadPuzzle(puzzleString: String) {
        
        let puzzles = getPuzzles(name: puzzleString)                                    // Loads all puzzles from plist
        let randomPuzzleIndex = Int(arc4random_uniform(UInt32(puzzles.count)))          // Random index to choose which puzzle to use.
        
        let puzzleElements = puzzles[randomPuzzleIndex].characters.map { String($0) }   // Puzzle string broken up into character array.
        
        var puzzleIndex = 0     // Which index of the chosen puzzle.
        
        for r in 0 ..< 9 {
            for c in 0 ..< 9 {
                if puzzleElements[puzzleIndex] != "." {
                    puzzle[r][c].number = Int(puzzleElements[puzzleIndex])!
                    puzzle[r][c].isFixed = true
                }
                
                puzzleIndex += 1
            }
        }
        
        
        
    }
    
    // Fetch the number stored in the cell at the specified row and column;
    // zero indicates an empty cell or the cell holds penciled in values.
    func numberAtRow(row: Int, column: Int) -> Int {
        
        return puzzle[row][column].number
    }
    
    // Set the number at the specified cell; assumes the cell does not contain
    // a fixed number.
    func setNumber(number: Int, row: Int, column: Int) -> CellConflictType {
        
        var conflict : CellConflictType
        
        puzzle[row][column].number = number
        
        
        // This figures out the nature of the conflict when ENTERING in a number at a cell.
        // newConflicts will cause a conflict coutner to increment while removedConflict will decrement.
        // XXX I do not need oldConflict and noConflict but for now I am leaving it this way.
        if number != 0 {
            if isConflictingEntryAtRow(row: row, column: column, number: number){
                if puzzle[row][column].isConflicting {
                    conflict = CellConflictType.oldConflict
                }
                else {
                    conflict = CellConflictType.newConflict
                }
                puzzle[row][column].isConflicting = true
            }
            else {
                if puzzle[row][column].isConflicting{
                    conflict = CellConflictType.removedConflict
                }
                else {
                    conflict = CellConflictType.noConflict
                }
                
                puzzle[row][column].isConflicting = false
            }
        }
        // This figures out the nature of the conflict when DELETING a number at a cell.
        else {
            if puzzle[row][column].isConflicting {
                conflict = CellConflictType.removedConflict
                puzzle[row][column].isConflicting = false
            }
            else {
                conflict = CellConflictType.noConflict
            }
        }
        
        
        return conflict
        
    }
    
    // Determines if cells contains fixed number.
    func numberIsFixedAtRow(row: Int, column: Int) -> Bool {
        
        return (puzzle[row][column].isFixed)
    
    }
    
    // Does the number conflict w/ any other numbers in the same row, column, or 3x3
    func isConflictingEntryAtRow(row: Int, column: Int, number: Int) -> Bool {
        
        // Check if there is a conflicting number in the column
        for r in 0 ..< 9 {
            if r != row && puzzle[r][column].number == number {
                return true
            }
        }
        
        // Check if there is a conflicting number in the row
        for c in 0 ..< 9 {
            if c != column && puzzle[row][c].number == number {
                return true
            }
        }
        
        // Check if there is a conflicting number in the cell
        let rowStart = row - (row % 3)
        let colStart = column - (column % 3)
        
        for r in rowStart ..< (rowStart + 3) {
            for c in colStart ..< (colStart + 3) {
                if puzzle[r][c].number == number && r != row && c != column{
                    return true
                }
            }
        }
        
        // No conflicts
        return false
    }
    
    // Are there any penciled in values at the given cell? (assumes number == 0)
    func anyPencilSetAtCell(row: Int, column: Int) -> Bool {
        
        for i in 0 ..< 10 {
            if puzzle[row][column].pencils[i] == 1 {
                return true
            }
        }
        
        return false
    }
    
    // Number of penciled in values at cell.
    func numberOfPencilsSetAtCell(row: Int, column: Int) -> Int {
        
        var count = 0
        
        for i in 0 ..< 10 {
            if puzzle[row][column].pencils[i] == 1 {
                count += 1
            }
        }
        
        return count
    }
    
    
    // Is the value n penciled in?
    func isSetPencil(n: Int, row: Int, column: Int) -> Bool {
        
        // NSLog("row = \(row), col = \(column), n = \(n)")
        return (puzzle[row][column].pencils[n] == 1)
        
        
    }
    
    // Pencil the value n in.
    func setPencil(n: Int, row: Int, column: Int) {
        
        // NSLog("row = \(row), col = \(column)")
        
        puzzle[row][column].pencils[n] = 1
        
    }
    
    // Clear pencil value n.
    func clearPencil(n: Int, row: Int, column: Int) {
        puzzle[row][column].pencils[n] = 0
    }
    
    // Clear all penciled in values.
    func clearAllPencils(row: Int, column: Int) {
        
        for i in 0 ..< 10 {
            puzzle[row][column].pencils[i] = 0
        }
        
    }
    
    func clearAllConflictingCells() {
        
        for r in 0 ..< 9 {
            for c in 0 ..< 9 {
                if puzzle[r][c].isConflicting {
                    puzzle[r][c].number = 0
                }
            }
        }
    }

}
