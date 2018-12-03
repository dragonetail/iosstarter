import UIKit
import PureLayout

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


class ImageViewController: UIViewController {
    var dataSource: ImageViewDataSource?
    var exitProcesser: ((IndexPath)->Void)?
    
    lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal

        var imageCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(ImageViewCell.self, forCellWithReuseIdentifier: "Cell")
        imageCollectionView.isPagingEnabled = true
        
        if let initialIndexPath = dataSource?.initialIndexPath(){
            imageCollectionView.scrollToItem(at: initialIndexPath, at: .left, animated: false)
        }

        imageCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))

        return imageCollectionView
    }()

    lazy var imageViewHeader: UIView = {
        let imageViewHeader = ImageViewHeader()
        imageViewHeader.viewDelegate = self

        imageViewHeader.translatesAutoresizingMaskIntoConstraints = false
        imageViewHeader.alpha = 1

        return imageViewHeader
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        //self.view._roundBorder()

        [imageCollectionView, imageViewHeader].forEach {
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

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        imageViewHeader.autoSetDimension(.height, toSize: 64)
        imageViewHeader.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)

        guard let flowLayout = imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.itemSize = imageCollectionView.frame.size
        flowLayout.invalidateLayout()

        imageCollectionView.collectionViewLayout.invalidateLayout()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let offset = imageCollectionView.contentOffset
        let width = imageCollectionView.bounds.size.width

        let index = round(offset.x / width)
        let newOffset = CGPoint(x: index * size.width, y: offset.y)

        imageCollectionView.setContentOffset(newOffset, animated: false)

        coordinator.animate(alongsideTransition: { (context) in
            self.imageCollectionView.reloadData()

            self.imageCollectionView.setContentOffset(newOffset, animated: false)
        }, completion: nil)
    }

    //隐藏状态栏
    override var prefersStatusBarHidden: Bool {
        return true
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

    @objc func handleSlightTap(recognizer: UITapGestureRecognizer) {
        imageViewHeader.isHidden = !imageViewHeader.isHidden
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
        
        guard let dataSource = dataSource else{
            return cell
        }
       
        let image = dataSource.image(indexPath)
        //TODO 追加进度控制
        //cell.imageView.image = UIImage()
        image.resolve(completion: { (uiImage) in
            cell.imageView.image = uiImage
            cell.setNeedsDisplay()
        })

        return cell
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
        guard let dataSource = dataSource else{
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
        
        guard let dataSource = dataSource else{
            return
        }
        
        if let indexPath = imageCollectionView.indexPathsForVisibleItems.first {
            self.exitProcesser?(dataSource.originalIndexPath(indexPath))
        }
    }

    func headerView(_: ImageViewHeader, didPressMenuButton button: UIButton) {
        //        let rect = CGRect(x: 0, y: 0, width: 50, height: 50)
        //        self.optionsController = OptionsController(sourceView: button, sourceRect: rect)
        //        self.optionsController!.delegate = self
        //        self.viewerController?.present(self.optionsController!, animated: true, completion: nil)
    }
}


