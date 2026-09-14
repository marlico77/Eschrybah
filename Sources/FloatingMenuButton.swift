import UIKit

protocol FloatingMenuDelegate: AnyObject {
    func didSelectTool(color: UIColor, width: CGFloat)
    func didSelectClear()
    func didToggleCanvas(isActive: Bool)
}

class FloatingMenuButton: UIView {
    
    weak var delegate: FloatingMenuDelegate?
    
    private var isExpanded = false
    private var canvasActive = false
    
    private let mainButton = UIButton(type: .system)
    private let stackView = UIStackView()
    
    // Configurações do FAB
    private let buttonSize: CGFloat = 44.0
    private let spacing: CGFloat = 10.0
    
    // Fonte Awesome
    private var faFont: UIFont {
        return UIFont(name: "FontAwesome6Free-Solid", size: 20) ?? UIFont.systemFont(ofSize: 20)
    }
    
    override init(frame: CGRect) {
        // Inicialmente tem o tamanho apenas do botão principal
        super.init(frame: CGRect(x: UIScreen.main.bounds.width - 64, y: 100, width: 44, height: 44))
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .clear
        
        // Botão Principal
        mainButton.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        mainButton.backgroundColor = .white
        mainButton.setTitle("\u{f142}", for: .normal) // fa-ellipsis-v
        mainButton.titleLabel?.font = faFont
        mainButton.setTitleColor(.darkGray, for: .normal)
        mainButton.layer.cornerRadius = buttonSize / 2
        applyShadow(to: mainButton)
        mainButton.addTarget(self, action: #selector(toggleMenu), for: .touchUpInside)
        
        // StackView para os botões secundários (Expansão Vertical)
        stackView.axis = .vertical
        stackView.spacing = spacing
        stackView.alpha = 0
        stackView.isHidden = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(stackView)
        self.addSubview(mainButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: mainButton.bottomAnchor, constant: spacing),
            stackView.centerXAnchor.constraint(equalTo: mainButton.centerXAnchor)
        ])
        
        setupTools()
    }
    
    private func applyShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 6
    }
    
    private func setupTools() {
        // Ícones FontAwesome puros, tintados com as cores das canetas
        let yellowBtn = createToolButton(icon: "\u{f591}", color: .systemYellow) // fa-highlighter
        yellowBtn.addTarget(self, action: #selector(selectYellow), for: .touchUpInside)
        
        let redBtn = createToolButton(icon: "\u{f304}", color: .systemRed) // fa-pen
        redBtn.addTarget(self, action: #selector(selectRed), for: .touchUpInside)
        
        let blueBtn = createToolButton(icon: "\u{f304}", color: .systemBlue) // fa-pen
        blueBtn.addTarget(self, action: #selector(selectBlue), for: .touchUpInside)
        
        let clearBtn = createToolButton(icon: "\u{f12d}", color: .darkGray) // fa-eraser
        clearBtn.addTarget(self, action: #selector(clearCanvas), for: .touchUpInside)
        
        stackView.addArrangedSubview(yellowBtn)
        stackView.addArrangedSubview(redBtn)
        stackView.addArrangedSubview(blueBtn)
        stackView.addArrangedSubview(clearBtn)
    }
    
    private func createToolButton(icon: String, color: UIColor) -> UIButton {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .white
        btn.setTitle(icon, for: .normal)
        btn.setTitleColor(color, for: .normal)
        btn.titleLabel?.font = faFont
        btn.layer.cornerRadius = buttonSize / 2
        applyShadow(to: btn)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        btn.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        return btn
    }
    
    // MARK: - Arrastar (Draggable)
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
    
    // MARK: - Ações
    @objc private func toggleMenu() {
        isExpanded.toggle()
        
        if isExpanded && !canvasActive {
            canvasActive = true
            delegate?.didToggleCanvas(isActive: true)
            mainButton.setTitle("\u{f00d}", for: .normal) // fa-times
            mainButton.setTitleColor(.systemRed, for: .normal)
        } else if !isExpanded {
            canvasActive = false
            delegate?.didToggleCanvas(isActive: false)
            mainButton.setTitle("\u{f142}", for: .normal) // fa-ellipsis-v
            mainButton.setTitleColor(.darkGray, for: .normal)
        }
        
        if isExpanded {
            self.stackView.isHidden = false
            // Expande o frame para baixo para conter a stack view e permitir os toques nela
            let itemsCount = CGFloat(stackView.arrangedSubviews.count)
            let newHeight = buttonSize + spacing + (buttonSize * itemsCount) + (spacing * (itemsCount - 1))
            self.frame.size.height = newHeight
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.stackView.alpha = self.isExpanded ? 1.0 : 0.0
        }) { _ in
            if !self.isExpanded {
                self.stackView.isHidden = true
                self.frame.size.height = self.buttonSize // Retrai o frame
            }
        }
    }
    
    @objc private func selectYellow() {
        delegate?.didSelectTool(color: UIColor.systemYellow.withAlphaComponent(0.5), width: 25)
    }
    
    @objc private func selectRed() {
        delegate?.didSelectTool(color: .systemRed, width: 3)
    }
    
    @objc private func selectBlue() {
        delegate?.didSelectTool(color: .systemBlue, width: 3)
    }
    
    @objc private func clearCanvas() {
        delegate?.didSelectClear()
    }
}
