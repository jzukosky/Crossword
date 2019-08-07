//
//  ViewController.swift
//  Crossword
//
//  Created by Jonah Zukosky on 12/17/18.
//  Copyright © 2018 Zukosky, Jonah. All rights reserved.
//

import UIKit
import CoreData


class CrosswordsViewController: UIViewController {
    
    @IBOutlet weak var crosswordsTableView: UITableView!
    
    var crosswords = [Crossword]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "Crosswords"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //fetchCrosswords()
        crosswordsTableView.reloadData()
    }
    
    func alertNotifyUser(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel) {
                (alertAction) -> Void in
                print("Ok selected")
            })
        self.present(alert, animated: true, completion: nil)
    }
    
    func fetchCrosswords() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Crossword> = Crossword.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        // this orders the results by the crossword title ascending
        
        do {
            crosswords = try managedContext.fetch(fetchRequest)
        } catch {
            alertNotifyUser(message: "Could not fetch crosswords from Core Data")
            return
        }
        
        // if it doesn't work, it throws this alertnotifier out to the user.
    }
    
    func deleteCrossword(at indexPath: IndexPath) {
        let crossword = crosswords[indexPath.row]
        
        if let managedObjectContext = crossword.managedObjectContext {
        managedObjectContext.delete(crossword)
            
            do {
                try managedObjectContext.save()
                self.crosswords.remove(at: indexPath.row)
                crosswordsTableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                alertNotifyUser(message: "Could not delete")
                crosswordsTableView.reloadData()
            }
        }
    }
}

extension CrosswordsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return crosswords.count 
        
        //when core data begins working this should change to below, because if it were to be added now then there would be no way to access the puzzleview controller
        
        //return crosswords.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "crosswordCell", for: indexPath)
        if let cell = cell as? CrosswordTableViewCell {
            let crossword = crosswords[indexPath.row]
            cell.titleLabel.text = crossword.title
            cell.dateLabel.text = "This is the Date"
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PuzzleViewController,
        let segueIdentifier = segue.identifier, segueIdentifier == "existingCrossword",
        let row = crosswordsTableView.indexPathForSelectedRow?.row {
            destination.crossword = crosswords[row]
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteCrossword(at: indexPath)
        }
    }
}


