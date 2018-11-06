import UIKit
import PureLayout

class ImageViewController: UIViewController {
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
        if self.album.count > 1 {
            //循环模式设置，如果多于一个元素，处理Dummy区
            let targetIndex = IndexPath(row: initialIndexPath.row, section: initialIndexPath.section + 1)
            imageCollectionView.scrollToItem(at: targetIndex, at: .left, animated: false)
        } else {
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


    let album: Album
    let initialIndexPath: IndexPath //循环模式设置，前后插入一个Dummy的区和一个元素

    init(album: Album, initialIndexPath: IndexPath) {
        self.album = album
        self.initialIndexPath = initialIndexPath

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        //self.view._roundBorder()

        [imageCollectionView, imageViewHeader].forEach {
            self.view.addSubview($0)
        }
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
}

extension ImageViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.album.count == 1 { //只有一个元素不需要
            return 1
        }

        //循环模式设置，前后插入一个Dummy的区和一个元素，因此总数加2
        return self.album.sections.count + 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.album.count == 1 { //只有一个元素不需要
            return 1
        }

        //循环模式设置，前后插入一个Dummy的区和一个元素，判断是否为插入的Dummy区
        if section == 0 || section == self.album.sections.count + 1 {
            return 1
        }

        return album.sections[section - 1].images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Infinite Logic, The first and last section are dummy
        let section = indexPath.section
        //真实相册数据中的坐标
        var targetIndexPath = indexPath
        if self.album.count > 1 { //只有一个元素不需要
            if section == 0 {
                //循环模式设置，头Dummy区，内容为最后一个图片
                targetIndexPath = IndexPath(row: album.sections[album.sections.count - 1].count - 1, section: self.album.sections.count - 1)
            } else if section == self.album.sections.count + 1 {
                //循环模式设置，尾Dummy区，内容为第一个图片
                targetIndexPath = IndexPath(row: 0, section: 0)
            } else {
                targetIndexPath = IndexPath(row: indexPath.row, section: indexPath.section - 1)
            }
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageViewCell
        let image = album.getImage(targetIndexPath)
        cell.imageView.image = UIImage()
        image.resolve(completion: { (uiImage) in
            cell.imageView.image = uiImage
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
        if self.album.count == 1 { //只有一个元素不需要
            return
        }

        //循环模式设置，计算循环滚动
        let fullyScrolledContentOffset: CGFloat = scrollView.frame.size.width * CGFloat(album.count)
        if (scrollView.contentOffset.x > fullyScrolledContentOffset) {
            let indexPath: IndexPath = IndexPath(row: 0, section: 1)
            imageCollectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        } else if (scrollView.contentOffset.x < scrollView.frame.size.width) {
            let indexPath: IndexPath = IndexPath(row: album.sections[album.sections.count - 1].count - 1, section: album.sections.count)
            imageCollectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        }
    }
}

extension ImageViewController: ImageViewHeaderDelegate {

    func headerView(_: ImageViewHeader, didPressClearButton _: UIButton) {
        self.dismiss(animated: true)
    }

    func headerView(_: ImageViewHeader, didPressMenuButton button: UIButton) {
        //        let rect = CGRect(x: 0, y: 0, width: 50, height: 50)
        //        self.optionsController = OptionsController(sourceView: button, sourceRect: rect)
        //        self.optionsController!.delegate = self
        //        self.viewerController?.present(self.optionsController!, animated: true, completion: nil)
    }
}


