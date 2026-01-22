//
//  CustomTabBar.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/1/18.
//

import UIKit
import SnapKit

@MainActor
final class CustomTabBar: UIView {
    
    // MARK: - Properties
    
    weak var delegate: CustomTabBarDelegate?
    
    private var items: [TabBarItem] = []
    private var selectedIndex: Int = 0 {
        didSet {
            guard selectedIndex != oldValue else { return }
            updateSelection(from: oldValue, to: selectedIndex)
        }
    }
    
    var customHeight: CGFloat = 49 {
        didSet {
            guard customHeight != oldValue else { return }
            invalidateIntrinsicContentSize()
        }
    }
    
    private lazy var feedbackGenerator: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        return generator
    }()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: customHeight + safeAreaInsets.bottom)
    }
    
    // MARK: - UI Components
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(backgroundView)
        addSubview(stackView)
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-8)
        }
        
        let borderView = UIView()
        borderView.backgroundColor = .separator
        addSubview(borderView)
        borderView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    // MARK: - Public Methods
    
    func configure(with items: [TabBarItem]) {
        guard self.items != items else { return }
        self.items = items
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        items.enumerated().forEach { index, item in
            let button = createTabButton(for: item, at: index)
            stackView.addArrangedSubview(button)
        }
        
        if selectedIndex >= items.count {
            selectedIndex = 0
        } else {
            updateSelection(from: -1, to: selectedIndex)
        }
    }
    
    func addItem(_ item: TabBarItem) {
        items.append(item)
        let button = createTabButton(for: item, at: items.count - 1)
        stackView.addArrangedSubview(button)
    }
    
    func removeItem(at index: Int) {
        guard index >= 0 && index < items.count else { return }
        let oldSelectedIndex = selectedIndex
        items.remove(at: index)
        
        if let button = stackView.arrangedSubviews[index] as? UIButton {
            stackView.removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        (index..<stackView.arrangedSubviews.count).forEach { idx in
            (stackView.arrangedSubviews[idx] as? UIButton)?.tag = idx
        }
        
        if selectedIndex >= items.count {
            selectedIndex = 0
        } else if selectedIndex != oldSelectedIndex {
            updateSelection(from: oldSelectedIndex, to: selectedIndex)
        }
    }
    
    func selectTab(at index: Int) {
        guard index >= 0 && index < items.count else { return }
        selectedIndex = index
    }
    
    // MARK: - Private Methods
    
    private func createTabButton(for item: TabBarItem, at index: Int) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.imagePlacement = .top
        configuration.imagePadding = 4
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        configuration.background.backgroundColor = .clear
        
        let button = UIButton(configuration: configuration)
        button.tag = index
        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        
        let attributedTitle: AttributedString? = {
            guard item.displayMode == .iconWithText else { return nil }
            var attributed = AttributedString(item.title)
            attributed.font = .systemFont(ofSize: 10)
            return attributed
        }()
        
        switch item.displayMode {
        case .iconOnly:
            configuration.image = item.icon
            configuration.title = nil
            configuration.baseForegroundColor = .systemGray
            button.configuration = configuration
            
            button.configurationUpdateHandler = { [item] btn in
                var config = btn.configuration
                let isSelected = btn.isSelected
                config?.image = isSelected ? (item.selectedIcon ?? item.icon) : item.icon
                config?.baseForegroundColor = isSelected ? .systemBlue : .systemGray
                config?.background.backgroundColor = .clear
                btn.configuration = config
            }
            
        case .iconWithText:
            configuration.image = item.icon
            configuration.title = item.title
            configuration.baseForegroundColor = .systemGray
            if let attributed = attributedTitle {
                configuration.attributedTitle = attributed
            }
            button.configuration = configuration
            
            button.configurationUpdateHandler = { [item] btn in
                var config = btn.configuration
                let isSelected = btn.isSelected
                config?.image = isSelected ? (item.selectedIcon ?? item.icon) : item.icon
                config?.baseForegroundColor = isSelected ? .systemBlue : .systemGray
                config?.background.backgroundColor = .clear
                btn.configuration = config
            }
        }
        
        return button
    }
    
    @objc private func tabButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index != selectedIndex else { return }
        selectedIndex = index
        delegate?.didSelectTab(at: index)
        feedbackGenerator.impactOccurred()
    }
    
    private func updateSelection(from oldIndex: Int, to newIndex: Int) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
        
        stackView.arrangedSubviews.enumerated().forEach { index, subview in
            guard let button = subview as? UIButton else { return }
            let shouldBeSelected = (index == newIndex)
            
            guard button.isSelected != shouldBeSelected else { return }
            
            button.isSelected = shouldBeSelected
            
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
                button.transform = shouldBeSelected
                    ? CGAffineTransform(scaleX: 1.1, y: 1.1)
                    : .identity
            }
        }
        
        CATransaction.commit()
    }
}
