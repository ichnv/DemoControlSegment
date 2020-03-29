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
    
    private let scrollView: UIScrollView = {
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
    
    public var style: SegmentStyle {
        didSet {
            setupDefaultLayout()
        }
    }
    
    private let selectContent =  UIView()
    
    private var indicator: UIView = {
        let ind = UIView()
        ind.layer.masksToBounds = true
        return ind
    }()
    
    private let selectedLabelsMaskView: UIView = {
        let cover = UIView()
        cover.layer.masksToBounds = true
        cover.backgroundColor = .yellow
        return cover
    }()
    
    private var titleLabels: [UILabel] = []
    var selectIndex = 0
    
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
    
    private func setupControl() {
        addSubview(UIView())
        addSubview(scrollView)
        titles = ["Mới","Bán Chạy", "Đồ Công Nghệ", "Góc Ăn uống","Thời Trang","Mỹ Phẩm","Sách","Đồ gia dụng","Khác"]
        setupDefaultLayout()
    }
    
    private func setupDefaultLayout() {
        guard !titles.isEmpty  else { return }
        //
        scrollView.frame = bounds
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
            scrollView.addSubview(backLabel)
            selectContent.addSubview(frontLabel)
            
            if index == titles.count - 1 {
                scrollView.contentSize.width = rect.maxX + style.titleMargin
                selectContent.frame.size.width = rect.maxX + style.titleMargin
            }
        }
        
        // Set Cover
        indicator.backgroundColor = style.indicatorColor
        scrollView.addSubview(indicator)
        scrollView.addSubview(selectContent)
        
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
        let x = gesture.location(in: self).x + scrollView.contentOffset.x
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
                          max(0, scrollView.contentSize.width - bounds.width))
        scrollView.setContentOffset(CGPoint(x: offSetX, y: 0), animated: true)
        
        UIView.animate(withDuration: 0.3, animations: {
            var rect = self.indicator.frame
            rect.origin.x = currentLabel.frame.origin.x
            rect.size.width = currentLabel.frame.size.width
            self.setIndicatorFrame(rect)
        })
        
        selectIndex = index
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

