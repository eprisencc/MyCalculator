//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Jonathan L. on 7/20/17.
//  Copyright © 2017 Jonathan L. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumlator: Double?
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    //var resultIsPending = false
    var descriptionOfMathSequence: String?
    
    //Mathematical operations that can be performed by calculator
    private var operations : Dictionary<String, Operation> = [
    "π" : Operation.constant(Double.pi),
    "e" : Operation.constant(M_E),
    "C" : Operation.constant(0),
    "√" : Operation.unaryOperation(sqrt),
    "cos" : Operation.unaryOperation(cos),
    "sin" : Operation.unaryOperation(sin),
    "±" : Operation.unaryOperation({ -$0 }),
    "x²" : Operation.unaryOperation({ $0 * $0 }),
    "×" : Operation.binaryOperation({ $0 * $1 }),
    "÷" : Operation.binaryOperation({ $0 / $1 }),
    "+" : Operation.binaryOperation({ $0 + $1 }),
    "−" : Operation.binaryOperation({ $0 - $1 }),
    "x^y" : Operation.binaryOperation({ pow($0, $1) }),
    "mod" : Operation.binaryOperation({ $0.truncatingRemainder(dividingBy: $1) }),
    "=" : Operation.equals
    ]
    
    //Cannot remove for assignment
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            
            //Update descriptionOfMathSequence
            if symbol == "C" {
                descriptionOfMathSequence = ""
            }
            else if descriptionOfMathSequence != nil && accumlator != nil && descriptionOfMathSequence != "" {
                
                /*Properly format special operators for display in descriptionOfMathSequence*/
                    switch symbol {
                    case "x²" :
                        descriptionOfMathSequence = "\(descriptionOfMathSequence!) ^ 2"
                    case "x^y" :
                        descriptionOfMathSequence = "\(descriptionOfMathSequence!) ^"
                    case "±" :
                        descriptionOfMathSequence = "- (\(descriptionOfMathSequence!))"
                    case "√" :
                        descriptionOfMathSequence = "√ (\(descriptionOfMathSequence!))"
                    case "cos" :
                        descriptionOfMathSequence = "cos(\(descriptionOfMathSequence!))"
                    case "sin" :
                        descriptionOfMathSequence = "sin(\(descriptionOfMathSequence!))"
                    case "=" : break
                    default :
                        descriptionOfMathSequence = descriptionOfMathSequence! + " " + symbol

                    }
            }
            
            switch operation {
            case .constant(let value):
                accumlator = value
            case .unaryOperation(let function):
                if accumlator != nil {
                    accumlator = function(accumlator!)
                }
            case .binaryOperation(let function):
                if accumlator != nil && accumlator != 0.0 {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumlator!)
                    accumlator = nil
                    //resultIsPending = true
                    
                }
            case .equals:
                performPendingBinaryOperation()
            //default: break
            }
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumlator != nil {
            accumlator = pendingBinaryOperation!.perform(with: accumlator!)
            pendingBinaryOperation = nil
            //resultIsPending = false
        }
    }
    
    //This is my extra function so do not remove.  May want to make it static.
    //Formatting as integer if no decimal and to six places if there is a decimal.
    func formatMyNumber(number: Double) -> String {
        let formattedNumber = NumberFormatter()
        var stringNumberToReturn: String
        
        if number.truncatingRemainder(dividingBy: 1) == 0 {
            formattedNumber.maximumFractionDigits = 0
            stringNumberToReturn = formattedNumber.string(for: number)!
        }
        else {
            formattedNumber.maximumFractionDigits = 6
            stringNumberToReturn = formattedNumber.string(for: number)!
        }
        
        return stringNumberToReturn
    }
    
    
    private struct  PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    //Cannot remove for assignment
    mutating func setOperand(_ operand: Double) {
        accumlator = operand
        
        if descriptionOfMathSequence != nil {
            descriptionOfMathSequence = descriptionOfMathSequence! + " " + formatMyNumber(number: operand)
        }
        else {
            descriptionOfMathSequence = formatMyNumber(number: operand)
        }
        
    }
    mutating func setOperand(variable: String) {
        
    }
    
    //Cannot remove for assignment
    var result: Double? {
        get {
            return accumlator
        }
    }
    
    var resultIsPending: Bool {
        get {
            return nil != pendingBinaryOperation
        }
    }
}
