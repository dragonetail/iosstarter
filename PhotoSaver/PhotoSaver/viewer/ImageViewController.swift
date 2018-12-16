import UIKit
import PureLayout
import DataCompression
import SwiftBaseBootstrap

protocol ImageViewDataSource {
    func totalCount() -> Int
    func numberOfSections() -> Int
    func numberOfSection(_ section: Int) -> Int
    func titleOfSection(_ section: Int) -> String
    func initialIndexPath() -> IndexPath
    func image(_ indexPath: IndexPath) -> Image
    func lastIndexPath() -> IndexPath
    func originalIndexPath(_ indexPath: IndexPath) -> IndexPath
}

class ImageViewController: BaseViewControllerWithAutolayout {
    var dataSource: ImageViewDataSource?
    var imageViewerSupportDelegate: ImageViewerSupportDelegate?
    var exitProcesser: ((IndexPath) -> Void)?

    lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal

        var imageCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout).autoLayout("imageCollectionView")
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(ImageViewCell.self, forCellWithReuseIdentifier: "Cell")
        imageCollectionView.isPagingEnabled = true
        imageCollectionView.showsHorizontalScrollIndicator = false
        imageCollectionView.showsVerticalScrollIndicator = false

        if let initialIndexPath = dataSource?.initialIndexPath() {
            imageCollectionView.scrollToItem(at: initialIndexPath, at: .left, animated: false)
        }

        imageCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))

        return imageCollectionView
    }()

    lazy var imageViewHeader: UIView = {
        let imageViewHeader = ImageViewHeader().autoLayout("imageViewHeader")
        imageViewHeader.viewDelegate = self

        imageViewHeader.translatesAutoresizingMaskIntoConstraints = false
        imageViewHeader.alpha = 1

        return imageViewHeader
    }()

    lazy var imageViewFooter: UIView = {
        let imageViewFooter = ImageViewFooter().autoLayout("imageViewFooter")
        imageViewFooter.viewDelegate = self

        imageViewFooter.translatesAutoresizingMaskIntoConstraints = false
        imageViewFooter.alpha = 1

        return imageViewFooter
    }()
    lazy var imageInfoView: ImageInfoView = {
        let imageInfoView = ImageInfoView().autoLayout("imageInfoView")

        //imageInfoView.alpha = 0.9
        imageInfoView.isHidden = true
        return imageInfoView
    }()

    //隐藏状态栏
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func setupAndComposeView() {
        self.title = "相册播放器"
        self.view.backgroundColor = UIColor.black
        //self.view._roundBorder()

        [imageCollectionView, imageViewHeader, imageViewFooter, imageInfoView].forEach {
            self.view.addSubview($0)
        }

        [UISwipeGestureRecognizer.Direction.right,
            UISwipeGestureRecognizer.Direction.left,
            UISwipeGestureRecognizer.Direction.up,
            UISwipeGestureRecognizer.Direction.down].forEach({ direction in
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handSwipe))
            swipe.direction = direction
            self.view.addGestureRecognizer(swipe)
        })

        let slightTapGest = UITapGestureRecognizer(target: self, action: #selector(handleSlightTap))
        slightTapGest.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(slightTapGest)

        let longpressGestrue = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        longpressGestrue.minimumPressDuration = 1
        longpressGestrue.numberOfTouchesRequired = 1
        longpressGestrue.allowableMovement = 15
        self.view.addGestureRecognizer(longpressGestrue)

        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .left
        view.addGestureRecognizer(edgePan)
    }

    fileprivate var isFullImageCollectionViewLayout: Bool = true
    fileprivate var dynamicConstraints: [String: NSArray] = [String: NSArray]()
    override func setupConstraints() {
        imageViewHeader.autoSetDimension(.height, toSize: 64)
        imageViewHeader.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)

        imageViewFooter.autoSetDimension(.height, toSize: 64)
        let padding = UIScreen.main.bounds.width / 10
        imageViewFooter.autoPinEdge(toSuperviewEdge: .left, withInset: padding)
        imageViewFooter.autoPinEdge(toSuperviewEdge: .right, withInset: padding)
        imageViewFooter.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0)

        do {
            let orientation = "landscape"
            dynamicConstraints["\(orientation).small"] = NSLayoutConstraint.autoCreateConstraintsWithoutInstalling {
                imageCollectionView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .left)
                imageCollectionView.autoMatch(.width, to: .width, of: self.view, withMultiplier: 0.67)
            } as NSArray

            dynamicConstraints["\(orientation).full"] = NSLayoutConstraint.autoCreateConstraintsWithoutInstalling {
                imageCollectionView.autoPinEdgesToSuperviewEdges()
            } as NSArray

            dynamicConstraints["\(orientation).imageInfo"] = NSLayoutConstraint.autoCreateConstraintsWithoutInstalling {
                imageInfoView.autoPinEdge(.right, to: .left, of: imageCollectionView)
                imageInfoView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .right)
            } as NSArray
        }

        do {
            let orientation = "portrait"
            dynamicConstraints["\(orientation).small"] = NSLayoutConstraint.autoCreateConstraintsWithoutInstalling {
                imageCollectionView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
                imageCollectionView.autoMatch(.height, to: .height, of: self.view, withMultiplier: 0.33)
            } as NSArray

            dynamicConstraints["\(orientation).full"] = NSLayoutConstraint.autoCreateConstraintsWithoutInstalling {
                imageCollectionView.autoPinEdgesToSuperviewEdges()
            } as NSArray

            dynamicConstraints["\(orientation).imageInfo"] = NSLayoutConstraint.autoCreateConstraintsWithoutInstalling {
                imageInfoView.autoPinEdge(.top, to: .bottom, of: imageCollectionView)
                imageInfoView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
            } as NSArray
        }
    }

    override func modifyConstraints() {
        var orientation = "portrait"
        if OrientationUtils.isLandscape() {
            orientation = "landscape"
        }

        dynamicConstraints.forEach { (_: String, constraints: NSArray) in
            constraints.autoRemoveConstraints()
        }

        if isFullImageCollectionViewLayout {
            dynamicConstraints["\(orientation).full"]?.autoInstallConstraints()
        } else {
            dynamicConstraints["\(orientation).small"]?.autoInstallConstraints()
        }
        dynamicConstraints["\(orientation).imageInfo"]?.autoInstallConstraints()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition( to: size, with: coordinator)
        
        let originalWidth = self.imageCollectionView.frame.size.width
        coordinator.animate(alongsideTransition: { (context) in
            self.transitionUpdate(originalWidth)
        }, completion: nil)
    }

    fileprivate func transitionUpdate(_ _originalWidth: CGFloat? = nil) {
        let originalWidth = _originalWidth ?? self.imageCollectionView.frame.size.width
        let offset = imageCollectionView.contentOffset
        let index = round(offset.x / originalWidth )
        
//        if let toFrameSize = toFrameSize {
//            self.view.frame.size = toFrameSize
//        }

        self.view.setNeedsUpdateConstraints()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        let newOffset = CGPoint(x: index * self.imageCollectionView.frame.width, y: offset.y)
        self.imageCollectionView.reloadData()
        self.imageCollectionView.setContentOffset(newOffset, animated: false)
    }

    @objc func handleSlightTap(recognizer: UITapGestureRecognizer) {
        if imageInfoView.isHidden == false {
            toggleImageInfoView()
        } else {
            toggleimageViewHeaderAndFooter(!imageViewHeader.isHidden)
        }
    }
    fileprivate func toggleimageViewHeaderAndFooter(_ visible: Bool) {
        if visible {
            self.imageViewHeader.isHidden = false
            self.imageViewFooter.isHidden = false
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.imageViewHeader.alpha = visible ? 1 : 0
            self.imageViewFooter.alpha = visible ? 1 : 0
        }, completion: { [weak self] _ in
            if !visible {
                self?.imageViewHeader.isHidden = true
                self?.imageViewFooter.isHidden = true
            }
        })
    }
    fileprivate func toggleImageInfoView() {
        isFullImageCollectionViewLayout = !isFullImageCollectionViewLayout

        self.imageViewHeader.isHidden = !isFullImageCollectionViewLayout
        self.imageViewFooter.isHidden = !isFullImageCollectionViewLayout

        if isFullImageCollectionViewLayout {
            //Full the collection view and hide the info view
            UIView.animate(withDuration: 0.1, animations: {
                self.imageInfoView.alpha = 0
            }, completion: { [weak self] _ in
                self?.imageInfoView.isHidden = true
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCurlUp,
                               animations: { [weak self] in
                                   self?.transitionUpdate()
                               })
            })
        } else {
            //Small the collection view and show the info view
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .transitionCurlUp, animations: {
                self.transitionUpdate()
            }, completion: { [weak self] _ in
                self?.imageInfoView.isHidden = false
                UIView.animate(withDuration: 0.3,
                               animations: { [weak self] in
                                   self?.imageInfoView.alpha = 1
                               })
            })
        }
    }

    @objc func handSwipe(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .right:
                print("Swiped right")
            case .down:
                print("Swiped down")
                self.dismiss(animated: true)
            case .left:
                print("Swiped left")
            case .up:
                print("Swiped up")
            default:
                break
            }
        }
    }

    @objc func handleLongPressGesture(sender: UILongPressGestureRecognizer) {
        print("handleLongPressGesture: \(sender.state)")
        if sender.state == UIGestureRecognizer.State.began {
            print("----------")
        }
    }

    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            print("Screen edge swiped!")
        }
    }
}

extension ImageViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource?.numberOfSections() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfSection(section) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageViewCell

        guard let dataSource = dataSource else {
            return cell
        }

        //let originalIndexPath = dataSource.originalIndexPath(indexPath)
        //let thumbnailImage = imageViewerSupportDelegate?.getLoadedThumbnailImage(indexPath: originalIndexPath)
        let image = dataSource.image(indexPath)
        DispatchQueue.global(qos: .userInteractive).async {
            let _ = image.resolve(imageCallback: { [weak cell](imageSource) in
                cell?.imageSourceView.imageSource = imageSource
                cell?.imageSourceView.setNeedsDisplay()
            }, metadataCallback: { [weak self] (image) in
                //guard let metadata = image.metadata else {
                //   log.warning("No metadata found.")
                //   return
                //}
                //justPerformaceTest(metadata)
                //print("collectionView metadata: \(metadata.prettyJSON())")

                if let imageInfoView = self?.imageInfoView,
                    imageInfoView.isHidden == false {
                    imageInfoView.image = image
                }
            }, errorCallback: { (error) in
                log.warning("error: \(error)")
            })
        }

        //imageViewerSupportDelegate?.scrollToItem(indexPath: originalIndexPath)
        return cell
    }

    func justPerformaceTest(_ metadata: ImageMetadata) {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let jsonDecoder = JSONDecoder()
        do {
            var start = Date()
            print("")
            print("................................")
            print("")

            start = Date()
            var jsonData = try jsonEncoder.encode(metadata)
            print("jsonEncoder \(-start.timeIntervalSinceNow)s")

            for algo: Data.CompressionAlgorithm in [.zlib, .lzfse, .lz4, .lzma] {
                start = Date()
                let compressedData: Data! = jsonData.compress(withAlgorithm: algo)

                let ratio = Double(jsonData.count) / Double(compressedData.count)
                print("\(algo) \(-start.timeIntervalSinceNow)s  =>   \(compressedData.count) bytes, ratio: \(ratio)")

                start = Date()
                assert(compressedData.decompress(withAlgorithm: algo)! == jsonData)
                print("\(algo) decompress \(-start.timeIntervalSinceNow)s")
            }

            start = Date()
            let jsonString = String(data: jsonData, encoding: .utf8)
            print("jsonEncoder Str \(-start.timeIntervalSinceNow)s: \n" + jsonString!)

            start = Date()
            let metadata2 = try jsonDecoder.decode(ImageMetadata.self, from: jsonData)
            print("jsonDecoder \(-start.timeIntervalSinceNow)s: \n" + jsonString!)

            print("")
            print("................................")
            print("")

            let jsonData2 = try jsonEncoder.encode(metadata2)
            let jsonString2 = String(data: jsonData2, encoding: .utf8)
            print("JSON2 String : \n" + jsonString2!)

            print("")
            print("................................")
            print("")
        }
        catch {
            log.error("数据JSON化失败。")
        }

    }
}
extension ImageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension ImageViewController: UICollectionViewDelegate {
}

extension ImageViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        guard let dataSource = dataSource else {
            return
        }

        let totalCount = dataSource.totalCount()
        if totalCount <= 1 { //只有一个元素不需要
            return
        }

        //循环模式设置，计算循环滚动
        let fullyScrolledContentOffset: CGFloat = scrollView.frame.size.width * CGFloat(totalCount)
        if (scrollView.contentOffset.x > fullyScrolledContentOffset) {
            imageCollectionView.scrollToItem(at: IndexPath(row: 0, section: 1), at: .left, animated: false)
        } else if (scrollView.contentOffset.x < scrollView.frame.size.width) {
            imageCollectionView.scrollToItem(at: dataSource.lastIndexPath(), at: .left, animated: false)
        }
    }
}

extension ImageViewController: ImageViewHeaderDelegate {
    func headerView(_: ImageViewHeader, didPressClearButton _: UIButton) {
        self.dismiss(animated: true)

        guard let dataSource = dataSource else {
            return
        }

        if let indexPath = imageCollectionView.indexPathsForVisibleItems.first {
            self.exitProcesser?(dataSource.originalIndexPath(indexPath))
        }
    }
}

extension ImageViewController: ImageViewFooterDelegate {

    func deleteDelegate(_: ImageViewFooter, _ button: UIButton) {
        self.dismiss(animated: true)

//        guard let dataSource = dataSource else {
//            return
//        }
    }

    func favoriteDelegate(_: ImageViewFooter, _ button: UIButton) {
    }

    func menueDelegate(_: ImageViewFooter, _ button: UIButton) {
    }

    func infoDelegate(_: ImageViewFooter, _ button: UIButton) {
        guard let indexPath = imageCollectionView.indexPathsForVisibleItems.first,
            let dataSource = dataSource else {
                return
        }

        let image = dataSource.image(indexPath)
        self.imageInfoView.image = image

        toggleImageInfoView()
    }
}
