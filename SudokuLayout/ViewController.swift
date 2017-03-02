//
//  ViewController.swift
//  SudokuLayout
//
//  Created by Tyler James Bounds on 2/7/17.
//  Copyright © 2017 Tyler James Bounds. All rights reserved.
//



import UIKit

class ViewController: UIViewController {
    
    let MAX_NUM_CELLS = 81

    var pencilEnabled : Bool = false
    var remainingOpenCells: Int = 81
    
    
    @IBOutlet weak var puzzleView : PuzzleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let puzzle = appDelegate.sudoku
        
        // Set the remainOpenCells after the puzzle loads
        remainingOpenCells -= (puzzle?.cellsUsedOnLoad)!
        
        NSLog("remainingCells = \(remainingOpenCells)")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tileSelected(_ sender: UIButton) {   // This should called numberSelected or something else.
        
        if puzzleView.selected.row != -1 && puzzleView.selected.column != -1 {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let puzzle = appDelegate.sudoku
            
            let tag = sender.tag
            let row = puzzleView.selected.row
            let col = puzzleView.selected.column
            
            NSLog("\(tag)")
            
            // Writing in pencils
            if(pencilEnabled && puzzle?.puzzle[row][col].number == 0) {
                
                NSLog("cell = \(puzzleView.selected)")
                
                if puzzle!.isSetPencil(n: sender.tag, row: row, column: col){
                    puzzle?.clearPencil(n: sender.tag, row: row, column: col)
                }
                else {
                    puzzle?.setPencil(n: sender.tag, row: puzzleView.selected.row, column: puzzleView.selected.column)
                }
                
                
                NSLog("pencil values = \(puzzle?.puzzle[row][col].pencils)")
                
                puzzleView.setNeedsDisplay()
            }
            // Writing in cell values
            if (!pencilEnabled && !(puzzle?.anyPencilSetAtCell(row: row, column: col))! ) {
                
                if puzzle?.puzzle[row][col].number == 0 {
                    self.remainingOpenCells -= 1
                }
                
                if tag == puzzle?.puzzle[row][col].number {
                    puzzle?.setNumber(number: 0, row: row, column: col)
                }
                else if puzzle?.puzzle[row][col].number == 0 {
                    puzzle?.setNumber(number: tag, row: row, column: col)
                }
                
                if !(puzzle?.checkPuzzleForConflicts())! && remainingOpenCells == 0 {
                    NSLog("you win")
                    // XXX TODO: Add popup with options
                }

                puzzleView.setNeedsDisplay()

                NSLog("# of remaining cells = \(remainingOpenCells)")
            }
        }
        
    }
    
    
    @IBAction func deleteSelected(_ sender: UIButton) {
        NSLog("\(sender.tag)")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let puzzle = appDelegate.sudoku
        
        let row = puzzleView.selected.row
        let col = puzzleView.selected.column
        
        if pencilEnabled && puzzle!.anyPencilSetAtCell(row: row, column: col){
            
            // Detete all pencils
            let alertController = UIAlertController(
                            title: "Deleting all penciled in values.",
                            message: "Are you sure?",
                            preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(
                            title: "Cancel",
                            style: .cancel,
                            handler: nil))
                        alertController.addAction(UIAlertAction(
                            title: "Okay",
                            style: .default,
                            handler: { (UIAlertAction) -> Void in
                                puzzle!.clearAllPencilsInCell(row: row, column: col)
                                self.puzzleView.setNeedsDisplay() }))
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        // Deletes cell value
        else if !pencilEnabled && puzzleView.selected.row != -1 && puzzleView.selected.column != -1 {
            
            if puzzle?.puzzle[row][col].number != 0 {
                self.remainingOpenCells += 1
            }
            
            puzzle?.setNumber(number: 0, row: row, column: col)
            puzzle?.checkPuzzleForConflicts()

            puzzleView.setNeedsDisplay()
            
            NSLog("# of remaining cells = \(remainingOpenCells)")
        }
        
    }
    
    @IBAction func pencilSelected(_ sender: UIButton) {
        NSLog("\(sender.tag)")
        
        pencilEnabled = !pencilEnabled   // toggle
        sender.isSelected = pencilEnabled
    }

    @IBAction func mainMenu(sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let puzzle = appDelegate.sudoku
        
        let alertController = UIAlertController(
            title: "Main Menu",
            message: nil,
            preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil))
        alertController.addAction(UIAlertAction(
            title: "New Easy Game",
            style: .default,
            handler: { (UIAlertAction) -> Void in
                appDelegate.sudoku = SudokuPuzzle()
                // let puzzleStr = randomPuzzle(appDelegate.simplePuzzles)
                let cellsUsed = (appDelegate.sudoku?.loadPuzzle(puzzleString: "simple"))
                self.remainingOpenCells = self.MAX_NUM_CELLS - cellsUsed!
                
                NSLog("remainingCells = \(self.remainingOpenCells)") // DEBUG
                
                self.puzzleView.selected = (-1, -1)
                self.puzzleView.setNeedsDisplay()}))
        alertController.addAction(UIAlertAction(
            title: "New Hard Game",
            style: .default,
            handler: { (UIAlertAction) -> Void in
                appDelegate.sudoku = SudokuPuzzle()
                // let puzzleStr = randomPuzzle(appDelegate.simplePuzzles)
                let cellsUsed = appDelegate.sudoku?.loadPuzzle(puzzleString: "hard")
                self.remainingOpenCells = self.MAX_NUM_CELLS - cellsUsed!
                
                NSLog("remainingCells = \(self.remainingOpenCells)") // DEBUG
                
                self.puzzleView.selected = (-1, -1)
                self.puzzleView.setNeedsDisplay()}))
        if !puzzleView.showConflictingCells {
            alertController.addAction(UIAlertAction(
                title: "Highlight Conflicting Cells",
                style: .default,
                handler: { (UIAlertAction) -> Void in
                    self.puzzleView.showConflictingCells = true
                    self.puzzleView.setNeedsDisplay()}))
        }
        else {
            alertController.addAction(UIAlertAction(
                title: "Unhighlight Conflicting Cells",
                style: .default,
                handler: { (UIAlertAction) -> Void in
                    self.puzzleView.showConflictingCells = false
                    self.puzzleView.setNeedsDisplay()}))
        }
        alertController.addAction(UIAlertAction(
            title: "Clear All Conflicting Cells",
            style: .default,
            handler: { (UIAlertAction) -> Void in
                puzzle?.clearAllConflictingCells()
                self.puzzleView.setNeedsDisplay()}))
        alertController.addAction(UIAlertAction(
            title: "Clear All Pencils",
            style: .default,
            handler: { (UIAlertAction) -> Void in
                puzzle?.clearAllPencilsInPuzzle()
                self.puzzleView.setNeedsDisplay()}))
        
            
        //     ... add other actions ...
//        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
//            let popoverPresenter = alertController.popoverPresentationController
//            let menuButtonTag = 12
//            let menuButton = buttonsView.viewWithTag(menuButtonTag)
//            popoverPresenter?.sourceView = menuButton
//            popoverPresenter?.sourceRect = (menuButton?.bounds)!
//        }
        self.present(alertController, animated: true, completion: nil)
    }
}

