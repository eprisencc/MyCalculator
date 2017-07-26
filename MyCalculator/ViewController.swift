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
            display.text = CalculatorBrain.formatMyNumber(number: newValue)
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
               //Do nothing because this is a second decimal point on the same operand
            }
            else {
                display.text = textCurrentlyInDisplay + digit
            }
        }
        else {
            display.text = digit
            if resultHasBeenDisplayed {
                sequenceOfOperationsDisplay.text = calculatorBrain.description
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
            userIsInTheMiddleOfTyping = false
            haveADecimalPoint = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            calculatorBrain.performOperation(mathematicalSymbol)
        }
        
        if let result = calculatorBrain.result {
            displayValue = result
            resultHasBeenDisplayed = true
        }
        
        if let description = calculatorBrain.description {
            sequenceOfOperationsDisplay.text = description
        }
        else {
            sequenceOfOperationsDisplay.text = ""
        }
    }
}

