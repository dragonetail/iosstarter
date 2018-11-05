import Foundation

extension String {

  func _localize(fallback: String) -> String {
    let string = NSLocalizedString(self, comment: "")
    return string == self ? fallback : string
  }
    
}
