//
//  ControlSegment.swift
//  DemoControlSegment
//
//  Created by Mr Ích on 3/29/20.
//  Copyright © 2020 Mr Ích. All rights reserved.
//


import UIKit

public struct SegmentStyle {
    public var indicatorColor = UIColor.red
    public var indicatorHeight: CGFloat = 26
    public var titleMargin: CGFloat = 5
    public var titlePaddingLeft: CGFloat = 10
    public var titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    public var normalTitleColor = UIColor.black
    public var selectedTitleColor = UIColor.white
    public var minimumWidth: CGFloat?
    public init() {}
}

@IBDesignable public class ControlSegment: UIControl {
    
    public override var frame: CGRect {
        didSet {
            guard frame.size != oldValue.size else { return }
            setupDefaultLayout()
        }
    }
    
    public override var bounds: CGRect {
        didSet {
            guard bounds.size != oldValue.size else { return }
            setupDefaultLayout()
        }
    }
    
    public var titles: [String] {
        didSet {
            setupDefaultLayout()
        }
    }
    
    private let _scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.bounces = true
        view.scrollsToTop = false
        view.isScrollEnabled = true
        view.contentInset = UIEdgeInsets.zero
        view.contentOffset = CGPoint.zero
        view.scrollsToTop = false
        return view
    }()
    
    //    // A scroll view to observe in order to move the indicator.
    @IBOutlet public weak var scrollView: UIScrollView? {
        willSet { scrollView?.removeObserver(self, forKeyPath: keyPath, context: &context) }
        didSet { scrollView?.addObserver(self, forKeyPath: keyPath, context: &context) }
    }
    
    public var style: SegmentStyle {
        didSet {
            setupDefaultLayout()
        }
    }
    
    private let selectContent =  UIView()
    
    private var indicator: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        return view
    }()
    
    private let selectedLabelsMaskView: UIView = {
        let cover = UIView()
        cover.layer.masksToBounds = true
        cover.backgroundColor = .yellow
        return cover
    }()
    
    private var titleLabels: [UILabel] = []
    var selectIndex = 0
    
    public var progress: CGFloat = 0 {
        didSet { layoutIndicator() }
    }
    
    private var context: UInt8 = 1
    private let keyPath = NSStringFromSelector(#selector(getter: UIScrollView.contentOffset))
    
    public var valueChange: ((Int) -> Void)?
    
    // MARK: - life cycle
    public convenience override init(frame: CGRect) {
        self.init(frame: frame, segmentStyle: SegmentStyle(), titles: [])
    }
    
    public init(frame: CGRect, segmentStyle: SegmentStyle, titles: [String]) {
        self.style = segmentStyle
        self.titles = titles
        super.init(frame: frame)
        setupControl()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.style = SegmentStyle()
        self.titles = []
        super.init(coder: aDecoder)
        setupControl()
    }
    
    deinit {
        guard let scrollView = scrollView else { return }
        scrollView.removeObserver(self, forKeyPath: keyPath, context: &context)
    }
    
    private func setupControl() {
        addSubview(_scrollView)
        setupDefaultLayout()
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &self.context {
            if let scrollView = scrollView, scrollView.isDragging || scrollView.isDecelerating {
                let offset = scrollView.contentOffset.x
                let bounds = scrollView.bounds.width
                let page = CGFloat(self.selectIndex)
               // print("offset",offset)
                let contentOffsetX = offset - bounds + page * bounds
                progress = CGFloat(contentOffsetX / scrollView.frame.size.width)
            }
            
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func layoutIndicator() {
        guard !titleLabels.isEmpty else { return }
        
        let index = min(Int(progress), titleLabels.count - 1)
        let current = titleLabels[index]
        
        var frame = CGRect.zero
        frame.size.height = style.indicatorHeight
        
        // Compute indicator's position
        let y: CGFloat = ( bounds.height - frame.size.height)/2
        var x: CGFloat = progress < 0 ? 0 : current.frame.size.width * (progress - CGFloat(index))
        
        for i in 0..<index {
            x += titleLabels[i].frame.size.width + style.titleMargin
        }
        
        x += style.titleMargin
        frame.origin.x = x
        frame.origin.y = y
        
        // Compute indicator's width
        if progress < 0 {
            // Bounce left, (progress + 1) so that the width is always greater than 0
            frame.size.width = current.frame.size.width * (progress + 1)
        } else if index + 1 < titleLabels.count {
            let next = titleLabels[index + 1]
            let dx = (next.frame.size.width - current.frame.size.width) * (progress - CGFloat(index))
            frame.size.width = current.frame.size.width + dx
        } else {
            //bounce right
            frame.size.width = current.frame.size.width * (CGFloat(titleLabels.count) - progress)
        }
        
        setIndicatorFrame(frame)
        let offSetX = min(max(0, current.center.x - bounds.width / 2),
                          max(0, _scrollView.contentSize.width - bounds.width))
        _scrollView.setContentOffset(CGPoint(x: offSetX, y: 0), animated: true)
    }
    
    private func setupDefaultLayout() {
        guard !titles.isEmpty  else { return }
        //
        _scrollView.frame = bounds
        selectContent.frame = bounds
        selectContent.layer.mask = selectedLabelsMaskView.layer
        selectedLabelsMaskView.isUserInteractionEnabled = true
        
        let font  = style.titleFont
        let toToSize: (String) -> CGFloat = { text in
            let result =  (text as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 0.0), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).width
            if let minWidth = self.style.minimumWidth, result < minWidth {
                return minWidth
            }
            return result
        }
        
        // Set titles
        var titleX: CGFloat = 0.0
        let titleH = font.lineHeight
        let titleY: CGFloat = ( bounds.height - titleH)/2
        
        for (index, item) in titles.enumerated() {
            
            let titleW = toToSize(item) + style.titlePaddingLeft * 2
            
            titleX = (titleLabels.last?.frame.maxX ?? 0 ) + style.titleMargin
            let rect = CGRect(x: titleX, y: titleY, width: titleW, height: titleH)
            
            let backLabel = makeLabel(index: index, text: item, rect: rect, color: style.normalTitleColor)
            let frontLabel = makeLabel(index: index, text: item, rect: rect, color: style.selectedTitleColor)
            
            titleLabels.append(backLabel)
            _scrollView.addSubview(backLabel)
            selectContent.addSubview(frontLabel)
            
            if index == titles.count - 1 {
                _scrollView.contentSize.width = rect.maxX + style.titleMargin
                selectContent.frame.size.width = rect.maxX + style.titleMargin
            }
        }
        
        // Set Cover
        indicator.backgroundColor = style.indicatorColor
        _scrollView.addSubview(indicator)
        _scrollView.addSubview(selectContent)
        
        let coverW = titleLabels[selectIndex].frame.size.width
        let coverH: CGFloat = style.indicatorHeight
        let coverX = titleLabels[selectIndex].frame.origin.x
        let coverY = (bounds.size.height - coverH) / 2
        
        let indRect = CGRect(x: coverX, y: coverY, width: coverW, height: coverH)
        setIndicatorFrame(indRect)
        indicator.layer.cornerRadius = coverH/2
        selectedLabelsMaskView.layer.cornerRadius = coverH/2
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ControlSegment.handleTapGesture(_:)))
        
        addGestureRecognizer(tapGesture)
        setSelectIndex(index: selectIndex)
    }
    
    // Target action
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let x = gesture.location(in: self).x + _scrollView.contentOffset.x
        for (i, label) in titleLabels.enumerated() {
            if x >= label.frame.minX && x <= label.frame.maxX {
                setSelectIndex(index: i)
                break
            }
        }
    }
    
    private func setSelectIndex(index: Int) {
        
        guard (index != selectIndex), index >= 0, index < titleLabels.count else { return }
        
        let currentLabel = titleLabels[index]
        let offSetX = min(max(0, currentLabel.center.x - bounds.width / 2),
                          max(0, _scrollView.contentSize.width - bounds.width))
        _scrollView.setContentOffset(CGPoint(x: offSetX, y: 0), animated: true)
        
        UIView.animate(withDuration: 0.3, animations: {
            var rect = self.indicator.frame
            rect.origin.x = currentLabel.frame.origin.x
            rect.size.width = currentLabel.frame.size.width
            self.setIndicatorFrame(rect)
        })
        
        selectIndex = index
        valueChange?(index)
    }
    
    private func setIndicatorFrame(_ frame: CGRect) {
        indicator.frame = frame
        selectedLabelsMaskView.frame = frame
    }
    
    private func makeLabel(index: Int, text: String, rect: CGRect, color: UIColor) -> UILabel {
        let label = UILabel(frame: CGRect.zero)
        label.tag = index
        label.text = text
        label.textColor = color
        label.font = style.titleFont
        label.textAlignment = .center
        label.frame = rect
        return label
    }
}

