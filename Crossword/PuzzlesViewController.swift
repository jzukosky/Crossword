//
//  ViewController.swift
//  Crossword
//
//  Created by Jonah Zukosky on 12/17/18.
//  Copyright © 2018 Zukosky, Jonah. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "puzzleCell")!
        cell.textLabel?.text = "Puzzle???"
        
        return cell
    }
    
    
}


