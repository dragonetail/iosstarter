//
//  ImageViewController.swift
//  photosApp2
//
//  Created by Muskan on 10/4/17.
//  Copyright © 2017 akhil. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    var imageCollectionView: UICollectionView!
    var album: Album!
    var initialIndexPath: IndexPath = IndexPath(row: 0, section: 1) //Infinite Logic, The first and last section are dummy

    var imageViewHeader: UIView?

   

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal

        imageCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(ImageViewCell.self, forCellWithReuseIdentifier: "Cell")
        imageCollectionView.isPagingEnabled = true
        imageCollectionView.scrollToItem(at: initialIndexPath, at: .left, animated: false)

        self.view.addSubview(imageCollectionView)

        imageCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))

        if let imageViewHeader = self.imageViewHeader {
            imageViewHeader.translatesAutoresizingMaskIntoConstraints = false
            imageViewHeader.alpha = 1
            self.view.addSubview(imageViewHeader)

            NSLayoutConstraint.activate([
                imageViewHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                imageViewHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                imageViewHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                imageViewHeader.heightAnchor.constraint(equalToConstant: CGFloat(64))
            ])
        }
    }

    //    override func viewWillLayoutSubviews() {
    //        super.viewWillLayoutSubviews()
    //
    //        guard let flowLayout = imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
    //
    //        flowLayout.itemSize = imageCollectionView.frame.size
    //
    //        flowLayout.invalidateLayout()
    //
    //        imageCollectionView.collectionViewLayout.invalidateLayout()
    //    }
    //
    //    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    //        super.viewWillTransition(to: size, with: coordinator)
    //        let offset = imageCollectionView.contentOffset
    //        let width = imageCollectionView.bounds.size.width
    //
    //        let index = round(offset.x / width)
    //        let newOffset = CGPoint(x: index * size.width, y: offset.y)
    //
    //        imageCollectionView.setContentOffset(newOffset, animated: false)
    //
    //        coordinator.animate(alongsideTransition: { (context) in
    //            self.imageCollectionView.reloadData()
    //
    //            self.imageCollectionView.setContentOffset(newOffset, animated: false)
    //        }, completion: nil)
    //    }

}
extension ImageViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        //Infinite Logic, The first and last section are dummy
        return self.album.sections.count + 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Infinite Logic, The first and last section are dummy
        if section == 0 || section == self.album.sections.count + 1 {
            return 1
        }

        return album.sections[section - 1].images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Infinite Logic, The first and last section are dummy
        print(indexPath.section, indexPath.row)
        let section = indexPath.section
        //真实相册数据中的坐标
        var targetIndexPath = indexPath
        if section == 0 {
            targetIndexPath = IndexPath(row: album.sections[album.sections.count - 1].count - 1, section: self.album.sections.count - 1)
        } else if section == self.album.sections.count + 1 {
            targetIndexPath = IndexPath(row: 0, section: 0)
        } else {
            targetIndexPath = IndexPath(row: indexPath.row, section: indexPath.section - 1)
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
        //return imageCollectionView.bounds.size
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
        print("scrollViewWillBeginDecelerating: ", scrollView.contentOffset.x / scrollView.frame.size.width)
        //Infinite Logic, The first and last section are dummy
        let fullyScrolledContentOffset: CGFloat = scrollView.frame.size.width * CGFloat(album.count)
        if (scrollView.contentOffset.x > fullyScrolledContentOffset) {
            //if album.count > 2 {
            print("scrollToItem: ", 1, 0)
            let indexPath: IndexPath = IndexPath(row: 0, section: 1)
            imageCollectionView.scrollToItem(at: indexPath, at: .left, animated: false)
            //}
        } else if (scrollView.contentOffset.x < scrollView.frame.size.width) {
            //if album.count > 2 {
            print("scrollToItem: ", album.sections.count, album.sections[album.sections.count - 1].count - 1)
            let indexPath: IndexPath = IndexPath(row: album.sections[album.sections.count - 1].count - 1, section: album.sections.count)
            imageCollectionView.scrollToItem(at: indexPath, at: .left, animated: false)
            //}
        }
    }

//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let X = scrollView.contentOffset.x
//         print("scrolled: ", X / scrollView.frame.size.width)
//        if X >= scrollView.frame.size.width * CGFloat(album.count - 1 + 2){
//            scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width, y: 0)
//        }else if X <= 0 {
//            scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width * CGFloat(album.count), y: 0)
//        }
//    }
}
