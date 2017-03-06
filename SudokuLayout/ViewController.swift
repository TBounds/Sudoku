//
//  ViewController.swift
//  SudokuLayout
//
//  Created by Tyler James Bounds on 2/7/17.
//  Copyright © 2017 Tyler James Bounds. All rights reserved.
//



import UIKit

class ViewController: UIViewController {
    
    var pencilEnabled : Bool = false
    var gameWon : Bool = false
 
    @IBOutlet weak var puzzleView : PuzzleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tileSelected(_ sender: UIButton) {   // This should called numberSelected or something else.
        
        if puzzleView.selected.row != -1 && puzzleView.selected.column != -1  && !self.gameWon {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let puzzle = appDelegate.sudoku
            
            let tag = sender.tag
            let row = puzzleView.selected.row
            let col = puzzleView.selected.column
            
            NSLog("\(tag)")
            
            // Writing in pencils
            if(pencilEnabled && puzzle?.puzzle[row][col].number == 0) {
                
                if puzzle!.isSetPencil(n: sender.tag, row: row, column: col){
                    puzzle?.clearPencil(n: sender.tag, row: row, column: col)
                }
                else {
                    puzzle?.setPencil(n: sender.tag, row: puzzleView.selected.row, column: puzzleView.selected.column)
                }
              
                puzzleView.setNeedsDisplay()
            }
            
            // Writing in cell values
            if (!pencilEnabled && !(puzzle?.anyPencilSetAtCell(row: row, column: col))! ) {
                
                if tag == puzzle?.puzzle[row][col].number {
                    puzzle?.setNumber(number: 0, row: row, column: col)
                }
                else if puzzle?.puzzle[row][col].number == 0 {
                    puzzle?.setNumber(number: tag, row: row, column: col)
                }
                
                // Make sure there are no conflicts, no empty cells, and that the game had not already been won.
                if !(puzzle?.checkPuzzleForConflicts())! && (puzzle?.checkIfPuzzleIsFilled())! && !self.gameWon {
                    
                    self.gameWon = true
                    self.puzzleView.gameWon = true
                    
                    // XXX TODO: Add popup with options
                    let winController = UIAlertController(
                        title: "You Win!",
                        message: nil,
                        preferredStyle: .alert)
                    
                    winController.addAction(UIAlertAction(
                        title: "New Hard Game",
                        style: .default,
                        handler: { (UIAlertAction) -> Void in
                            
                            let confirmationController = UIAlertController(
                                title: "Starting a new hard game.",
                                message: "Are you sure?",
                                preferredStyle: .alert)
                            confirmationController.addAction(UIKit.UIAlertAction(
                                title: "Cancel",
                                style: .cancel,
                                handler: { (UIAlertAction) -> Void in
                                    self.present(winController, animated: true, completion: nil) }))
                            confirmationController.addAction(UIKit.UIAlertAction(
                                title: "Yes",
                                style: .default,
                                handler: { (UIAlertAction) -> Void in
                                    appDelegate.sudoku = SudokuPuzzle()
                                    // let puzzleStr = randomPuzzle(appDelegate.simplePuzzles)
                                    appDelegate.sudoku?.loadPuzzle(puzzleString: "hard")
                                    
                                    self.puzzleView.selected = (-1, -1)
                                    self.gameWon = false
                                    self.puzzleView.gameWon = false
                                    
                                    self.puzzleView.setNeedsDisplay() }))
                            
                            self.present(confirmationController, animated: true, completion: nil)
                    }))
                        
                    winController.addAction(UIAlertAction(
                        title: "New Easy game",
                        style: .default,
                        handler: { (UIAlertAction) -> Void in
                            
                            let confirmationController = UIAlertController(
                                title: "Starting a new easy game.",
                                message: "Are you sure?",
                                preferredStyle: .alert)
                            confirmationController.addAction(UIKit.UIAlertAction(
                                title: "Cancel",
                                style: .cancel,
                                handler: { (UIAlertAction) -> Void in
                                    self.present(winController, animated: true, completion: nil) }))
                            confirmationController.addAction(UIKit.UIAlertAction(
                                title: "Yes",
                                style: .default,
                                handler: { (UIAlertAction) -> Void in
                                    appDelegate.sudoku = SudokuPuzzle()
                                    // let puzzleStr = randomPuzzle(appDelegate.simplePuzzles)
                                    appDelegate.sudoku?.loadPuzzle(puzzleString: "simple")
                                    
                                    self.puzzleView.selected = (-1, -1)
                                    self.gameWon = false
                                    self.puzzleView.gameWon = false
                                    
                                    self.puzzleView.setNeedsDisplay() }))
                            
                            self.present(confirmationController, animated: true, completion: nil)
                    }))
                    
                    winController.addAction(UIAlertAction(
                        title: "Cancel",
                        style: .cancel,
                        handler: nil))
                    
                    self.present(winController, animated: true, completion: nil)

                }

                puzzleView.setNeedsDisplay()
                
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
            
            // Delete all pencils
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
            
            
            puzzle?.setNumber(number: 0, row: row, column: col)
            puzzle?.checkPuzzleForConflicts() // Used to update conflicting cells highlighting

            puzzleView.setNeedsDisplay()
            
        }
        
    }
    
    @IBAction func pencilSelected(_ sender: UIButton) {
        
        pencilEnabled = !pencilEnabled   // toggle
        sender.isSelected = pencilEnabled
    }

    //------------------------------------------------------------------------//
    //------------------------------- Menu UI --------------------------------//
    //------------------------------------------------------------------------//
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
        
        // New Easy Game
        alertController.addAction(UIAlertAction(
            title: "New Easy Game",
            style: .default,
            handler: { (UIAlertAction) -> Void in
                let confirmationController = UIAlertController(
                    title: "Starting a new easy game.",
                    message: "Are you sure?",
                    preferredStyle: .alert)
                confirmationController.addAction(UIKit.UIAlertAction(
                    title: "Cancel",
                    style: .cancel,
                    handler: nil))
                confirmationController.addAction(UIKit.UIAlertAction(
                    title: "Yes",
                    style: .default,
                    handler: { (UIAlertAction) -> Void in
                        appDelegate.sudoku = SudokuPuzzle()
                        // let puzzleStr = randomPuzzle(appDelegate.simplePuzzles)
                        appDelegate.sudoku?.loadPuzzle(puzzleString: "simple")

                        self.puzzleView.selected = (-1, -1)
                        self.gameWon = false
                        self.puzzleView.gameWon = false
                        
                        self.puzzleView.setNeedsDisplay() }))
                
                self.present(confirmationController, animated: true, completion: nil)
        }))
        
        // New Hard Game
        alertController.addAction(UIAlertAction(
            title: "New Hard Game",
            style: .default,
            handler: { (UIAlertAction) -> Void in
                
                let confirmationController = UIAlertController(
                    title: "Starting a new hard game.",
                    message: "Are you sure?",
                    preferredStyle: .alert)
                confirmationController.addAction(UIKit.UIAlertAction(
                    title: "Cancel",
                    style: .cancel,
                    handler: nil))
                confirmationController.addAction(UIKit.UIAlertAction(
                    title: "Yes",
                    style: .default,
                    handler: { (UIAlertAction) -> Void in
                        appDelegate.sudoku = SudokuPuzzle()
                        // let puzzleStr = randomPuzzle(appDelegate.simplePuzzles)
                        appDelegate.sudoku?.loadPuzzle(puzzleString: "hard")
                        
                        self.puzzleView.selected = (-1, -1)
                        self.gameWon = false
                        self.puzzleView.gameWon = false
                        
                        self.puzzleView.setNeedsDisplay() }))
                
                self.present(confirmationController, animated: true, completion: nil)
                
                
        }))
        
        if !self.gameWon {
            // Show Conflicting Cells
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
            
            // Clear Conflicting Cells
            alertController.addAction(UIAlertAction(
                title: "Clear All Conflicting Cells",
                style: .default,
                handler: { (UIAlertAction) -> Void in
                    
                    let confirmationController = UIAlertController(
                        title: "Clearing all conflicting cells.",
                        message: "Are you sure?",
                        preferredStyle: .alert)
                    confirmationController.addAction(UIKit.UIAlertAction(
                        title: "Cancel",
                        style: .cancel,
                        handler: nil))
                    confirmationController.addAction(UIKit.UIAlertAction(
                        title: "Yes",
                        style: .default,
                        handler: { (UIAlertAction) -> Void in
                            puzzle?.clearAllConflictingCells()
                            self.puzzleView.setNeedsDisplay() }))
                    
                    self.present(confirmationController, animated: true, completion: nil)
                    
            }))
            
            // Clear Pencils
            alertController.addAction(UIAlertAction(
                title: "Clear All Pencils",
                style: .default,
                handler: { (UIAlertAction) -> Void in
                    let confirmationController = UIAlertController(
                        title: "Clearing all pencils in puzzle.",
                        message: "Are you sure?",
                        preferredStyle: .alert)
                    confirmationController.addAction(UIKit.UIAlertAction(
                        title: "Cancel",
                        style: .cancel,
                        handler: nil))
                    confirmationController.addAction(UIKit.UIAlertAction(
                        title: "Yes",
                        style: .default,
                        handler: { (UIAlertAction) -> Void in
                            puzzle?.clearAllPencilsInPuzzle()
                            self.puzzleView.setNeedsDisplay() }))
                    
                    self.present(confirmationController, animated: true, completion: nil)
                    
            }))
            
            // Clear Non-Fixed Cells
            alertController.addAction(UIAlertAction(
                title: "Clear Non-Fixed Cells",
                style: .default,
                handler: { (UIAlertAction) -> Void in
                    let confirmationController = UIAlertController(
                        title: "Clearing all non-fixed cells in puzzle.",
                        message: "Are you sure?",
                        preferredStyle: .alert)
                    confirmationController.addAction(UIKit.UIAlertAction(
                        title: "Cancel",
                        style: .cancel,
                        handler: nil))
                    confirmationController.addAction(UIKit.UIAlertAction(
                        title: "Yes",
                        style: .default,
                        handler: { (UIAlertAction) -> Void in
                            puzzle?.clearNonFixedValues()
                            self.puzzleView.setNeedsDisplay() }))
                    
                    self.present(confirmationController, animated: true, completion: nil)
            }))
            
        }
        
            
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

