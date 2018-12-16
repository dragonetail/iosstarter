import UIKit
import Photos
import PureLayout
import SwipeSelectingCollectionView2
import SwiftBaseBootstrap

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

protocol ImageViewerSupportDelegate {
    func getLoadedThumbnailImage(indexPath: IndexPath) -> UIImage
    func scrollToItem(indexPath: IndexPath)
}

class PhotoGalleryView: BaseViewWithAutolayout {
    //控件
    lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let loadingIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge).autoLayout("albumListButton")
        loadingIndicatorView.color = .gray
        loadingIndicatorView.isHidden = false
        loadingIndicatorView.hidesWhenStopped = true

        return loadingIndicatorView
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = SwipeSelectingCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).autoresizingMask("collectionView")
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
    lazy var scrollSlider: ScrollSlider = {
        let scrollSlider = ScrollSlider(collectionView).autoLayout("scrollSlider")
        scrollSlider.isHidden = true

        return scrollSlider
    }()

    lazy var emptyView: UIView = {
        let view = EmptyView()
        view.isHidden = true

        return view
    }()

    var dataSource: PhotoGalleryViewDataSource? {
        didSet {
            loadingIndicatorView.startAnimating()

            let numberOfSections = self.dataSource?.numberOfSections() ?? 0
            emptyView.isHidden = (numberOfSections > 0)

            collectionView.reloadData()

            loadingIndicatorView.stopAnimating()
        }
    }

    var delegate: PhotoGalleryViewDelegate?

    override func setupAndComposeView() {
        self.backgroundColor = .white

        [collectionView, scrollSlider, emptyView, loadingIndicatorView].forEach {
            addSubview($0)
        }
        loadingIndicatorView.startAnimating()
    }

    // invoked only once
    override func setupConstraints() {
        [collectionView, emptyView, loadingIndicatorView].forEach { subview in
            subview.autoPinEdgesToSuperviewEdges()
        }

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1

        let cellSpacing: CGFloat = 1
        var columnCount: CGFloat = CGFloat(floorf(Float(UIScreen.main.bounds.width / 145)))
        columnCount = columnCount < 4 ? 4 : columnCount
        columnCount = columnCount > 8 ? 8 : columnCount
        let size = (UIScreen.main.bounds.width - layout.minimumInteritemSpacing * 2 - (columnCount - 1) * cellSpacing) / columnCount
        layout.itemSize = CGSize(width: size, height: size)

        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        //layout.footerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 5)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = layout
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
        cell.layoutIfNeeded()
        cell.setImage(image)

        return cell
    }


    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            //print("HEADER DETECTED");//CALLED
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:
                HeaderCell.identifier, for: indexPath) as! HeaderCell

            let title = self.dataSource?.titleOfSection(indexPath.section) ?? "UNKNOWN"
            header.setTitleAndDelegate(title, delegate: self)
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
                foundedIndexPath = indexPath
                break
            }
        }

        guard let indexPath = foundedIndexPath else {
            log.warning("没有发现HeaderCell的indexPath")
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

extension PhotoGalleryView: ImageViewerSupportDelegate {
    func getLoadedThumbnailImage(indexPath: IndexPath) -> UIImage {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCell else {
            return UIImage()
        }
        return cell.imageView.image ?? UIImage()
    }

    func scrollToItem(indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
}

