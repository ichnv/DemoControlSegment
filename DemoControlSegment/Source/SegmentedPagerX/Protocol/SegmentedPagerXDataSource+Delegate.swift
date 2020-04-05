//
//  MDVTabBarDataSource+Delegate.swift
//  DemoControlSegment
//
//  Created by Mr Ích on 4/5/20.
//  Copyright © 2020 Mr Ích. All rights reserved.
//

import UIKit

@objc protocol SegmentedPagerXDelegate: class {
    @objc optional func segmentedPagerX(_ segmentedPagerX: SegmentedPagerX, current index: Int)
}

protocol SegmentedPagerXDataSource: class {
    func numberOfPagesIn(_ segmentedPagerX: SegmentedPagerX) -> Int
    func segmentedPagerX(titleForSectionAt index: Int) -> String
    func segmentedPagerX(_ segmentedPagerX: SegmentedPagerX, viewForPageAt index: Int) -> UIViewController
}
