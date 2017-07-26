//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Jonathan L. on 7/20/17.
//  Copyright © 2017 Jonathan L. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumlator: (Double, String)?
    private var calledEquals = false
    private var calledBinaryOperation = false
    private var arrayOfOperationsAndOperands: [String] = []
    
    private enum Operation {
        case clear
        case constant(Double)
        case unaryOperation((Double) -> Double, (String)  -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    //var resultIsPending = false
    var descriptionOfMathSequence: String?
    
    //Mathematical operations that can be performed by calculator
    private var operations : Dictionary<String, Operation> = [
    "C" : Operation.clear,
    "π" : Operation.constant(Double.pi),
    "e" : Operation.constant(M_E),
    "√" : Operation.unaryOperation(sqrt, { "√(" + $0 + ")" }),
    "cos" : Operation.unaryOperation(cos, { "cos(" + $0 + ")" }),
    "sin" : Operation.unaryOperation(sin, { "sin(" + $0 + ")" }),
    "±" : Operation.unaryOperation({ -$0 }, { "-(" + $0 + ")" }),
    "x²" : Operation.unaryOperation({ pow($0, 2) }, { "(" + $0 + ")²" }),
    "×" : Operation.binaryOperation(*, { $0 + "×" + $1 }),
    "÷" : Operation.binaryOperation(/, { $0 + "÷" + $1 }),
    "+" : Operation.binaryOperation(+, { $0 + "+" + $1 }),
    "−" : Operation.binaryOperation(-, { $0 + "-" + $1 }),
    "xʸ" : Operation.binaryOperation({ pow($0, $1) }, { $0 + "^" + $1 }),
    "mod" : Operation.binaryOperation({ $0.truncatingRemainder(dividingBy: $1) }, { "(" + $0 + ")mod" + $1 }),
    "=" : Operation.equals
    ]
    
    //Cannot remove for assignment
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .clear:
                accumlator = (0, "C")
                pendingBinaryOperation = nil //reset pendingBinaryOperation
            case .constant(let value):
                accumlator = (value, symbol)
            case .unaryOperation(let function, let description):
                performPendingBinaryOperation()
                if accumlator != nil {
                    accumlator = (function(accumlator!.0), description(accumlator!.1))
                }
            case .binaryOperation(let function, let description):
                if !calledEquals {
                    calledBinaryOperation = true
                }
                performPendingBinaryOperation()
                if accumlator != nil {
                    
                    pendingBinaryOperation = PendingBinaryOperation(function: function, description: description, firstOperand: (accumlator!.0, accumlator!.1))
                    accumlator = nil
                    
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
            accumlator = pendingBinaryOperation!.perform(with: (accumlator!.0, CalculatorBrain.formatMyNumber(number: accumlator!.0)!))
            pendingBinaryOperation = nil
        }
    }
    //Static function for formatting as integer if no decimal and to six places if there is a decimal.
    static func formatMyNumber(number: Double?) -> String? {
        let formattedNumber = NumberFormatter()
        var stringNumberToReturn: String?
        
        if number != nil {
            if number?.truncatingRemainder(dividingBy: 1) == 0 {
                formattedNumber.maximumFractionDigits = 0
                stringNumberToReturn = formattedNumber.string(for: number)!
            }
            else {
                formattedNumber.maximumFractionDigits = 6
                stringNumberToReturn = formattedNumber.string(for: number)!
            }
        }
        else {
            stringNumberToReturn = nil
        }
        
        return stringNumberToReturn
    }
    
    
    private struct  PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let description: (String, String) -> String
        let firstOperand: (Double, String)
        
        func perform(with secondOperand: (Double, String)) -> (Double, String) {
            return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1))
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumlator = (operand, CalculatorBrain.formatMyNumber(number: operand)!)
    }
    mutating func setOperand(variable: String) {
        
    }
    
    var result: Double? {
        get {
            if accumlator != nil {
              return accumlator!.0
            }
            else {
                return nil
            }
        }
    }
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    var description: String? {
        mutating get {
            var stringToReturn: String?
            
            if accumlator?.1 == "C" {
                stringToReturn = nil
                accumlator = nil
            }
            else if resultIsPending {
                stringToReturn = pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, CalculatorBrain.formatMyNumber(number: (accumlator?.0)) ?? "")
            }
            else {
                stringToReturn = accumlator?.1
            }
            
            return stringToReturn
        }
    }
}
