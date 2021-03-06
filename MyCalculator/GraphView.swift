//
//  GraphView.swift
//  GraphingFunctions
//
//  Created by Jonathan L. on 8/3/17.
//  Copyright © 2017 Jonathan L. All rights reserved.
//

import UIKit

struct DataSource {
    var function: ((CGFloat) -> Double)?
    
    func getYCoordinate(x: CGFloat) -> CGFloat {
        return CGFloat(function?(x) ?? Double.nan)
    }
    
}

@IBDesignable
class GraphView: UIView {
    private var axesDrawer = AxesDrawer(color: UIColor.white)
    
    var myData = DataSource(function: { (x: CGFloat) -> Double in
        let data = Double(x)
        return Double.nan }) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var origin: CGPoint? /*{ didSet{ setNeedsDisplay() } }*/
    
    @IBInspectable
    var scale: CGFloat = 50 /*{ didSet{ setNeedsDisplay() } }*/
    
    @IBInspectable
    var lineWidth: CGFloat = 3 { didSet{ setNeedsDisplay() } }
    
    @IBInspectable
    var color: UIColor = UIColor.orange { didSet{ setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        if origin == nil {
            origin = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        
        axesDrawer.drawAxes(in: bounds, origin: origin!, pointsPerUnit: scale)
        color.set()
        pathForFunction().stroke()
    }
    
    private func pathForFunction() -> UIBezierPath {
        let path = UIBezierPath()
        let width = Int(bounds.size.width * scale)
        var pathStarted = false
        
        if origin == nil {
            origin = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        
        for pixel in 0...width {
            var pointTranslated: CGPoint = CGPoint.zero
            var pointOnNormalAxes: CGPoint = CGPoint.zero
            pointTranslated.x = ((CGFloat(pixel) / scale) - (origin?.x)!) / scale
            pointTranslated.y = myData.getYCoordinate(x: pointTranslated.x)
            
            if pointTranslated.y.isNaN {
                pointOnNormalAxes = origin!
            }
            else {

                pointOnNormalAxes.x = CGFloat(pixel) / scale
                pointOnNormalAxes.y = (origin?.y)! - pointTranslated.y * scale

            }

            if !pathStarted {
                path.move(to: pointOnNormalAxes)
                pathStarted = true
            }
            else {
                path.addLine(to: pointOnNormalAxes)
            }
        }
        
        path.lineWidth = lineWidth
        return path
    }
    
    func moveOrigin(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .changed:
            let translation = panRecognizer.translation(in: self)
            origin?.x += translation.x
            origin?.y += translation.y
            panRecognizer.setTranslation(CGPoint.zero, in: self)
        case .ended:
            let translation = panRecognizer.translation(in: self)
            origin?.x += translation.x
            origin?.y += translation.y
            panRecognizer.setTranslation(CGPoint.zero, in: self)
            setNeedsDisplay()
        default:
            break
        }
    }
    
    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        case .ended:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
            setNeedsDisplay()
        default:
            break
        }
    }
    
    func doubleTap(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        if tapRecognizer.state == .ended {
            origin = tapRecognizer.location(in: self)
            setNeedsDisplay()
        }
    }

}
