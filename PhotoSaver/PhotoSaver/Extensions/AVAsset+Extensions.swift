import UIKit
import AVFoundation

extension AVAsset {

  fileprivate var _naturalSize: CGSize {
    return tracks(withMediaType: AVMediaType.video).first?.naturalSize ?? .zero
  }

  var _correctSize: CGSize {
    return _isPortrait ? CGSize(width: _naturalSize.height, height: _naturalSize.width) : _naturalSize
  }

  var _isPortrait: Bool {
    let portraits: [UIInterfaceOrientation] = [.portrait, .portraitUpsideDown]
    return portraits.contains(_orientation)
  }

  var _fileSize: Double {
    guard let avURLAsset = self as? AVURLAsset else { return 0 }

    var result: AnyObject?
    try? (avURLAsset.url as NSURL).getResourceValue(&result, forKey: URLResourceKey.fileSizeKey)

    if let result = result as? NSNumber {
      return result.doubleValue
    } else {
      return 0
    }
  }

  var _frameRate: Float {
    return tracks(withMediaType: AVMediaType.video).first?.nominalFrameRate ?? 30
  }

  // Same as UIImageOrientation
  var _orientation: UIInterfaceOrientation {
    guard let transform = tracks(withMediaType: AVMediaType.video).first?.preferredTransform else {
      return .portrait
    }

    switch (transform.tx, transform.ty) {
    case (0, 0):
      return .landscapeRight
    case (_naturalSize.width, _naturalSize.height):
      return .landscapeLeft
    case (0, _naturalSize.width):
      return .portraitUpsideDown
    default:
      return .portrait
    }
  }

  // MARK: - Description

  var _videoDescription: CMFormatDescription? {
    guard let object = tracks(withMediaType: AVMediaType.video).first?.formatDescriptions.first else {
      return nil
    }

    return (object as! CMFormatDescription)
  }

  var _audioDescription: CMFormatDescription? {
    guard let object = tracks(withMediaType: AVMediaType.audio).first?.formatDescriptions.first else {
      return nil
    }

    return (object as! CMFormatDescription)
  }
}
