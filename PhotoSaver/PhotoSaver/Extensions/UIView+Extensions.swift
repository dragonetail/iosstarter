import UIKit

extension UIView {
    func autoLayout(_ accessibilityIdentifier: String? = nil) -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false;
        if let accessibilityIdentifier = accessibilityIdentifier {
            self.accessibilityIdentifier = accessibilityIdentifier
        }
        return self
    }
    
    func autoresizingMask(_ accessibilityIdentifier: String? = nil) -> Self {
        self.translatesAutoresizingMaskIntoConstraints = true;
        if let accessibilityIdentifier = accessibilityIdentifier {
            self.accessibilityIdentifier = accessibilityIdentifier
        }
        return self
    }
    
    func autoPrintConstraints() {
        #if DEBUG
        self.constraints.forEach { (constraint) in
            print(String(describing: constraint))
        }
        #endif
    }
    
    func autoRoundBorder(_ color: UIColor = UIColor.purple) {
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
        layer.cornerRadius = 3
        clipsToBounds = true
    }
    
    func autoShadow(_ color: UIColor = UIColor.black) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 1
    }


    func quickFade(_ visible: Bool = true) {
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = visible ? 1 : 0
        })
    }

    func fade(_ visible: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = visible ? 1 : 0
        })
    }
    
    func hide() {
        fade(false)
    }
    
    func show() {
        fade(true)
    }
}
