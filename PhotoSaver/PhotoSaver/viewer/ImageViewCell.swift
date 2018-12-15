import UIKit
import ImageIOSwift_F2

class ImageViewCell: UICollectionViewCell {

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView().autoresizingMask("scrollView")
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.flashScrollIndicators()

        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0

        let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapScrollView(recognizer:)))
        doubleTapGest.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGest)

        scrollView.addSubview(imageSourceView)
        return scrollView
    }()
    lazy var imageSourceView: ImageSourceView = {
        let imageSourceView = ImageSourceView().autoresizingMask("imageSourceView")
        imageSourceView.contentMode = .scaleAspectFit
        return imageSourceView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        _ = self.autoresizingMask("ImageViewCell")

        setupAndComposeView()

        // bootstrap Auto Layout
        self.setNeedsUpdateConstraints()
    }
    func setupAndComposeView() {
        self.addSubview(scrollView)
    }

    override func layoutSubviews() {
        scrollView.frame = self.bounds
        imageSourceView.frame = self.bounds

        super.layoutSubviews()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
    }

    @objc func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            let zoomRect = zoomRectForScale(scale: scrollView.maximumZoomScale, center: recognizer.location(in: recognizer.view))
            scrollView.zoom(to: zoomRect, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }

    fileprivate func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageSourceView.frame.size.height / scale
        zoomRect.size.width = imageSourceView.frame.size.width / scale
        let newCenter = imageSourceView.convert(center, from: scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageSourceView
    }

}
