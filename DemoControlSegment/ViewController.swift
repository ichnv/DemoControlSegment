//
//  ViewController.swift
//  DemoControlSegment
//
//  Created by Mr Ích on 3/29/20.
//  Copyright © 2020 Mr Ích. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var segmentedPager: SegmentedPagerX!
    private var listVC: [UIViewController] = []
    private var listTitles: [String] = ["Mới","Bán Chạy", "Đồ Công Nghệ",
                                        "Góc Ăn uống","Thời Trang","Mỹ Phẩm",
                                        "Sách","Đồ gia dụng","Khác"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTitles.forEach { (_) in
            listVC.append(DemoViewController())
        }
        
        segmentedPager.dataSource = self
        segmentedPager.delegate = self
    }
}

// MARK: - SegmentedPagerXDataSource and SegmentedPagerXDelegate
extension ViewController: SegmentedPagerXDataSource {
    func numberOfPagesIn(_ segmentedPagerX: SegmentedPagerX) -> Int {
        return listVC.count
    }
    
    func segmentedPagerX(titleForSectionAt index: Int) -> String {
        return listTitles[index]
    }
    
    func segmentedPagerX(_ segmentedPagerX: SegmentedPagerX, viewForPageAt index: Int) -> UIViewController {
        return listVC[index]
    }
}

extension ViewController: SegmentedPagerXDelegate {
    func segmentedPagerX(_ segmentedPagerX: SegmentedPagerX, current index: Int) {
        
    }
}
