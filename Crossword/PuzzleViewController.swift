//
//  PuzzleViewController.swift
//  Crossword
//
//  Created by Jonah Zukosky on 12/17/18.
//  Copyright © 2018 Zukosky, Jonah. All rights reserved.
//




//TODO: each time you enter in a letter, it saves to core data
//TODO: publish button to finalize


import UIKit
import CoreData

class PuzzleViewController: UIViewController {

    let LABEL_TAG_CONSTANT = 1000
    let BLANK_CHARACTER = "\u{200B}"
    
    var blocking = false
    var horizontal = true
    
    var currentHighlightedRow = 0
    var currentHighlightedColumn = 0
    
    @IBOutlet weak var puzzleContainerView: UIView!
    @IBOutlet weak var containerContainerView: UIView!
    
    @IBOutlet weak var navigationTitleTextField: UINavigationItem!
    
    var scrollView: UIScrollView!
    
    let fakeTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    let cellTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
    
    
    var currentCoords = (0,0)
    var lastSelectedView = UIView()
    
    
    var cellsArray = [[(UIView,UILabel)]]()
    var crossword: Crossword?
    
    var cellNumberArray = [[UILabel]]()
    var clues = [Clue]()
    var dimensions = 0
    
    var clueCount = 1
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    //Anything between these comments is for getting saving to work only, not saving the crossword itself.
        
    
    //
    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: Make this variable?
        dimensions = 15
        createToolbar()
        
        
        let recognizer = UITapGestureRecognizer(target: self,
                                                action:#selector(handleTap(recognizer:)))
        
        createGrid(with: recognizer)
        //createClues()
       // let cellWidth = puzzleContainerView.frame.width / CGFloat(dimensions)
        let cellWidth = UIScreen.main.bounds.width / CGFloat(dimensions)
        let mainLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        mainLabel.tag = -3
        cellNumberArray = Array(repeating: Array(repeating: mainLabel, count: dimensions), count: dimensions)
        
        for j in 0..<dimensions {
            for i in 0..<dimensions {
                cellNumberArray[i][j] = UILabel(frame: CGRect(x: CGFloat(i)*cellWidth + 0.7, y: CGFloat(j)*cellWidth + 0.5, width: cellWidth, height: cellWidth/4))
                cellNumberArray[i][j].font = cellNumberArray[i][j].font.withSize(5.0)
                puzzleContainerView.addSubview(cellNumberArray[i][j])
            }
        }
        updateNumbers()
        
        fakeTextField.delegate = self
        fakeTextField.text = BLANK_CHARACTER
        fakeTextField.autocorrectionType = .no
        fakeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        view.addSubview(fakeTextField)
        
        
        /* SCROLL VIEW CHANGES */
        
//        scrollView = UIScrollView(frame: view.bounds)
//        scrollView = UIScrollView()
//        view.addSubview(scrollView)
//        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0).isActive = true
//        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true
//        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0).isActive = true
//        scrollView.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0))

        //scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0).isActive = true
        
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.addGestureRecognizer(recognizer)
//        scrollView.contentSize = puzzleContainerView.bounds.size
//
//        scrollView.minimumZoomScale = 1.0
//        scrollView.maximumZoomScale = 3.0
//        scrollView.delegate = self
//
//        scrollView.addSubview(puzzleContainerView)
        puzzleContainerView.addGestureRecognizer(recognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fakeTextField.becomeFirstResponder()
    }
    
    
    /*
        Creates the actual ui for the grid.
        It does this by creating a 2d array of Tuples,
        each consisting of a View (The background of the cell), and a Label (The Letter)
        This is all stored in a global cellsArray variable.
     
        Do I have to have to make a change to the custom class in Core Data?
     */
    func createGrid(with recognizer: UITapGestureRecognizer) {
        // let cellWidth = puzzleContainerView.frame.width / CGFloat(dimensions)
        let cellWidth = UIScreen.main.bounds.width / CGFloat(dimensions)
        var cellCount = 0
        
        let mainView = UIView()
        mainView.tag = -1
        let mainLabel = UILabel(frame: CGRect(x: 0, y: 0, width: cellWidth, height: cellWidth/4))
        mainLabel.tag = -2
        
        cellsArray = Array(repeating: Array(repeating: (mainView,mainLabel), count: dimensions), count: dimensions)
        
        for j in 0..<dimensions {
            for i in 0..<dimensions {
                cellCount += 1
                
                let letterView = UIView()
                puzzleContainerView.addSubview(letterView)
                
                letterView.frame = CGRect(x: CGFloat(i)*cellWidth, y: CGFloat(j)*cellWidth, width: cellWidth, height: cellWidth)
                let textLabel = UILabel(frame: CGRect(x: CGFloat(i)*cellWidth, y: CGFloat(j)*cellWidth, width: cellWidth, height: cellWidth))
                
                puzzleContainerView.addSubview(textLabel)
                textLabel.textAlignment = .center
                textLabel.text = BLANK_CHARACTER
                textLabel.font = textLabel.font.withSize(cellWidth/3)
                letterView.layer.borderWidth = 0.2
                letterView.layer.borderColor = UIColor.black.cgColor
                
                cellsArray[i][j] = (letterView, textLabel)
            }
        }
    }
    
//    func createClues() {
//        let tempClue = Clue.init(startingLocation: nil, clueNumber: -1, orientation: .horizontal, clue: nil, answer: nil)
//        clues = Array(repeating: tempClue, count: dimensions*dimensions)
//    }
    
    /*
     
     */
    @objc func updateNumbers() {
        
        var previousCellWasBlack = false
        clueCount = 1
        
        
        for j in 0..<dimensions {
            for i in 0..<dimensions {
                let cell = cellsArray[i][j]
                //print(cell.1.text)

//                let numberLabel = cellNumberArray[i][j]
//
//                if numberLabel.tag != -3 {
//
//                    continue
//                }
                
                if cell.0.backgroundColor == .black {
                    //print("previous cell was black")
                    previousCellWasBlack = true
                    continue
                }
                
                
                
                if previousCellWasBlack || j-1 < 0 || i-1 < 0 || cellsArray[i][j-1].0.backgroundColor == .black {
//                    if let viewToBeRemoved = puzzleContainerView.viewWithTag(clueCount) {
//                        print("Removing subview")
//                        viewToBeRemoved.removeFromSuperview()
//                    }
                    
                    print("setting label")
                    //let newLabel = UILabel(frame: CGRect(x: CGFloat(i)*cellWidth + 0.7, y: CGFloat(j)*cellWidth + 0.5, width: cellWidth, height: cellWidth/4))
                    //puzzleContainerView.addSubview(newLabel)
                    //newLabel.text = String(clueCount)
                    //newLabel.font = newLabel.font.withSize(5)
                    //newLabel.tag = clueCount
                    //cellNumberArray[i][j].removeFromSuperview()
                    cellNumberArray[i][j].text = ""
                    cellNumberArray[i][j].text = String(clueCount)
                    cellNumberArray[i][j].tag = clueCount
                    
//                    cellNumberArray[i][j].frame = CGRect(x: CGFloat(i)*cellWidth + 0.7, y: CGFloat(j)*cellWidth + 0.5, width: cellWidth, height: cellWidth/4)
//                    cellNumberArray[i][j].setNeedsLayout()
//                    cellNumberArray[i][j].layoutIfNeeded()
                    //cellNumberArray[i][j] = newLabel
                    var currentClue: Clue?
                    for clue in clues {
                        if clue.clueNumber == clueCount {
                            currentClue = clue
                            break
                        }
                    }
        
                    if (previousCellWasBlack || i-1 < 0) && (j-1 < 0 || cellsArray[i][j-1].0.backgroundColor == .black) {
                        //Both Horizontal and Vertical: Two Clues
                        //print("Horizontal and Vertical Clue? ", terminator: "\n")
                        //Check if previous clue already exists at position, if not:
                        
                        
                        
                    } else if previousCellWasBlack || i-1 < 0 {
                        //Horizontal Clue Only
                        //print("Horizontal Clue? ", terminator: "\n")
                        //Check if previous clue already exists at position
                        
                        if let existingClue = currentClue {
                            
                        }
                        
                        
                    } else {
                        //Vertical Clue Only
                        //print("Vertical Clue?\n")
                        //Check if previous clue already exists at position
                        
                    }
                    
                    
                    clueCount += 1
                    previousCellWasBlack = false
                    continue
                } else {
                    cellNumberArray[i][j].text = ""
                }
                
                
            }
        }
        
        print(clues)
    }
    
    /*
        Handles Taps on Cells
         - First gets location of tap on screen
            - Gets the cell number from location using some weird math
         - 2 Branches: If blocking is on or off
            - if blocking:
                - Get cell from cellsArray, swap the color, and update numbers
            - if not blocking:
                - Checks if cell is already selected. If so, swaps the direction
                - If not selected, selects the cell and updates highlighted colors (the blue)
     */
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: puzzleContainerView)
        
        let width = view.frame.width / CGFloat(dimensions)
        let i = Int(location.x / width)
        let j = Int(location.y / width)
        
        print("X:\(i)\nY: \(j)\n")
        if i > dimensions-1 || j > dimensions-1 { return }
        
        if !blocking {
            if cellsArray[i][j].0.backgroundColor != .black {
                if (i,j) == currentCoords {
                    toggleDirection()
                } else {
                    
                    updateCell(to: (i,j), from: currentCoords)
                    highlightRows()
                }
            }
        } else {
            let cellView = cellsArray[i][j]
            if cellView.0.backgroundColor != .black {
                cellView.1.text = "\u{200B}"
                cellView.0.backgroundColor = .black
                addRotationalSymmetry(i,j)
            } else {
                cellView.0.backgroundColor = .white
            
                if i != dimensions/2 || j != dimensions/2 {
                    addRotationalSymmetry(i,j)
                }
            }
            updateNumbers()
        }
        
    }
    
    
    /*
        Handles adding block to match the user added one
        to satisfy rotational symmetry. Should be made optional eventually
     */
    func addRotationalSymmetry(_ i: Int,_ j: Int) {
        let inverseCellView = cellsArray[dimensions-1-i][dimensions-1-j]
        print(i,j)
        print(dimensions-1-i,dimensions-1-j)
        if inverseCellView != cellsArray[i][j] {
            if inverseCellView.0.backgroundColor != .black {
                print("setting black not equal")
                inverseCellView.0.backgroundColor = .black
            } else {
                print("setting white")
                inverseCellView.0.backgroundColor = .white
            }
        }else {
            print("setting black")
            inverseCellView.0.backgroundColor = .black
        }
    }
    
    /*
        Handles logic for placing the blue selector on the grid.
        Checks to see if the cell is a block, if so doesn't place.
        Then resets the previous cell (sometimes you have to skip over a block)
        to the correct color.
     
        updates global variables and highlights the rows.
     
     */
    func updateCell(to newCell: (Int,Int),from lastSelectedCell: (Int,Int)) {
        
        if cellsArray[newCell.0][newCell.1].0.backgroundColor != .black {
            if horizontal {
                if newCell.1 == currentCoords.1 && cellsArray[lastSelectedCell.0][lastSelectedCell.1].0.backgroundColor != .black {
                    cellsArray[lastSelectedCell.0][lastSelectedCell.1].0.backgroundColor = .yellow
                } else {
                    highlightRows()
                }
            } else {
                if newCell.0 == currentCoords.0 && cellsArray[lastSelectedCell.0][lastSelectedCell.1].0.backgroundColor != .black {
                    cellsArray[lastSelectedCell.0][lastSelectedCell.1].0.backgroundColor = .yellow
                } else {
                    highlightRows()
                }
            }
            
            
            if cellsArray[lastSelectedCell.0][lastSelectedCell.1].0.backgroundColor != .black
                && cellsArray[lastSelectedCell.0][lastSelectedCell.1].0.backgroundColor != .yellow{
                print("Last View: \(lastSelectedCell)")
                print("New View: \(newCell)")
                cellsArray[lastSelectedCell.0][lastSelectedCell.1].0.backgroundColor = .white
                
            }
            
            currentCoords = newCell
            cellsArray[currentCoords.0][currentCoords.1].0.backgroundColor = .blue
            highlightRows()
        }

    }
    
    /*
        Handles calling updateCell from the keyboard via backspace.
        Specifically checks to see if we need to skip cell(s) to get
        to a valid location for the selector. Calls itself recursively
        if it encounters a block that it needs to move over. Then updates cells
     */
    func moveCellandLabel(to newCoords: (Int,Int)) {
        let newCell = cellsArray[newCoords.0][newCoords.1]
        
        if newCell.0.backgroundColor == .black {
            if cellsArray[currentCoords.0][currentCoords.1].0.backgroundColor != .black {
                cellsArray[currentCoords.0][currentCoords.1].0.backgroundColor = .white
            }
            
            let newerCoords = iterateCoords(currentI: newCoords.0,currentJ: newCoords.1)
            currentCoords = newCoords

            moveCellandLabel(to: newerCoords)
        } else {
            print("Move successful, calling update")
            updateCell(to: newCoords, from: currentCoords)
        }
    }
    
    /*
        Helper function for moveCellandLabel. Handles moving coords to next cell
        because the logic around wrapping lines got lengthy.
     
        Basically checks to see if we're at the end of a line and need to move to
        the next row/column
     */
    func iterateCoords(currentI: Int, currentJ: Int) -> (Int,Int) {
        let currentX = currentI
        let currentY = currentJ
        let lineLimit = dimensions-1
        
        if horizontal {
            if currentX < lineLimit {
                return (currentX+1, currentY)
            } else if currentY < lineLimit {
                unhighlightRows()
                return (0,currentY+1)
            } else {
                return (0,0)
            }
        } else {
            if currentY < lineLimit {
                return (currentX, currentY+1)
            } else if currentX < lineLimit {
                unhighlightRows()
                return (currentX+1,0)
            } else {
                unhighlightRows()
                return (0,0)
            }
        }
        
    }
    
    /*
        Wow this is the exact same as iterateCoords thats dumb Jonah
        This should be consolidated into iterateCoords and there should
        be a flag paramter added to determine if we're iterating or deiterating.
     */
    func deiterateCoords(currentI: Int, currentJ: Int) -> (Int,Int) {
        let currentX = currentI
        let currentY = currentJ
        
        if horizontal {
            if currentX > 0 {
                return (currentX-1, currentY)
            } else if currentY > 0 {
                unhighlightRows()
                return (14,currentY-1)
            } else {
                return (0,0)
            }
        } else {
            if currentY > 0 {
                return (currentX, currentY-1)
            } else if currentX > 0 {
                return (currentX-1,14)
            } else {
                unhighlightRows()
                return (0,0)
            }
        }
        
    }
    
    /*
        Unhighlights all the yellow.
        Does so by getting the current column/row and iterating through it resetting colors
     */
    func unhighlightRows() {
        
        if !horizontal {
            for x in 0...dimensions-1 {
                let cell = cellsArray[currentHighlightedColumn][x]
                if cell.0.backgroundColor != .black && cell.0.backgroundColor != .blue {
                    cell.0.backgroundColor = .white
                }
            }
        } else {
            for x in 0...dimensions-1 {
                let cell = cellsArray[x][currentHighlightedRow]
                if cell.0.backgroundColor != .black && cell.0.backgroundColor != .blue {
                    cell.0.backgroundColor = .white
                }
            }
        }
    }
    
    /*
        Unhighlights previous row, then highlights current row
     */
    func highlightRows() {
        unhighlightRows()
        let i = currentCoords.0
        let j = currentCoords.1
        
        if !horizontal {
            for x in 0...dimensions-1 {
                let cell = cellsArray[i][x]
                if cell.0.backgroundColor != .blue && cell.0.backgroundColor != .black {
                    cell.0.backgroundColor = .yellow
                }
            }
            currentHighlightedColumn = i
        } else {
            for x in 0...dimensions-1 {
                let cell = cellsArray[x][j]
                if cell.0.backgroundColor != .blue && cell.0.backgroundColor != .black {
                    cell.0.backgroundColor = .yellow
                }
            }
            currentHighlightedRow = j
        }
        
    }
    
    
    //MARK: - Core Data
    
    
    //Dale Musser https://github.com/TechInnovator
    func alertNotifyUser(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func savePuzzle(_ sender: Any) {
        
        for item in cellsArray {
            print("Found \(item)")
        }
        
        guard let title = navigationTitleTextField.title?.trimmingCharacters(in: .whitespaces), !title.isEmpty else {
            alertNotifyUser(message: "Please enter a title before saving your puzzle.")
            return
        }
        
        if let crossword = crossword {
            crossword.title = title
            crossword!.
            crossword.stringsArray = cellsArray
        } else {
            crossword = Crossword(title: title, clue: clues, stringsArray: cellsArray)
        }
        
    }

    func convertPuzzleForCoreData() {
        
    }

}

extension PuzzleViewController: UITextFieldDelegate {
    
    /*
        This is a weird requirement to basically make sure that labels are the correct size when "empty"
     */
    @objc func textFieldDidChange(_ textField: UITextField) {
        print("textFieldDidChange")
        textField.text = BLANK_CHARACTER
    }
    
    /*
        Changes Letter text and iterates the cell selector.
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.text = BLANK_CHARACTER
        
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        let label = cellsArray[currentCoords.0][currentCoords.1].1
        
        if !blocking {
            
            if isBackSpace != -92 {
                let newCoords = iterateCoords(currentI: currentCoords.0, currentJ: currentCoords.1)
                label.text = string.uppercased()
                print(char)
                moveCellandLabel(to: newCoords)
            } else {
                if let text = label.text {
                    if text == BLANK_CHARACTER || text.isEmpty {
                        moveCellandLabel(to: deiterateCoords(currentI: currentCoords.0, currentJ: currentCoords.1))
                    } else {
                        label.text = ""
                    }
                }
            }
        }
        
        
        return true
    }
    
}
//MARK: - Keyboard Toolbar
extension PuzzleViewController {
    
    /*
        Creates the UI for the toolbar above the keyboard.
        This should eventually be more flushed out/have some stuff removed to go elsewhere
     */
    func createToolbar() {
        
        numberToolbar.barStyle = .default
        numberToolbar.items = [
            UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goToPreviousClue)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Block", style: .plain, target: self, action: #selector(toggleBlocking)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Forward", style: .plain, target: self, action: #selector(goToNextClue))]
        numberToolbar.sizeToFit()
        fakeTextField.inputAccessoryView = nil
        fakeTextField.inputAccessoryView = numberToolbar
    }
    
    /*
        idk why this is an @objc func but it toggles the direction
        when the currently selected cell is selected again.
     */
    @objc func toggleDirection() {
        unhighlightRows()
        horizontal = !horizontal
        highlightRows()
    }
    
    /*
        Handles the blocking button in the toolbar.
        Basically changes a flag and resets cell colors.
     */
    @objc func toggleBlocking() {
        blocking = !blocking
        if blocking {
            unhighlightRows()
            cellsArray[currentCoords.0][currentCoords.1].0.backgroundColor = .white
            numberToolbar.items?[2].title = "Done"
        } else {
            numberToolbar.items?[2].title = "Block"
        }
    }
    
    @objc func goToPreviousClue() {
        // TODO: Implement
    }
    
    @objc func goToNextClue() {
        // TODO: Implement
    }
}

/*
    None of this is getting used rn cause the scroll view is FUCKY
 */
extension PuzzleViewController: UIScrollViewDelegate {
    
    /*
     
     */
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        scrollView.setZoomScale(1.0, animated: true)
    }
    
    /*
     
     */
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        print("viewForZoomingIn")

        return self.puzzleContainerView
    }
    
    /*
     
     */
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print("scrollViewDidZoom")
        if scrollView.zoomScale < 1.0 {
            scrollView.zoomScale = 1.0
        }
    }
}
