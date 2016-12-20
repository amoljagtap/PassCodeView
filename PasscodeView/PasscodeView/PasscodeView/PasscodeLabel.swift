//
//  PasscodeLabel.swift
//  PassCodeView
//
//  Created by Jagtap, Amol on 11/16/16.
//  Copyright © 2016 Amol Jagtap. All rights reserved.
//

import UIKit

class PasscodeLabel: UILabel {

    var borderWidth:CGFloat = 1.0
    var borderColor:UIColor = UIColor.darkGray
    private var defaultFontSize:CGFloat = 30.0
    
    static func idiomScaleFactor() -> CGFloat {
        let idiom = UIDevice.current.userInterfaceIdiom
        if idiom == .phone {
            return 1.0
        } else if idiom == .pad {
            return 1.5
        }
        return 1.0
    }
    
    /// The size of a label element
    private var elementSize:CGSize? = {
        return CGSize(width: (30 * PasscodeLabel.idiomScaleFactor()), height: 30 * PasscodeLabel.idiomScaleFactor())
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        let bezier = UIBezierPath()
        bezier.move(to: CGPoint(x: rect.origin.x, y: rect.size.height - borderWidth))
        bezier.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height - borderWidth))
        bezier.lineWidth = borderWidth
        borderColor.setStroke()
        bezier.stroke()
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    private func configure(){
        textColor = UIColor.darkGray
        textAlignment = .center
        numberOfLines = 0
        
        let idiom = UIDevice.current.userInterfaceIdiom
        if idiom == .phone {
            defaultFontSize = 30.0
        } else if idiom == .pad {
            defaultFontSize = 45
        }
        
        font = UIFont.systemFont(ofSize: defaultFontSize)
        
        setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .vertical)
        setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .horizontal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustsFontSizeToFitWidth = true
        //minimum font size should be 14 pt
        minimumScaleFactor = defaultFontSize / font.pointSize
    }
    
    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        return elementSize ?? superSize
    }

}
