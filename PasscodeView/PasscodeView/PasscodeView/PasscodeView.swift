//
//  PasscodeView.swift
//  PassCodeView
//
//  Created by Jagtap, Amol on 11/16/16.
//  Copyright © 2016 Amol Jagtap. All rights reserved.
//

import UIKit

/// Responds to key press event in PasscodeView.
/// Triggers a delegate method when user eneter or delete a digit
protocol PasscodeViewDelegate: class {
    /// Returns a pin when user pressed the key
    ///
    /// - parameter inputView: PasscodeView object
    /// - parameter text: input text of PasscodeView
    func passcodeView(view: PasscodeView, didPressedKey text: String)
}


@IBDesignable class PasscodeView: UIView {
    weak var delegate: PasscodeViewDelegate?
    
    /// set keyboard appearance
    var keyboardAppearance:UIKeyboardAppearance = .dark
    
    /// Set keyboard type numberPad
    var keyboardType:UIKeyboardType = .numberPad {
        didSet{
            text = ""
        }
    }
    
    private(set) var myItems = [String]()
    
    /// The stack view holding all the labels
    fileprivate lazy var stackView:UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 10.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    /// Tap gesture to handle tap event
    private lazy var tap:UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(PasscodeView.handleTapEvent(_:)))
        return tap
    }()
    
    
    /// Add Done button on keyboard to dismiss the number pad
    fileprivate lazy var doneBarView:UIView = {
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done,
                                              target: self, action: #selector(doneButtonClicked))
        let space = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
                                         target: self, action: nil)
        toolbarDone.items = [space,barBtnDone]
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 40))
        view.addSubview(toolbarDone)
        return view
    }()
    
    /// input text - concat the text of all labels
    fileprivate var inputSecureText:String = ""
    
    //input text returns text(pin) entered by the user
    @IBInspectable var text:String {
        get {
            return inputSecureText
        }
        set{
            let newText = newValue.trimmingCharacters(in: CharacterSet.whitespaces)
            if newText.characters.count == 0 {
                inputSecureText = newText
                for (index, label) in stackView.arrangedSubviews.enumerated() {
                    if index < pinDigitLength {
                        if let label = label as? PasscodeLabel {
                            label.text = ""
                        }
                    }
                }
            }
            else {
                for (index, label) in stackView.arrangedSubviews.enumerated() {
                    if index < newValue.characters.count {
                        if let label = label as? PasscodeLabel {
                            label.text = "*"
                            inputSecureText.append(newValue[index])
                        }
                    }
                }
            }
        }
    }
    
    /// The number of pin digits
   @IBInspectable var pinDigitLength:Int = 0 {
        willSet{
            updateNumberOfPinDigits(newValue: newValue)
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    /// set text color of labels
    @IBInspectable var textColor:UIColor = UIColor.darkGray {
        didSet{
            for label in stackView.arrangedSubviews {
                if let label = label as? PasscodeLabel {
                    label.textColor = textColor
                }
            }
        }
    }
    
    /// set border line color of labels
   @IBInspectable var borderLineColor:UIColor = UIColor.darkGray {
        didSet{
            for label in stackView.arrangedSubviews {
                if let label = label as? PasscodeLabel {
                   label.borderColor = borderLineColor
                    label.setNeedsDisplay()
                }
            }
        }
    }
    
    /// Set text entry secure - default is true
    var isSecureText: Bool = true
    
    /// flag to know if shake animation is running or not
    fileprivate var isShakeAnimationRunning = false
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    /// Configures the view
    private func configure() {
        addSubview(stackView)
        
        leadingAnchor.constraint(greaterThanOrEqualTo: stackView.leadingAnchor).isActive = true
        stackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
        trailingAnchor.constraint(greaterThanOrEqualTo: stackView.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        addGestureRecognizer(tap)
    }
    
    
    @objc private func doneButtonClicked(){
        _ = resignFirstResponder()
    }
    
    @objc private func handleTapEvent(_ sender:UITapGestureRecognizer){
        becomeFirstResponder()
    }
    
    /// updates the number labels in stackview based on pinDigitLength
    ///
    /// - parameter newValue: length of pin
    private func updateNumberOfPinDigits(newValue: Int) {
        let difference = newValue - pinDigitLength
        guard difference != 0 else {
            return
        }
        // reset passcode
        text = ""
        let animationTime: TimeInterval = (self.superview != nil ? 0.3 : 0.0)
        if difference > 0 {
            //Add labels
            UIView.animate(withDuration: animationTime, animations: { [unowned self] in
                for _ in (self.stackView.arrangedSubviews.count + 1)...newValue {
                    self.stackView.addArrangedSubview(self.getLabel())
                }
            })
        } else {
            //Remove labels
            let trimmingIndex = stackView.arrangedSubviews.count + difference
            UIView.animate(withDuration: animationTime, animations: { [unowned self] in
                for i in trimmingIndex..<self.stackView.arrangedSubviews.count {
                    self.stackView.arrangedSubviews[i].removeFromSuperview()
                }
            })
        }
    }
    
    /// Crates a custom subview (UILabel)
    ///
    /// - parameter text: The index of the label
    ///
    /// - returns: return a custom UILabel
    private func getLabel() -> UILabel {
        let label = PasscodeLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        return label
    }
    
    
    /// Shake view and clear the text of label after animation
    ///
    /// - parameter count:       shake animation count of view
    /// - parameter duration:    animation duration
    /// - parameter translation: Defines the value the receiver uses to perform relative interpolation.
    func shakeInputView(count : Float? = nil,for duration : TimeInterval? = nil,withTranslation translation : Float? = nil) {
        isShakeAnimationRunning = true
        shake(view: self, count: count, for: duration, withTranslation: translation, completion: { [unowned self] in
            self.isShakeAnimationRunning = false
            self.text = ""
        })
    }
    /// shake uiview with animation
    ///
    /// - parameter view:        view on which shake animation will be performed
    /// - parameter count:       count to shake view
    /// - parameter duration:    animation duration
    /// - parameter translation: Defines the value the receiver uses to perform relative interpolation.
    /// - parameter completion:  completion block to tell animation finished
    private func shake(view:UIView, count : Float? = nil,for duration : TimeInterval? = nil,withTranslation translation : Float? = nil, completion:@escaping (()->())) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.1
        animation.repeatCount = count ?? 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 30, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 30, y: self.center.y))
        self.layer.add(animation, forKey: "position")
        let fireTime = animation.duration + 0.5
        delay(fireTime) {
            completion()
        }
    }
    
    fileprivate func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
}

// MARK: - UIKeyInputProtocol Delegate
extension PasscodeView: UIKeyInput{
    
    ///pressed key on keyboard
    func insertText(_ text: String) {
        if !isShakeAnimationRunning {
            if inputSecureText.characters.count < pinDigitLength {
                if let label = stackView.arrangedSubviews[safe:inputSecureText.characters.count] as? PasscodeLabel {
                    label.text = text
                    inputSecureText.append(text)
                    if isSecureText {
                        delay(0.2, closure: {
                            label.text = "*"
                        })
                    }
                    delegate?.passcodeView(view: self, didPressedKey: inputSecureText)
                }
            }
        }
    }
    
    /// pressed delete key on keyboard
    func deleteBackward() {
        if let label = (stackView.arrangedSubviews[safe:inputSecureText.characters.count-1] as? PasscodeLabel), let text = label.text {
            if text.characters.count > 0 {
                label.text = ""
            }
            inputSecureText.characters.removeLast()
            delegate?.passcodeView(view: self, didPressedKey: inputSecureText)
        }
    }
    
    /// input accessory view for keyboard
    override var inputAccessoryView: UIView?{
        return doneBarView
    }
    
    /// set view first responder
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    /// returns true if textcontainer has text
    var hasText: Bool {
        if inputSecureText.characters.count > 0 {
            return true
        }
        return false
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}

extension String {
    /// Returns the character at the specified index if it is within bounds, otherwise empty string.
    subscript(i: Int) -> String {
        guard i >= 0 && i < characters.count else { return "" }
        return String(self[index(startIndex, offsetBy: i)])
    }
}
