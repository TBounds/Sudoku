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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tileSelected(_ sender: UIButton) {
        //let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        //let board = AppDelegate.board
        
        NSLog("\(sender.tag)")
        
    }
    
    
    @IBAction func deleteSelected(_ sender: UIButton) {
        NSLog("\(sender.tag)")
    }
    
    @IBAction func pencilSelected(_ sender: UIButton) {
        NSLog("\(sender.tag)")
        
        pencilEnabled = !pencilEnabled   // toggle
        sender.isSelected = pencilEnabled
    }

    @IBAction func menuSelected(_ sender: UIButton) {
        NSLog("\(sender.tag)")
    }
}

