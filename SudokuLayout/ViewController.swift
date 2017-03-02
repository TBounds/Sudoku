//
//  ViewController.swift
//  SudokuLayout
//
//  Created by Tyler James Bounds on 2/7/17.
//  Copyright © 2017 Tyler James Bounds. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var pencilEnabled : Bool = false  // controller property
    
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
        
        if puzzleView.selected.row != -1 && puzzleView.selected.column != -1 {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let puzzle = appDelegate.sudoku
            
            let tag = sender.tag
            let row = puzzleView.selected.row
            let col = puzzleView.selected.column
            
            NSLog("\(tag)")
            
            if(pencilEnabled) {
                
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
            
            if (!pencilEnabled) {
                let conflict = puzzle?.setNumber(number: tag, row: row, column: col)
                if  conflict == .newConflict {
                    puzzleView.conflictingCellsCount += 1
                }
                else if conflict == .removedConflict {
                    puzzleView.conflictingCellsCount -= 1
                }
                puzzleView.setNeedsDisplay()
                
                NSLog("# of conflicting cells = \(puzzleView.conflictingCellsCount)")
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
                                puzzle!.clearAllPencils(row: row, column: col)
                                self.puzzleView.setNeedsDisplay() }))
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        // Deletes cell value
        else if !pencilEnabled && puzzleView.selected.row != -1 && puzzleView.selected.column != -1 {
            
            let conflict = puzzle?.setNumber(number: 0, row: row, column: col)
            
            if conflict == .removedConflict {
                puzzleView.conflictingCellsCount -= 1
            }
            puzzleView.setNeedsDisplay()
            
            NSLog("# of conflicting cells = \(puzzleView.conflictingCellsCount)")
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
                appDelegate.sudoku?.loadPuzzle(puzzleString: "simple")
                // self.selectFirstAvailableCell()
                self.puzzleView.setNeedsDisplay()}))
        alertController.addAction(UIAlertAction(
            title: "New Hard Game",
            style: .default,
            handler: { (UIAlertAction) -> Void in
                appDelegate.sudoku = SudokuPuzzle()
                // let puzzleStr = randomPuzzle(appDelegate.simplePuzzles)
                appDelegate.sudoku?.loadPuzzle(puzzleString: "hard")
                // self.selectFirstAvailableCell()
                self.puzzleView.setNeedsDisplay()}))
        if !puzzleView.showConflictingCells {
            alertController.addAction(UIAlertAction(
                title: "Show Conflicting Cells",
                style: .default,
                handler: { (UIAlertAction) -> Void in
                    self.puzzleView.showConflictingCells = true
                    self.puzzleView.setNeedsDisplay()}))
        }
        else {
            alertController.addAction(UIAlertAction(
                title: "Hide Conflicting Cells",
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

