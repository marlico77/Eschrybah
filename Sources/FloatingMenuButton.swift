import UIKit
import CoreText

protocol FloatingMenuDelegate: AnyObject {
    func didSelectTool(isEraser: Bool, color: UIColor, width: CGFloat)
    func didSelectUndo()
    func didSelectRedo()
    func didSelectClear()
    func didToggleCanvas(isActive: Bool)
}

class FloatingMenuButton: UIView {
    
    weak var delegate: FloatingMenuDelegate?
    
    private var isExpanded = false
    private var canvasActive = false
    
    private var currentColor: UIColor = .blue
    private var currentWidth: CGFloat = 3.0
    private var isHighlighter = false
    
    private let mainButton = UIButton(type: .system)
    private let stackView = UIStackView()
    private let toolsContainer = UIView()
    
    private let buttonSize: CGFloat = 44.0
    private let spacing: CGFloat = 10.0
    
    private var faFont: UIFont {
        return UIFont(name: "FontAwesome6Free-Solid", size: 20) ?? UIFont.systemFont(ofSize: 20)
    }
    
    private static var fontRegistered = false
    private func registerFont() {
        guard !FloatingMenuButton.fontRegistered else { return }
        guard let url = Bundle.main.url(forResource: "fa-solid-900", withExtension: "ttf") else { return }
        var error: Unmanaged<CFError>?
        if CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
            FloatingMenuButton.fontRegistered = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: UIScreen.main.bounds.width - 64, y: 100, width: 44, height: 44))
        registerFont()
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        self.backgroundColor = .clear
        
        mainButton.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        mainButton.backgroundColor = .white
        mainButton.setTitle("\u{f142}", for: .normal)
        mainButton.titleLabel?.font = faFont
        mainButton.setTitleColor(.darkGray, for: .normal)
        mainButton.layer.cornerRadius = buttonSize / 2
        applyShadow(to: mainButton)
        mainButton.addTarget(self, action: #selector(toggleMenu), for: .touchUpInside)
        
        toolsContainer.isHidden = true
        toolsContainer.backgroundColor = .white
        toolsContainer.layer.cornerRadius = buttonSize / 2
        applyShadow(to: toolsContainer)
        
        stackView.axis = .horizontal
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        toolsContainer.addSubview(stackView)
        self.addSubview(toolsContainer)
        self.addSubview(mainButton)
        
        toolsContainer.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: toolsContainer.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: toolsContainer.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: toolsContainer.leadingAnchor, constant: spacing),
            stackView.trailingAnchor.constraint(equalTo: toolsContainer.trailingAnchor, constant: -spacing)
        ])
        
        showMainTools()
    }
    
    private func applyShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 6
    }
    
    // MARK: - State Management
    
    @objc private func showMainTools() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let penBtn = createToolButton(icon: "\u{f304}", color: .darkGray) // fa-pen
        penBtn.addTarget(self, action: #selector(openColorsForPen), for: .touchUpInside)
        
        let highBtn = createToolButton(icon: "\u{f591}", color: .darkGray) // fa-highlighter
        highBtn.addTarget(self, action: #selector(selectHighlighter), for: .touchUpInside)
        
        let eraseBtn = createToolButton(icon: "\u{f12d}", color: .darkGray) // fa-eraser
        eraseBtn.addTarget(self, action: #selector(selectEraser), for: .touchUpInside)
        
        let undoBtn = createToolButton(icon: "\u{f0e2}", color: .darkGray) // fa-undo
        undoBtn.addTarget(self, action: #selector(doUndo), for: .touchUpInside)
        
        let redoBtn = createToolButton(icon: "\u{f01e}", color: .darkGray) // fa-redo
        redoBtn.addTarget(self, action: #selector(doRedo), for: .touchUpInside)
        
        let clearBtn = createToolButton(icon: "\u{f1f8}", color: .red) // fa-trash
        clearBtn.addTarget(self, action: #selector(doClear), for: .touchUpInside)
        
        [penBtn, highBtn, eraseBtn, undoBtn, redoBtn, clearBtn].forEach { stackView.addArrangedSubview($0) }
        updateContainerSize()
    }
    
    @objc private func openColorsForPen() {
        isHighlighter = false
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let blackBtn = createColorButton(color: .black)
        let redBtn = createColorButton(color: .red)
        let blueBtn = createColorButton(color: .blue)
        let greenBtn = createColorButton(color: .green)
        
        let backBtn = createToolButton(icon: "\u{f060}", color: .darkGray) // fa-arrow-left
        backBtn.addTarget(self, action: #selector(showMainTools), for: .touchUpInside)
        
        [blackBtn, redBtn, blueBtn, greenBtn, backBtn].forEach { stackView.addArrangedSubview($0) }
        updateContainerSize()
    }
    
    private func createColorButton(color: UIColor) -> UIView {
        let btn = UIButton(type: .system)
        btn.backgroundColor = color
        btn.layer.cornerRadius = 15
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // Add a wrapper to center the 30x30 circle in a 44x44 space
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        wrapper.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        wrapper.addSubview(btn)
        btn.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor).isActive = true
        btn.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor).isActive = true
        
        // Action
        let tap = UITapGestureRecognizer(target: self, action: #selector(colorSelected(_:)))
        wrapper.addGestureRecognizer(tap)
        wrapper.tag = color.hash
        
        return wrapper
    }
    
    @objc private func colorSelected(_ sender: UITapGestureRecognizer) {
        guard let wrapper = sender.view, let colorBtn = wrapper.subviews.first as? UIButton, let color = colorBtn.backgroundColor else { return }
        currentColor = color
        openWidthsForPen()
    }
    
    private func openWidthsForPen() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let thinBtn = createToolButton(icon: "•", color: .darkGray)
        thinBtn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        thinBtn.addTarget(self, action: #selector(widthSelectedThin), for: .touchUpInside)
        
        let medBtn = createToolButton(icon: "•", color: .darkGray)
        medBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        medBtn.addTarget(self, action: #selector(widthSelectedMed), for: .touchUpInside)
        
        let thickBtn = createToolButton(icon: "•", color: .darkGray)
        thickBtn.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        thickBtn.addTarget(self, action: #selector(widthSelectedThick), for: .touchUpInside)
        
        let backBtn = createToolButton(icon: "\u{f060}", color: .darkGray)
        backBtn.addTarget(self, action: #selector(openColorsForPen), for: .touchUpInside)
        
        [thinBtn, medBtn, thickBtn, backBtn].forEach { stackView.addArrangedSubview($0) }
        updateContainerSize()
    }
    
    @objc private func widthSelectedThin() { applyPen(width: 2.0) }
    @objc private func widthSelectedMed() { applyPen(width: 5.0) }
    @objc private func widthSelectedThick() { applyPen(width: 10.0) }
    
    private func applyPen(width: CGFloat) {
        currentWidth = width
        delegate?.didSelectTool(isEraser: false, color: currentColor, width: currentWidth)
        showMainTools() // Go back to main
    }
    
    @objc private func selectHighlighter() {
        isHighlighter = true
        delegate?.didSelectTool(isEraser: false, color: UIColor.yellow.withAlphaComponent(0.4), width: 25.0)
    }
    
    @objc private func selectEraser() {
        delegate?.didSelectTool(isEraser: true, color: .clear, width: 20)
    }
    
    @objc private func doUndo() { delegate?.didSelectUndo() }
    @objc private func doRedo() { delegate?.didSelectRedo() }
    @objc private func doClear() { delegate?.didSelectClear() }
    
    private func createToolButton(icon: String, color: UIColor) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(icon, for: .normal)
        btn.setTitleColor(color, for: .normal)
        btn.titleLabel?.font = faFont
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        btn.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        return btn
    }
    
    // MARK: - Dragging and Touch Handling
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isHidden || !self.isUserInteractionEnabled || self.alpha < 0.01 { return nil }
        for subview in self.subviews.reversed() {
            let convertedPoint = subview.convert(point, from: self)
            if let hitView = subview.hitTest(convertedPoint, with: event) {
                return hitView
            }
        }
        return super.hitTest(point, with: event)
    }
    
    private func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(pan)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview = self.superview else { return }
        let translation = gesture.translation(in: superview)
        if gesture.state == .began || gesture.state == .changed {
            self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
            gesture.setTranslation(.zero, in: superview)
        }
    }
    
    // MARK: - Toggle Actions
    
    private func updateContainerSize() {
        let itemsCount = CGFloat(stackView.arrangedSubviews.count)
        let newWidth = (buttonSize * itemsCount) + (spacing * (itemsCount + 1))
        
        UIView.animate(withDuration: 0.2) {
            self.toolsContainer.frame = CGRect(x: -newWidth + self.buttonSize, y: 0, width: newWidth, height: self.buttonSize)
        }
    }
    
    @objc private func toggleMenu() {
        isExpanded.toggle()
        
        if isExpanded && !canvasActive {
            canvasActive = true
            delegate?.didToggleCanvas(isActive: true)
            mainButton.setTitle("\u{f00d}", for: .normal) // fa-times
            mainButton.setTitleColor(.red, for: .normal)
        } else if !isExpanded {
            canvasActive = false
            delegate?.didToggleCanvas(isActive: false)
            mainButton.setTitle("\u{f142}", for: .normal) // fa-ellipsis-v
            mainButton.setTitleColor(.darkGray, for: .normal)
        }
        
        var targetWidth: CGFloat = buttonSize
        
        if isExpanded {
            toolsContainer.isHidden = false
            toolsContainer.alpha = 0
            showMainTools() // Always reset to main tools when opening
            let itemsCount = CGFloat(stackView.arrangedSubviews.count)
            targetWidth = (buttonSize * itemsCount) + (spacing * (itemsCount + 1))
            self.toolsContainer.frame = CGRect(x: self.buttonSize/2, y: 0, width: self.buttonSize, height: self.buttonSize) // Start small from right
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.isExpanded {
                self.toolsContainer.alpha = 1
                // Expandir para a esquerda
                self.toolsContainer.frame = CGRect(x: -targetWidth + self.buttonSize, y: 0, width: targetWidth, height: self.buttonSize)
            } else {
                self.toolsContainer.alpha = 0
                self.toolsContainer.frame = CGRect(x: 0, y: 0, width: self.buttonSize, height: self.buttonSize)
            }
        }) { _ in
            if !self.isExpanded {
                self.toolsContainer.isHidden = true
            }
        }
    }
}
