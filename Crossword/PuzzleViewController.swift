//
//  PuzzleViewController.swift
//  Crossword
//
//  Created by Jonah Zukosky on 12/17/18.
//  Copyright © 2018 Zukosky, Jonah. All rights reserved.
//

import UIKit

class PuzzleViewController: UIViewController {

    let LABEL_TAG_CONSTANT = 1000
    let BLANK_CHARACTER = "\u{200B}"
    
    var blocking = false
    var horizontal = true
    
    var currentHighlightedRow = 0
    var currentHighlightedColumn = 0
    
    @IBOutlet weak var puzzleContainerView: UIView!
    @IBOutlet weak var containerContainerView: UIView!
    var scrollView: UIScrollView!
    
    let fakeTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    let cellTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
    
    
    var currentCoords = (0,0)
    var lastSelectedView = UIView()
    
    
    var cellsArray = [[(UIView,UILabel)]]()
    var cellNumberArray = [[UILabel]]()
    var dimensions = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: Make this variable?
        dimensions = 15
        createToolbar()
        
        
        let recognizer = UITapGestureRecognizer(target: self,
                                                action:#selector(handleTap(recognizer:)))
        
        createGrid(with: recognizer)
        
        
        fakeTextField.delegate = self
        fakeTextField.text = BLANK_CHARACTER
        fakeTextField.autocorrectionType = .no
        fakeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        view.addSubview(fakeTextField)
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.addGestureRecognizer(recognizer)
        scrollView.contentSize = puzzleContainerView.bounds.size
        //scrollView.backgroundColor = UIColor.lightGray
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.delegate = self
        
        scrollView.addSubview(puzzleContainerView)
        view.addSubview(scrollView)
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fakeTextField.becomeFirstResponder()
    }
    
    
    
    func createGrid(with recognizer: UITapGestureRecognizer) {
        let cellWidth = puzzleContainerView.frame.width / CGFloat(dimensions)
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
                //textLabel.text = String(cellCount)
                
                letterView.tag = cellCount
                textLabel.tag = cellCount + LABEL_TAG_CONSTANT
                
                textLabel.font = textLabel.font.withSize(9)
                letterView.layer.borderWidth = 0.2
                letterView.layer.borderColor = UIColor.black.cgColor
                
                cellsArray[i][j] = (letterView, textLabel)
                
                
                
            }
        }
        
        //puzzleContainerView.addGestureRecognizer(recognizer)
    }
    
    @objc func updateNumbers() {
        
        let cellWidth = puzzleContainerView.frame.width / CGFloat(dimensions)
        let mainLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        mainLabel.tag = -3
        cellNumberArray = Array(repeating: Array(repeating: mainLabel, count: dimensions), count: dimensions)
        
        var previousCellWasBlack = false
        var count = 1
        
        for j in 0..<dimensions {
            for i in 0..<dimensions {
                let cell = cellsArray[i][j]
                //print(cell.1.text)
                let numberLabel = cellNumberArray[i][j]
                
                if numberLabel.tag != -3 {
                    continue
                }
                
                if cell.0.backgroundColor == .black {
                    //print("previous cell was black")
                    previousCellWasBlack = true
                    continue
                }
                
                
                if previousCellWasBlack || j-1 < 0 || i-1 < 0 || cellsArray[i][j-1].0.backgroundColor == .black {
                    //print("adding number \(count)")
                    let newLabel = UILabel(frame: CGRect(x: CGFloat(i)*cellWidth + 0.7, y: CGFloat(j)*cellWidth + 0.5, width: cellWidth, height: cellWidth/4))
                    self.view.addSubview(newLabel)
//                    puzzleContainerView.addSubview(newLabel)
                    //let newLabel = UILabel(frame: CGRect(x: 0.7, y: 0.7, width: cellWidth, height: cellWidth/4))
                    newLabel.text = String(count)
                    newLabel.textAlignment = .center
                    print(newLabel.text)
                    newLabel.font = newLabel.font.withSize(5)
                    //newLabel.backgroundColor = .red
                    
                    //cell.0.addSubview(newLabel)
                    cellNumberArray[i][j] = newLabel
                    
                    //cell.1.text = String(count)
                    
                    count += 1
                    previousCellWasBlack = false
                    continue
                }
                
                
            }
            //print()
        }
    }
    
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
            // unhighlightRows()
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
    
    func updateCell(to newCell: (Int,Int),from lastSelectedCell: (Int,Int)) {
        
        if cellsArray[newCell.0][newCell.1].0.backgroundColor != .black {
            if horizontal {
                if newCell.1 == currentCoords.1 && cellsArray[lastSelectedCell.0][lastSelectedCell.1].0.backgroundColor != .black{
                    cellsArray[lastSelectedCell.0][lastSelectedCell.1].0.backgroundColor = .yellow
                } else {
                    highlightRows()
                }
            } else {
                if newCell.0 == currentCoords.0 && cellsArray[lastSelectedCell.0][lastSelectedCell.1].0.backgroundColor != .black{
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
    
    func unhighlightRows() {
        
        if blocking {
            cellsArray[currentCoords.0][currentCoords.1].0.backgroundColor = .white
        }
        
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

}

extension PuzzleViewController: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        print("textFieldDidChange")
        textField.text = BLANK_CHARACTER
    }
    
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
                print("Backspace was pressed")
                label.text = ""
                moveCellandLabel(to: deiterateCoords(currentI: currentCoords.0, currentJ: currentCoords.1))
            }
        }
        
        
        return true
    }
    
}


//MARK: - Keyboard Toolbar
extension PuzzleViewController {
    
    func createToolbar() {
        
        numberToolbar.barStyle = .default
        numberToolbar.items = [
            UIBarButtonItem(title: "Block", style: .plain, target: self, action: #selector(toggleBlocking)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Swap", style: .plain, target: self, action: #selector(toggleDirection)),
            UIBarButtonItem(title: "Nums", style: .plain, target: self, action: #selector(updateNumbers))]
        numberToolbar.sizeToFit()
        fakeTextField.inputAccessoryView = nil
        fakeTextField.inputAccessoryView = numberToolbar
    }
    
    @objc func toggleDirection() {
        unhighlightRows()
        horizontal = !horizontal
        highlightRows()
    }
    @objc func toggleBlocking() {
        blocking = !blocking
        if blocking {
            unhighlightRows()
            numberToolbar.items?[0].title = "Done"
        } else {
            numberToolbar.items?[0].title = "Block"
        }
    }
}


extension PuzzleViewController: UIScrollViewDelegate {
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        scrollView.setZoomScale(1.0, animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        print("viewForZoomingIn")

        return self.puzzleContainerView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print("scrollViewDidZoom")
        if scrollView.zoomScale < 1.0 {
            scrollView.zoomScale = 1.0
        }
    }
}
