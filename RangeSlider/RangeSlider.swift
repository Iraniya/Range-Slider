//
//  RangeSlider.swift
//  RangeSlider
//
//  Created by Iraniya Naynesh on 28/03/18.
//  Copyright © 2018 Iraniya Naynesh. All rights reserved.
//

import UIKit
import QuartzCore

class RangeSlider: UIControl {

    var lowerLabel: UILabel =  {
        let label = UILabel()
        label.layer.borderColor = UIColor.blue.cgColor
        label.layer.borderWidth = 1.0
        label.layer.cornerRadius = 25/2
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    var upperLabel: UILabel =  {
        let label = UILabel()
        label.layer.borderColor = UIColor.blue.cgColor
        label.layer.borderWidth = 1.0
        label.layer.cornerRadius = 25/2
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    var lowerLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blue
        return view
    }()
    
    var upperLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blue
        return view
    }()
    
    var minimumValue: Double = 0.0  { didSet { updateLayerFrames() } }
    var maximumValue: Double = 24.0 { didSet { updateLayerFrames() } }
    var lowerValue: Double = 5.0 { didSet { updateLayerFrames() } }
    var upperValue: Double = 9.0 { didSet { updateLayerFrames() } }
    
    let trackLayer = RangeSliderTrackLayer()
    let lowerThumbLayer = RangeSliderThumbLayer()
    let upperThumbLayer = RangeSliderThumbLayer()
    
    var previousLoaction = CGPoint()
    var trackTintColor = UIColor(white: 0.9, alpha: 1.0) { didSet { trackLayer.setNeedsDisplay() } }
    var trackHighlightTintColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0)
    
    var thumbTintColor = UIColor.white {
        didSet {
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }
    
    var curvaceousness : CGFloat = 1.0 {
        didSet {
            trackLayer.setNeedsDisplay()
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }
    
    var thumbWidth: CGFloat { return CGFloat(bounds.height) }
    var labelWidth: CGFloat { return 40 }
    
    override var frame: CGRect { didSet { updateLayerFrames() } }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(lowerLabel)
        self.addSubview(upperLabel)
        self.addSubview(lowerLine)
        self.addSubview(upperLine)
        
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        
        lowerThumbLayer.rangeSlider = self
        lowerThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(lowerThumbLayer)
        
        upperThumbLayer.rangeSlider = self
        upperThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(upperThumbLayer)
        
        updateLayerFrames()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateLayerFrames() {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height/3)
        trackLayer.setNeedsDisplay()
        
        // Lower part
        let lowerThumbCenter = CGFloat(positionForValue(value: lowerValue))
        lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth / 2, y: 0.0, width: thumbWidth, height: thumbWidth)
        lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth/2, y: 0.0, width: thumbWidth, height: thumbWidth)
        lowerThumbLayer.setNeedsDisplay()
        
        lowerLine.frame = CGRect(x: lowerThumbCenter, y: bounds.height, width: 1, height: 5)
        lowerLabel.frame = CGRect(x: 0, y: bounds.height + 5, width: 50, height: 25)
        lowerLabel.center.x = lowerThumbCenter
        lowerLabel.text = String(format: "%.2f",lowerValue)
        
        //upper part
        let upperThumbCenter = CGFloat(positionForValue(value: upperValue))
        upperThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth / 2, y: 0.0, width: thumbWidth, height: thumbWidth)
        
        upperLine.frame = CGRect(x: upperThumbCenter, y: bounds.height, width: 1, height: 5)
        upperLabel.frame = CGRect(x: 0, y: bounds.height + 5, width: 50, height: 25)
        upperLabel.center.x = upperThumbCenter
        upperLabel.text = String(format: "%.2f",upperValue)
        upperThumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    func positionForValue(value: Double) -> Double {
        return Double(bounds.width - thumbWidth) * (value - minimumValue) / (maximumValue - minimumValue) + Double(thumbWidth / 2.0)
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLoaction = touch.location(in: self)
        
        if lowerThumbLayer.frame.contains(previousLoaction) || lowerLabel.frame.contains(previousLoaction) {
            lowerThumbLayer.highlighted = true
        } else if upperThumbLayer.frame.contains(previousLoaction) {
            upperThumbLayer.highlighted = true
        }
        return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        let deltaLoaction = Double(location.x - previousLoaction.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLoaction / Double(bounds.width - thumbWidth)
        previousLoaction = location
        
        if lowerThumbLayer.highlighted  {
            lowerValue += deltaValue
            lowerValue = boundValues(value: lowerValue, toLowerValue: minimumValue, upperValue: upperValue)
            lowerLabel.text = String(format: "%.2f",lowerValue)
        } else if upperThumbLayer.highlighted {
                upperValue += deltaValue
            upperValue = boundValues(value: upperValue, toLowerValue: lowerValue, upperValue: maximumValue)
            upperLabel.text = String(format: "%.2f",upperValue)
        }
        
        sendActions(for: .valueChanged)
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        upperThumbLayer.highlighted = false
        lowerThumbLayer.highlighted = false
    }
    
    func boundValues(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
}


class RangeSliderThumbLayer: CALayer {
    
    var  highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    weak var rangeSlider: RangeSlider?
    
    override func draw(in ctx: CGContext) {
        if let slider = rangeSlider {
            
            let thumbFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
            let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
            let thumbpath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
            
            //fill with subtle shadow
            let shadowColor = UIColor.gray
            ctx.setShadow(offset: CGSize(width: 0.0, height: 1.0), blur: 1.0, color: shadowColor.cgColor)
            ctx.setFillColor(slider.thumbTintColor.cgColor)
            ctx.addPath(thumbpath.cgPath)
            ctx.fillPath()
            
            //outline
            ctx.setStrokeColor(shadowColor.cgColor)
            ctx.setLineWidth(0.5)
            ctx.addPath(thumbpath.cgPath)
            ctx.strokePath()
            
            if highlighted {
                ctx.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
                ctx.addPath(thumbpath.cgPath)
                ctx.fillPath()
            }
        }
    }
    
}


class RangeSliderTrackLayer: CALayer {
    weak var rangeSlider: RangeSlider?
    
    override func draw(in ctx: CGContext) {
        if let slider = rangeSlider {
            //Clip
            let cornerRadius = bounds.height * slider.curvaceousness / 2.0
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            ctx.addPath(path.cgPath)
            
            //Fill the track
            ctx.setFillColor(slider.trackTintColor.cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
            
            //fill the highlighted range
            ctx.setFillColor(slider.trackHighlightTintColor.cgColor)
            
            let lowerValuePosition = CGFloat(slider.positionForValue(value: slider.lowerValue))
            let upperValuePosition = CGFloat(slider.positionForValue(value: slider.upperValue))
            
            let rect = CGRect(x: lowerValuePosition, y: 0.0, width: upperValuePosition - lowerValuePosition, height: bounds.height)
            ctx.fill(rect)
        }
    }
}





