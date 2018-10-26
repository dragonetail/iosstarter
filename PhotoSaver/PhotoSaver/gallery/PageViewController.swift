//
//  PageViewController.swift
//  PhotoSaver
//
//  Created by 孙玉新 on 2018/10/21.
//  Copyright © 2018年 dragonetail. All rights reserved.
//

import Foundation
import UIKit
import FSPagerView
import PureLayout

class PageViewController: UIViewController {

    private let album: Album
    private let indexPath: IndexPath

    init(album: Album, indexPath: IndexPath) {
        self.album = album
        self.indexPath = indexPath

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 初始化逻辑
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a pager view
        let pagerView = FSPagerView()
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pagerView.isInfinite = true
        pagerView.decelerationDistance = 1
//        pagerView.itemSize = CGSize(width: 200, height: 180)
//        pagerView.interitemSpacing = 10
//        pagerView.transformer = FSPagerViewTransformer(type: .crossFading)
        pagerView.transformer = FSPagerViewTransformer(type: .zoomOut)
//        pagerView.transformer = FSPagerViewTransformer(type: .depth)
//        pagerView.transformer = FSPagerViewTransformer(type: .overlap)
//        pagerView.transformer = FSPagerViewTransformer(type: .ferrisWheel)
//        pagerView.transformer = FSPagerViewTransformer(type: .invertedFerrisWheel)
//        pagerView.transformer = FSPagerViewTransformer(type: .coverFlow)
//        pagerView.transformer = FSPagerViewTransformer(type: .cubic)

        self.view.addSubview(pagerView)
        // Create a page control
        let pageControl = FSPageControl()
        self.view.addSubview(pageControl)
        pageControl.currentPage = 5

        pagerView.autoPinEdges(toSuperviewMarginsExcludingEdge: .bottom)
        pageControl.autoPinEdges(toSuperviewMarginsExcludingEdge: .top)
        pageControl.autoPinEdge(.top, to: .bottom, of: pagerView)
        pageControl.autoSetDimension(.height, toSize: 200)

    }
}
extension PageViewController: FSPagerViewDataSource {
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return album.count
    }

    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
//        let image: Image = images[index]
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
//        let group = DispatchGroup() // initialize
//        group.enter() // wait
//
//        print("Group enterred")
//        cell.imageView?.image = UIImage(named: "picture_unselect")
//        cell.imageView?.image = nil
//        image.resolve(completion: { uiImage in
//            print(uiImage)
//            cell.imageView?.image = uiImage
//            group.leave()
//            print("Group leaved")
//        })
//        group.notify(queue: .main) {
//            //cell.imageView?.image = UIImage(named: "picture_unselect")
//            //noop
//            print("Group notified")
//        }
//        cell.textLabel?.text = image.asset.creationDate?.description
        return cell
    }
}

extension PageViewController: FSPagerViewDelegate {
    func pagerView(_ pagerView: FSPagerView, shouldHighlightItemAt index: Int) -> Bool {
        return true
    }
}
