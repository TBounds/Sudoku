//
//  AppDelegate.swift
//  SudokuLayout
//
//  Created by Tyler James Bounds on 2/7/17.
//  Copyright © 2017 Tyler James Bounds. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var sudoku : SudokuPuzzle?
    
    func sandboxArchivePath() -> String {
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        return dir.appendingPathComponent("sudokuPuzzle.plist")
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.sudoku = SudokuPuzzle()
        
        // Load puzzle from sandbox. XXX TODO
        let archiveName = sandboxArchivePath()
        if FileManager.default.fileExists(atPath: archiveName) {
            
            NSLog("Loading puzzle.")
            
            let saveState = NSArray(contentsOfFile: archiveName)
            self.sudoku?.setState(puzzleArray: saveState! as NSArray)
        }
        else {
            NSLog("New simple puzzle")
            self.sudoku!.loadPuzzle(puzzleString: "simple") // Load new simple puzzle

        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
       
        self.sudoku = SudokuPuzzle()

        let archiveName = sandboxArchivePath()
        let saveState : NSArray = (self.sudoku?.savedState())!
        
        saveState.write(toFile: archiveName, atomically : true)

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

