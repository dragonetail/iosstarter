import UIKit
import Photos
import PureLayout
import SwipeSelectingCollectionView2


protocol PhotoGalleryViewDataSource {
    func numberOfSections() -> Int
    func numberOfSection(_ section: Int) -> Int
    func titleOfSection(_ section: Int) -> String
    func initialIndexPath() -> IndexPath
    func image(_ indexPath: IndexPath) -> Image
}

protocol PhotoGalleryViewDelegate {
    func didSelectImage(_ photoGalleryView: PhotoGalleryView, dataSource: PhotoGalleryViewDataSource?, indexPath: IndexPath)
}

class PhotoGalleryView: UIView {
    //控件
    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let loadingIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        loadingIndicatorView.color = .gray
        loadingIndicatorView.isHidden = false
        loadingIndicatorView.hidesWhenStopped = true
        //loadingIndicatorView._roundBorder()
        //loadingIndicatorView._shadow()

        return loadingIndicatorView
    }()

    private lazy var topView: UIView = {
        let topView = UIView()
        topView.backgroundColor = UIColor.white

        return topView
    }()

    internal lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()

        let columnCount: CGFloat = 3
        let cellSpacing: CGFloat = 1
        let size = (UIScreen.main.bounds.width - 2 - (columnCount - 1) * cellSpacing) / columnCount

        layout.itemSize = CGSize(width: size, height: size)
        //         layout.itemSize = CGSize(width: 150, height: 150)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        //layout.footerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 5)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)


        let collectionView = SwipeSelectingCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.allowsMultipleSelection = true

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.register(HeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCell.identifier)

        //collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 10)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false

        return collectionView
    }()
    private lazy var scrollSlider: ScrollSlider = {
        let scrollSlider = ScrollSlider(collectionView)
        scrollSlider.isHidden = true

        return scrollSlider
    }()



    private lazy var emptyView: UIView = {
        let view = EmptyView()
        view.isHidden = true

        return view
    }()

    private var dataSource: PhotoGalleryViewDataSource?
    private var delegate: PhotoGalleryViewDelegate?
    private var albumListButton: AlbumListButton?

    // 初始化
    func setup(delegate: PhotoGalleryViewDelegate?, albumListButton: AlbumListButton?) {
        self.delegate = delegate

        self.albumListButton = albumListButton
        if let albumListButton = albumListButton {
            topView.addSubview(albumListButton)
        }

        backgroundColor = .white

        [collectionView, scrollSlider, topView, emptyView, loadingIndicatorView].forEach {
            addSubview($0)
        }
        loadingIndicatorView.startAnimating()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        topView.autoSetDimension(.height, toSize: 40)
        topView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)

        albumListButton?.autoSetDimension(.height, toSize: 40)
        albumListButton?.autoCenterInSuperview()
        albumListButton?.layoutSubviews()

        [collectionView, emptyView, loadingIndicatorView].forEach { subview in
            subview.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
            subview.autoPinEdge(.top, to: .bottom, of: topView, withOffset: 0.0)
        }
    }

    internal func insertAlbumListControllerView(_ albumListControllerView: UIView) -> (expandedTopConstraint: NSLayoutConstraint, collapsedTopConstraint: NSLayoutConstraint) {

        insertSubview(albumListControllerView, belowSubview: loadingIndicatorView)

        albumListControllerView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .top)
        let expandedTopConstraint = albumListControllerView.autoPinEdge(.top, to: .bottom, of: topView, withOffset: 0.0)
        expandedTopConstraint.isActive = false
        let collapsedTopConstraint = albumListControllerView.autoPinEdge(.top, to: .bottom, of: albumListControllerView)
        collapsedTopConstraint.isActive = true

        return (expandedTopConstraint: expandedTopConstraint, collapsedTopConstraint: collapsedTopConstraint)
    }


    internal func update(_ dataSource: PhotoGalleryViewDataSource) {
        loadingIndicatorView.startAnimating()
        
        self.dataSource = dataSource

        let numberOfSections = self.dataSource?.numberOfSections() ?? 0
        emptyView.isHidden = (numberOfSections > 0)

        collectionView.reloadData()

        loadingIndicatorView.stopAnimating()
    }
}


extension PhotoGalleryView: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.dataSource?.numberOfSections() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfSection(section) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell

        guard let dataSource = self.dataSource else {
            return cell
        }

        let image = dataSource.image(indexPath)

        //TODO 统一Viewer部分Image的取法
        cell.configure(image)

        return cell
    }


    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            //print("HEADER DETECTED");//CALLED
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:
                HeaderCell.identifier, for: indexPath) as! HeaderCell

            let title = self.dataSource?.titleOfSection(indexPath.section) ?? "UNKNOWN"
            header.configure(title, delegate: self)
            return header
        case UICollectionView.elementKindSectionFooter:
            print("FOOTER DETECTED");//NEVER CALLED
            break;
        default:
            print("DEFAULT DETECTED");//NEVER CALLED
            break;
        }

        return UICollectionReusableView();
    }
}

extension PhotoGalleryView: SwipeUICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtByTapped indexPath: IndexPath) {
        self.delegate?.didSelectImage(self, dataSource: dataSource, indexPath: indexPath)
    }
}

extension PhotoGalleryView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    }
}

extension PhotoGalleryView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollSlider.dragAndScrollView()

        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint),
            let dataSource = self.dataSource
            else { return }

        let title = dataSource.titleOfSection(indexPath.section)
        self.scrollSlider.updateScrollLabel(title)
    }
}

extension PhotoGalleryView: SectionSelectedDelegate {
    func didSelectSection(_ headerCell: HeaderCell) {
        //查找HeaderCell对应的IndexPath
        let indexPaths = self.collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader)

        var foundedIndexPath: IndexPath?
        for indexPath in indexPaths {
            if headerCell == collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) {
                print("found at : \(indexPath)")
                foundedIndexPath = indexPath
                break
            }
        }

        guard let indexPath = foundedIndexPath else {
            print("ERROR: 没有发现HeaderCell的indexPath")
            return
        }

        headerCell.isSelected = !headerCell.isSelected

        let sectionIndex = indexPath.section
        let size = collectionView.numberOfItems(inSection: indexPath.section)
        collectionView.performBatchUpdates({
            for rowIndex in 0..<size {
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                if headerCell.isSelected {
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                } else {
                    collectionView.deselectItem(at: indexPath, animated: false)
                }
            }
        })
    }
}

