//
//  SegmentedPagerX.swift
//  DemoControlSegment
//
//  Created by Mr Ích on 4/5/20.
//  Copyright © 2020 Mr Ích. All rights reserved.
//

import UIKit

class SegmentedPagerX: UIView {
    weak var delegate: SegmentedPagerXDelegate?
    weak var dataSource: SegmentedPagerXDataSource? {
        didSet {
            self.setupData()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet weak private var pageViewContainerView: UIView!
    @IBOutlet weak var controlSegment: ControlSegment!
    
    private var pageViewController: UIPageViewController!
    var viewControllers = [UIViewController]()
    
    private(set) var currentIndex = 0 {
        didSet {
            delegate?.segmentedPagerX?(self, current: currentIndex)
        }
    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("SegmentedPagerX", owner: self, options: nil )
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupSubViews()
    }
    
    private func setupSubViews() {
        controlSegment.valueChange = {[weak self](index) in
            self?.selectPage(index)
        }
    }
    
    private func setupData() {
        let numberOfPages = dataSource?.numberOfPagesIn(self) ?? 0
        var titles = [String]()
        var viewControllers = [UIViewController]()
        for index in 0..<numberOfPages {
            if let title = dataSource?.segmentedPagerX(titleForSectionAt: index) {
                titles.append(title)
            }
            
            if let viewController = dataSource?.segmentedPagerX(self, viewForPageAt: index) {
                viewControllers.append(viewController)
            }
        }
        
        if !viewControllers.isEmpty {
            self.viewControllers = viewControllers
            controlSegment.titles = titles
            setupPageView()
            getProgress()
        }
    }
    
    private func getProgress() {
        let scrollView = pageViewController.view.subviews.filter { $0 is UIScrollView }.first as! UIScrollView
        scrollView.delegate = self
        controlSegment.scrollView = scrollView
    }
}

extension SegmentedPagerX {
    // Setup PageViewController
    private func setupPageView() {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        addChildVC(pageViewController, into: pageViewContainerView)
        self.pageViewController = pageViewController
        selectPage(currentIndex)
    }
    
    func addChildVC(_ vc: UIViewController, into container: UIView) {
        container.addSubview(vc.view)
        vc.view.constraintToAllSides(of: container)
    }
    
    // MARK: - Support function
    private func selectPage(_ index: Int) {
        let direction: UIPageViewController.NavigationDirection = index < currentIndex ? .reverse : .forward
        let viewController = viewControllers[index] as UIViewController
        pageViewController.setViewControllers([viewController], direction: direction, animated: true, completion: {(finished) in
            
        })
        currentIndex = index
        setTag(index)
    }
    
    fileprivate func setTag(_ index: Int) {
        let previous = index - 1
        if previous > 0 {
            viewControllers[previous].view.tag = previous
        }
        let next = index + 1
        if next < viewControllers.count {
            viewControllers[next].view.tag = next
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension SegmentedPagerX: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = viewControllers.firstIndex(of: viewController), index > 0 {
            return viewControllers[index - 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = viewControllers.firstIndex(of: viewController) {
            if index < viewControllers.count - 1 {
                return viewControllers[index + 1]
            }
        }
        return nil
    }
}

//MARK:- UIPageViewControllerDelegate
extension SegmentedPagerX: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let firstIndex = pageViewController.viewControllers?.first?.view.tag {
            setTag(firstIndex)
            currentIndex = firstIndex
        }
    }
}

extension SegmentedPagerX: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        controlSegment.selectIndex = self.currentIndex
    }
}
