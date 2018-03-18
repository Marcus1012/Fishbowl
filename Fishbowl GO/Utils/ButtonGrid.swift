//
//  ButtonGrid.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 2/2/17.
//  Copyright © 2017 RPM Consulting. All rights reserved.
//

import Foundation
import UIKit

class ButtonConstraints {
    let left: NSLayoutConstraint
    let top: NSLayoutConstraint
    let width: NSLayoutConstraint
    let height: NSLayoutConstraint
    
    init(left: NSLayoutConstraint, top: NSLayoutConstraint, width: NSLayoutConstraint, height: NSLayoutConstraint) {
        self.left = left
        self.top = top
        self.width = width
        self.height = height
    }
}

class ButtonWithLoc {
    let button: UIButton
    let constraints: ButtonConstraints
    init(button: UIButton, constraints: ButtonConstraints) {
        self.button = button
        self.constraints = constraints
    }
}


class ButtonGrid {
    private let spacingAboveBelow = 8
    private let spacingBeforeAfter = 6
    private let spacingBetween = 6
    private let defaultButtonHeight = 90
    private let defaultButtonWidth = 184

    private (set) internal var rowCount: Int = 1        // default is 1 row
    private (set) internal var columnCount: Int = 1 {   // default is 1 col
        didSet {
            recalcRowCount()
        }
    }
    private (set) internal var buttons = [ButtonWithLoc]() {
        didSet {
            layoutButtons()
        }
    }
    private var isLandscape: Bool {
        get {
            if let frame = frame {
                return frame.width > frame.height
            }
            return false
        }
    }
    var frameTopOffset = 60 {
        didSet {
            layoutButtons()
        }
    }
    var portraitColumns = 2 {
        didSet {
            if let frame = frame {
                if frame.width < frame.height { // in portrait mode?
                    layoutButtons()
                }
            }
        }
    }
    var landscapeColumns = 3 {
        didSet {
            if let frame = frame {
                if frame.width > frame.height { // in landscape mode?
                    layoutButtons()
                }
            }
        }
    }

    var frame: CGRect? {
        didSet {
            layoutButtons()
        }
    }

    private func verticalSpacers(columns: Int) -> Int {
        return (columns > 0) ? columns - 1 : 0
    }

    private func getItemRow(itemIndex: Int) -> Int {
        return (itemIndex / columnCount) + 1
    }
    
    private func rowButtonCount(row: Int) -> Int { // number of buttons on this row (1-based row numbers)
        if row > 0 && row <= rowCount {
            let fullRows = buttons.count / columnCount
            if row <= fullRows {
                return columnCount
            }
            return buttons.count % columnCount
        }
        return 0
    }
    
    private func recalcRowCount() {
        let items = max(buttons.count, 1)
        rowCount = Int(ceil(CGFloat(items) / CGFloat(columnCount)))
    }

    private func layoutButtons() {
        if let frame = self.frame {
            columnCount = isLandscape ? landscapeColumns : portraitColumns
            recalcRowCount()
            let buttonHeight = calculateButtonHeight(frame.height, rows: rowCount)
            let buttonWidth = calculateButtonWidth(frame.width, columns: columnCount)
            setButtonConstraints(buttonWidth, buttonHeight: buttonHeight)
        }
    }
    
    private func calculateButtonWidth(frameWidth: CGFloat, columns: Int) -> CGFloat {
        var buttonWidth: CGFloat = CGFloat(defaultButtonWidth) // default width
        let totalSpacing = (verticalSpacers(columns) * spacingBetween) + (2 * spacingBeforeAfter)
        buttonWidth = CGFloat(Int(frameWidth) - totalSpacing) / CGFloat(columns)
        return buttonWidth
    }

    private func calculateButtonHeight(frameHeight: CGFloat, rows: Int) -> CGFloat {
        var buttonHeight: CGFloat = CGFloat(defaultButtonHeight)
        let totalSpacing = (2 * spacingAboveBelow) + ((rowCount - 1) * spacingBetween)
        buttonHeight = CGFloat(Int(frameHeight) - frameTopOffset - totalSpacing) / CGFloat(rows)
        return buttonHeight
    }
    
    private func calcTopConstraint(index: Int, btnHeight: CGFloat) -> CGFloat {
        var top: CGFloat = 0
        let row = CGFloat(floor(Double(index) / Double(columnCount)))
        top = CGFloat(spacingAboveBelow) + (row * CGFloat(spacingBetween)) + (row * btnHeight)
        return top
    }
    
    private func calcLeftConstraint(index: Int, btnWidth: CGFloat) -> CGFloat {
        var left: CGFloat = 0
        let column = CGFloat(index % columnCount)
        left = CGFloat(spacingBeforeAfter) + (column * CGFloat(spacingBetween)) + (column * btnWidth)
        return left
    }

    private func setButtonConstraints(buttonWidth: CGFloat, buttonHeight: CGFloat) {
        for (index, button) in buttons.enumerate() {
            button.constraints.height.constant = buttonHeight
            button.constraints.top.constant = calcTopConstraint(index, btnHeight: buttonHeight)

            let rowBtnCount = rowButtonCount(getItemRow(index))
            if rowBtnCount == columnCount {
                button.constraints.width.constant = buttonWidth
                button.constraints.left.constant = calcLeftConstraint(index, btnWidth: buttonWidth)
            } else {
                // not a full row... find new button width(s)...
                let newWidth = calculateButtonWidth(frame!.width, columns: rowBtnCount)
                button.constraints.width.constant = newWidth
                button.constraints.left.constant = calcLeftConstraint(index, btnWidth: newWidth)
            }
        }
    }
    
    
    // MARK: - Public Methods
    
    func addButton(button: UIButton, left: NSLayoutConstraint, top: NSLayoutConstraint, width: NSLayoutConstraint, height: NSLayoutConstraint) {
        let buttonWithLoc = ButtonWithLoc(button: button, constraints: ButtonConstraints(left: left, top: top, width: width, height: height))
        buttons.append(buttonWithLoc)
    }

    func columnsOnRow(row: Int) -> Int {
        return 1
    }

}
