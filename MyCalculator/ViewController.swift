//
//  ViewController.swift
//  MyCalculator
//
//  Created by Jonathan L. on 7/22/17.
//  Copyright © 2017 Jonathan L. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var sequenceOfOperationsDisplay: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    var haveADecimalPoint = false
    var resultHasBeenDisplayed = false
    private var calculatorBrain = CalculatorBrain()
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }

    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            
            //Only allow one decimal point in the display
            if !haveADecimalPoint && digit == "." {
                display.text = textCurrentlyInDisplay + digit
                haveADecimalPoint = true
            }
            else if haveADecimalPoint && digit == "." {
                
            }
            else {
                display.text = textCurrentlyInDisplay + digit
            }
        }
        else {
            display.text = digit
            if resultHasBeenDisplayed {
                sequenceOfOperationsDisplay.text = calculatorBrain.descriptionOfMathSequence
                resultHasBeenDisplayed = false
            }
            userIsInTheMiddleOfTyping = true
            if digit == "." {
                haveADecimalPoint = true
            }
        }
    }
    

    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            calculatorBrain.setOperand(displayValue)
            sequenceOfOperationsDisplay.text = calculatorBrain.descriptionOfMathSequence
            userIsInTheMiddleOfTyping = false
            haveADecimalPoint = false
        }
        
        /*If result has been displayed remove = sign from end of sequenceOfOperationsDisplay otherwise keep unary operation in display*/
        if resultHasBeenDisplayed {
            if let previousSequenceOfOperationsDisplay = sequenceOfOperationsDisplay.text {
                if previousSequenceOfOperationsDisplay.hasSuffix("=") {
                    let endIndex = previousSequenceOfOperationsDisplay.index(previousSequenceOfOperationsDisplay.endIndex, offsetBy: -2)
                    calculatorBrain.descriptionOfMathSequence = previousSequenceOfOperationsDisplay.substring(to: endIndex)
                }
                else {
                    calculatorBrain.descriptionOfMathSequence = previousSequenceOfOperationsDisplay
                }
            }
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            calculatorBrain.performOperation("=")
            
            calculatorBrain.performOperation(mathematicalSymbol)
            sequenceOfOperationsDisplay.text = calculatorBrain.descriptionOfMathSequence
        }
        
        //Display result and reset descriptionOfMathSequence
        if let result = calculatorBrain.result {
            display.text = calculatorBrain.formatMyNumber(number: result)
            calculatorBrain.descriptionOfMathSequence = nil
            resultHasBeenDisplayed = true
        }
    }
}

