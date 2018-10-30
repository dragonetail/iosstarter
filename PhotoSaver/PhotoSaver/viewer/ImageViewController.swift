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
    var initialIndexPath: IndexPath = IndexPath()

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
        imageCollectionView.scrollToItem(at: initialIndexPath, at: .left, animated: true)

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
}
extension ImageViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.album.sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album.sections[section].images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageViewCell
        let image = album.getImage(indexPath)
        //cell.imageView.image = UIImage(named: "picture_unselect")
        image.resolve(completion: { (uiImage) in
            cell.imageView.image = uiImage
        })

        return cell
    }
}
extension ImageViewController: UICollectionViewDelegateFlowLayout {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

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
}
extension ImageViewController: UICollectionViewDelegate {
}

