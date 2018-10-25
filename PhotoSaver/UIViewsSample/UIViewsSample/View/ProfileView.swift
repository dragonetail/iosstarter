//
//  ProfileView.swift
//  UIViewsSample
//
//  Created by 孙玉新 on 2018/10/17.
//  Copyright © 2018年 dragonetail. All rights reserved.
//

import UIKit
import PureLayout

class ProfileView: UIView {
    var shouldSetupConstraints = true

    var bannerView: UIImageView!
    var profileView: UIImageView!
    var segmentedControl: UISegmentedControl!

    override init(frame: CGRect) {
        super.init(frame: frame)

        bannerView = UIImageView(frame: CGRect.zero)
        bannerView.backgroundColor = UIColor.gray

        bannerView.autoSetDimension(.height, toSize: UIScreen.main.bounds.size.width / 3)

        self.addSubview(bannerView)

        profileView = UIImageView(frame: CGRect.zero)
        profileView.backgroundColor = UIColor.gray
        profileView.layer.borderColor = UIColor.white.cgColor
        profileView.layer.borderWidth = 1.0
        profileView.layer.cornerRadius = 5.0

        profileView.autoSetDimension(.width, toSize: 124.0)
        profileView.autoSetDimension(.height, toSize: 124.0)

        self.addSubview(profileView)

        segmentedControl = UISegmentedControl(items: ["Tweets", "Media", "Likes"])

        self.addSubview(segmentedControl)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func updateConstraints() {
        if(shouldSetupConstraints) {
            // AutoLayout constraints
            updateLocalConstraints()

            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }

    func updateLocalConstraints() {
        let edgesInset: CGFloat = 10.0
        let centerOffset: CGFloat = 62.0

        bannerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .bottom)

        profileView.autoPinEdge(toSuperviewEdge: .left, withInset: edgesInset)
        // 👇🏽 profileView.autoAlignAxis(.horizontal, toSameAxisOf: bannerView, withOffset: centerOffset)
        profileView.autoPinEdge(.bottom, to: .bottom, of: bannerView, withOffset: centerOffset)

        segmentedControl.autoPinEdge(toSuperviewEdge: .bottom, withInset: edgesInset)
        segmentedControl.autoPinEdge(toSuperviewEdge: .left, withInset: edgesInset)
        segmentedControl.autoPinEdge(toSuperviewEdge: .right, withInset: edgesInset)
    }
}

