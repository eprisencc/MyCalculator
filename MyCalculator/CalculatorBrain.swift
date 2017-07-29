//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Jonathan L. on 7/20/17.
//  Copyright © 2017 Jonathan L. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var stackOfElementsInOperation = [ElementInOperation]()
    
    private enum ElementInOperation {
        case operation(String)
        case operand(Double)
        case variable(String)
    }
    
    private enum Operation {
        case clear
        case constant(Double)
        case unaryOperation((Double) -> Double, (String)  -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case nullaryOperation(() -> Double, String)
        case equals
    }
    
    //Mathematical operations that can be performed by calculator
    private var operations : Dictionary<String, Operation> = [
    //"C" : Operation.clear,
    "π" : Operation.constant(Double.pi),
    "e" : Operation.constant(M_E),
    
    "√" : Operation.unaryOperation(sqrt, { "√(" + $0 + ")" }),
    "cos" : Operation.unaryOperation(cos, { "cos(" + $0 + ")" }),
    "sin" : Operation.unaryOperation(sin, { "sin(" + $0 + ")" }),
    "tan" : Operation.unaryOperation(tan, { "tan(" + $0 + ")" }),
    "cosh" : Operation.unaryOperation(cosh, { "cosh(" + $0 + ")" }),
    "sinh" : Operation.unaryOperation(sinh, { "sinh(" + $0 + ")" }),
    "tanh" : Operation.unaryOperation(tanh, { "tanh(" + $0 + ")" }),
    "±" : Operation.unaryOperation({ -$0 }, { "-(" + $0 + ")" }),
    "x²" : Operation.unaryOperation({ pow($0, 2) }, { "(" + $0 + ")²" }),
    "x⁻¹" : Operation.unaryOperation({ 1/$0 }, { "(" + $0 + ")⁻¹" }),
    "ln" : Operation.unaryOperation(log, { "ln(" + $0 + ")" }),
    "log" : Operation.unaryOperation(log10, { "log(" + $0 + ")" }),
    "eˣ" : Operation.unaryOperation(exp, { "e^(" + $0 + ")" }),
    
    "×" : Operation.binaryOperation(*, { $0 + "×" + $1 }),
    "÷" : Operation.binaryOperation(/, { $0 + "÷" + $1 }),
    "+" : Operation.binaryOperation(+, { $0 + "+" + $1 }),
    "−" : Operation.binaryOperation(-, { $0 + "-" + $1 }),
    "xʸ" : Operation.binaryOperation({ pow($0, $1) }, { $0 + "^" + $1 }),
    "mod" : Operation.binaryOperation({ $0.truncatingRemainder(dividingBy: $1) }, { "(" + $0 + ")mod" + $1 }),
    
    "rand" : Operation.nullaryOperation({ Double(arc4random()) / Double(UInt32.max) }, "rand()"),
    
    "=" : Operation.equals
    ]
    
    //Static function for formatting as integer if no decimal and to six places if there is a decimal.
    static func formatMyNumber(number: Double?) -> String? {
        let formattedNumber = NumberFormatter()
        var stringNumberToReturn: String?
        
        if number != nil {
            if number?.truncatingRemainder(dividingBy: 1) == 0 {
                formattedNumber.maximumFractionDigits = 0
                formattedNumber.minimumIntegerDigits = 1
                stringNumberToReturn = formattedNumber.string(for: number)!
            }
            else {
                formattedNumber.maximumFractionDigits = 6
                formattedNumber.minimumIntegerDigits = 1
                stringNumberToReturn = formattedNumber.string(for: number)!
            }
        }
        else {
            stringNumberToReturn = nil
        }
        
        return stringNumberToReturn
    }
    
    mutating func setOperand(_ operand: Double) {
        stackOfElementsInOperation.append(ElementInOperation.operand(operand))
    }
    
    mutating func setOperand(variable named: String) {
        stackOfElementsInOperation.append(ElementInOperation.variable(named))
    }
    
    mutating func performOperation(_ symbol: String) {
       stackOfElementsInOperation.append(ElementInOperation.operation(symbol))
    }
    
    mutating func undo() {
        if !stackOfElementsInOperation.isEmpty {
            stackOfElementsInOperation.removeLast()
        }
    }
    
    @available(*, deprecated, message: "no longer needed ...")
    var result: Double? {
            return evaluate().result
    }
    
    @available(*, deprecated, message: "no longer needed ...")
    var resultIsPending: Bool {
        return evaluate().isPending
    }
    
    @available(*, deprecated, message: "no longer needed ...")
    var description: String? {
        return evaluate().descripton
    }
    
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, descripton: String) {
        var accumulator: (Double, String)?
        //var calledEquals = false
        //var calledBinaryOperation = false
        //var temporaryMathOperationsTotal: Double?
        
        var pendingBinaryOperation: PendingBinaryOperation?
        
        /*var resultIsPending: Bool {
            get {
             return pendingBinaryOperation != nil
             }
        }*/
        
        
        struct  PendingBinaryOperation {
            let function: (Double, Double) -> Double
            let description: (String, String) -> String
            let firstOperand: (Double, String)
            
            func perform(with secondOperand: (Double, String)) -> (Double, String) {
                return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1))
            }
        }
        
        func performPendingBinaryOperation() {
            if pendingBinaryOperation != nil && accumulator != nil {
                accumulator = pendingBinaryOperation!.perform(with: (accumulator!))
                pendingBinaryOperation = nil
            }
        }
        
        var result: Double? {
            get {
                if accumulator != nil {
                    return accumulator!.0
                }
                else {
                    return nil
                }
            }
        }
        
        var description: String? {
            if pendingBinaryOperation != nil {
                return pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, accumulator?.1 ?? "")
            } else {
                return accumulator?.1
            }

            
            /*get {
                var stringToReturn: String?
                
                if accumlator?.1 == "C" {
                    stringToReturn = nil
                    accumlator = nil
                }
                else if resultIsPending && !calledEquals {
                    if accumlator?.0 == temporaryMathOperationsTotal {
                        stringToReturn = pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, "")
                    }
                    else if accumlator?.1 == "π" {
                        stringToReturn = pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, (accumlator?.1)!)
                    }
                    else {
                        stringToReturn = pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, (accumlator?.1) ?? "")
                    }
                }
                else if resultIsPending && calledEquals {
                    stringToReturn = pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, (accumlator?.1) ?? "")
                }
                else {
                    stringToReturn = accumlator?.1
                }
                
                return stringToReturn
            }*/
        }
        
        for element in stackOfElementsInOperation {
            switch element {
            case .operand(let value):
                accumulator = (value, CalculatorBrain.formatMyNumber(number: value)!)
            case .operation(let symbol):
                if let operation = operations[symbol] {
                    switch operation {
                    case .constant(let value):
                        accumulator = (value, symbol)
                    case .nullaryOperation(let randomNumberFunction, let descriptionOfRandomNumber):
                        accumulator = (randomNumberFunction(), descriptionOfRandomNumber)
                    case .unaryOperation(let function, let description):
                        if accumulator != nil {
                            accumulator = (function(accumulator!.0), description(accumulator!.1))
                        }
                    case .binaryOperation(let function, let description):
                        performPendingBinaryOperation()
                        if accumulator != nil {
                            
                            pendingBinaryOperation = PendingBinaryOperation(function: function, description: description, firstOperand: (accumulator!.0, accumulator!.1))
                            //temporaryMathOperationsTotal = accumulator!.0
                            accumulator = nil
                            //calledEquals = false
                            
                        }
                        //When user removes last binary operation and decide to add a binary operation back
                        /*else if (accumlator == nil) && calledEquals {
                            if (temporaryMathOperationsTotal != nil) && (self.description != nil) {
                                accumlator = (temporaryMathOperationsTotal!, self.description!)
                                pendingBinaryOperation = PendingBinaryOperation(function: function, description: description, firstOperand: (accumlator!.0, accumlator!.1))
                                calledEquals = false
                            }
                        }*/
                    case .equals:
                        performPendingBinaryOperation()
                        //calledEquals = true
                    default:
                        break
                    }
                }
            case .variable(let symbol):
                if let value = variables?[symbol] {
                    accumulator = (value, symbol)
                }
                else {
                    accumulator = (0, symbol)
                }
            }
        }
        
        return (result, pendingBinaryOperation != nil, description ?? "")
    }
}
