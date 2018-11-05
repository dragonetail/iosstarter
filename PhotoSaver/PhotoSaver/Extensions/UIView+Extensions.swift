import UIKit

extension UIView {

    func _shadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 1
    }

    func _roundBorder() {
        layer.borderWidth = 1
        layer.borderColor = FrameView.borderColor.cgColor
        layer.cornerRadius = 3
        clipsToBounds = true
    }

    func _quickFade(_ visible: Bool = true) {
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = visible ? 1 : 0
        })
    }

    func _fade(_ visible: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = visible ? 1 : 0
        })
    }
    
    func _hide() {
        _fade(false)
    }
    
    func _show() {
        _fade(true)
    }
}
