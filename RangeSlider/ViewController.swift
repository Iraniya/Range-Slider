//
//  ViewController.swift
//  RangeSlider
//
//  Created by Iraniya Naynesh on 28/03/18.
//  Copyright © 2018 Iraniya Naynesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let rangeSlider = RangeSlider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rangeSlider.backgroundColor = UIColor.clear
        rangeSlider.trackHighlightTintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        rangeSlider.trackTintColor = #colorLiteral(red: 0.1333333333, green: 0.1294117647, blue: 0.1882352941, alpha: 1)
        view.addSubview(rangeSlider)
        rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged), for: .valueChanged)
        
    }
    
    override func viewDidLayoutSubviews() {
        let margin: CGFloat = 20.0
        let width = view.bounds.width - 2.0 * margin
        rangeSlider.frame = CGRect(x: margin, y: margin + 50,
                                   width: width, height: 31.0)
    }
    
    @objc func rangeSliderValueChanged(rangeSlider: RangeSlider) {
        print("Range slider value changed: (\(rangeSlider.lowerValue) \(rangeSlider.upperValue))")
    }
    
}

