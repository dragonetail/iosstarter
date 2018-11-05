import UIKit

extension UIScrollView {

  func _scrollToTop() {
    setContentOffset(CGPoint.zero, animated: false)
  }

  func _updateBottomInset(_ value: CGFloat) {
    var inset = contentInset
    inset.bottom = value

    contentInset = inset
    scrollIndicatorInsets = inset
  }
    
}
