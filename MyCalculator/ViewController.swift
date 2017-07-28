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
    private var variables: Dictionary<String, Double>?
    
    var displayValue: Double {
        get {
            return Double(display.text!) ?? 0  //?? is when a decimal is entered and then hit C
        }
        set {
            display.text = CalculatorBrain.formatMyNumber(number: newValue)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            var textCurrentlyInDisplay: String
            if display.text == "0" {
               textCurrentlyInDisplay = ""
            }
            else {
                textCurrentlyInDisplay = display.text!
            }
            
            //Only allow one decimal point in the display.
            if !haveADecimalPoint && digit == "." {
                display.text = textCurrentlyInDisplay + digit
                haveADecimalPoint = true
            }
            else if haveADecimalPoint && digit == "." {
            //Do nothing because this is a second decimal point on the same operand.
            }
            else {
                display.text = textCurrentlyInDisplay + digit
            }
        }
        else {
            display.text = digit
            if resultHasBeenDisplayed {
                sequenceOfOperationsDisplay.text = calculatorBrain.evaluate(using: variables).descripton + (calculatorBrain.evaluate(using: variables).isPending ? "..." : "=")
                resultHasBeenDisplayed = false
            }
            userIsInTheMiddleOfTyping = true
            
            //If the first digit is a decimal point add a zero in front.
            if digit == "." {
                display.text = "0\(digit)"
                haveADecimalPoint = true
            }
            else {
                display.text = digit
            }
        }
    }
    
    private func displayResult() {
        let evaluated = calculatorBrain.evaluate(using: variables)
        
        if let result = evaluated.result {
            displayValue = result
            resultHasBeenDisplayed = true
        }
        
        if evaluated.descripton != "" {
            sequenceOfOperationsDisplay.text = evaluated.descripton + (evaluated.isPending ? "..." : "=")
        }
        else {
            sequenceOfOperationsDisplay.text = ""
        }
    }
    
    @IBAction func reset(_ sender: UIButton) {
        calculatorBrain = CalculatorBrain()
        userIsInTheMiddleOfTyping = false
        haveADecimalPoint = false
        resultHasBeenDisplayed = false
        variables = Dictionary<String, Double>()
        displayValue = 0
        sequenceOfOperationsDisplay.text = ""
    }
    
    var temporaryHoldForDisplay = ""
    
    @IBAction func storeToMemoryPressedDown(_ sender: UIButton) {
        variables = ["M": displayValue]
        temporaryHoldForDisplay = display.text ?? "0"
        displayResult()
        userIsInTheMiddleOfTyping = false
        display.text = "STORED"
    }
    
    @IBAction func storeToMemoryNoLongerPressed(_ sender: UIButton) {
        display.text = temporaryHoldForDisplay
        temporaryHoldForDisplay = ""
    }
    
    
    @IBAction func callMemory(_ sender: UIButton) {
        calculatorBrain.setOperand(variable: sender.currentTitle!)
        userIsInTheMiddleOfTyping = false
        displayResult()
    }
    
    @IBAction func backSpace(_ sender: UIButton) {
        var textToBackSpace: String = display.text!
        
        //Only allow backspacing when zero is not in the display and the display is not showing the results
        if textToBackSpace != "0" && !resultHasBeenDisplayed {
            var charactersToBackSpace = Array(textToBackSpace.characters)
            
            if charactersToBackSpace.count > 1 {
                charactersToBackSpace.removeLast()
                textToBackSpace = String(charactersToBackSpace)
            }
            else {
                textToBackSpace = "0"
            }
            
        }
        
        display.text = textToBackSpace
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
        
        displayResult()
    }
}

