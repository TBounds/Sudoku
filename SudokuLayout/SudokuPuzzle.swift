//
//  SudokuPuzzle.swift
//  SudokuLayout
//
//  Created by Tyler James Bounds on 2/24/17.
//  Copyright © 2017 Tyler James Bounds. All rights reserved.
//

import Foundation

class SudokuPuzzle {
    
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
        
        let savedState = NSMutableArray(capacity: 9*9)
        
        for r in 0 ..< 9 {
            for c in 0 ..< 9 {
                let cell = puzzle[r][c]
                let cellDict : NSDictionary = ["pencils" : cell.pencils, "number" : cell.number, "isFixed" : cell.isFixed, "isConflicting" : cell.isConflicting]
                
                savedState.add(cellDict)
                
            }
        }
        
        return savedState
    }
    
    func sandboxArchivePath() -> String {
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        return dir.appendingPathComponent("sudokuPuzzle.plist")
    }
    
    // Read from plist compatible array.
    func setState(puzzleArray: NSArray) {
        
        let archiveName = sandboxArchivePath()
        if FileManager.default.fileExists(atPath: archiveName) {
            
            let saveState = NSMutableArray(contentsOfFile: archiveName)
            
            for r in 0 ..< 9 {
                for c in 0 ..< 9 {
                    puzzle[r][c].pencils = (saveState?[r*9 + c] as! NSDictionary).value(forKey: "pencils") as! [Int]
                    puzzle[r][c].number = (saveState?[r*9 + c] as! NSDictionary).value(forKey: "number") as! Int
                    puzzle[r][c].isFixed = (saveState?[r*9 + c] as! NSDictionary).value(forKey: "isFixed") as! Bool
                    puzzle[r][c].isConflicting = (saveState?[r*9 + c] as! NSDictionary).value(forKey: "isConflicting") as! Bool
                }
            }
        }
        
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
    func setNumber(number: Int, row: Int, column: Int) {
        
        puzzle[row][column].number = number
        
        
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
    
    // Checks each cell for a conflict.
    func checkPuzzleForConflicts() -> Bool {
        
        var conflict : Bool = false
        
        for r in 0 ..< 9 {
            for c in 0 ..< 9 {
                if !puzzle[r][c].isFixed {
                    if isConflictingEntryAtRow(row: r, column: c, number: puzzle[r][c].number) {
                        puzzle[r][c].isConflicting = true
                        conflict = true
                    }
                    else {
                        puzzle[r][c].isConflicting = false
                    }
                }
                
            }
        }
        
        return conflict
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

        return (puzzle[row][column].pencils[n] == 1)
        
        
    }
    
    // Pencil the value n in.
    func setPencil(n: Int, row: Int, column: Int) {
        
        puzzle[row][column].pencils[n] = 1
        
    }
    
    // Clear pencil value n.
    func clearPencil(n: Int, row: Int, column: Int) {
        puzzle[row][column].pencils[n] = 0
    }
    
    // Clear all penciled in values.
    func clearAllPencilsInCell(row: Int, column: Int) {
        
        for i in 0 ..< 10 {
            puzzle[row][column].pencils[i] = 0
        }
        
    }
    
    func clearAllPencilsInPuzzle() {
        
        for r in 0 ..< 9 {
            for c in 0 ..< 9 {
                if !puzzle[r][c].isFixed {
                    if anyPencilSetAtCell(row: r, column: c) {
                        clearAllPencilsInCell(row: r, column: c)
                    }
                }
            }
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
    
    func clearNonFixedValues() {
        
        for r in 0 ..< 9 {
            for c in 0 ..< 9 {
                if !puzzle[r][c].isFixed && puzzle[r][c].number != 0 {
                    puzzle[r][c].number = 0
                }
            }
        }
    }
    
    func checkIfPuzzleIsFilled() -> Bool {
        for r in 0 ..< 9 {
            for c in 0 ..< 9 {
                if puzzle[r][c].number == 0 {
                    return false
                }
            }
        }
        
        return true
    }

}
