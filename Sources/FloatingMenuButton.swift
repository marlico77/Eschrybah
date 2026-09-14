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
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .clear
        
        mainButton.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        mainButton.backgroundColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1.0)
        mainButton.setTitle("•••", for: .normal)
        mainButton.setTitleColor(.white, for: .normal)
        mainButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        mainButton.layer.cornerRadius = 30
        mainButton.layer.shadowColor = UIColor.black.cgColor
        mainButton.layer.shadowOpacity = 0.3
        mainButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        mainButton.layer.shadowRadius = 5
        mainButton.addTarget(self, action: #selector(toggleMenu), for: .touchUpInside)
        
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.alpha = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(stackView)
        self.addSubview(mainButton)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: mainButton.centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: mainButton.leadingAnchor, constant: -15)
        ])
        
        setupTools()
    }
    
    private func setupTools() {
        let yellowBtn = createToolButton(color: UIColor.systemYellow.withAlphaComponent(0.5), title: "🖊️")
        yellowBtn.addTarget(self, action: #selector(selectYellow), for: .touchUpInside)
        
        let redBtn = createToolButton(color: .red, title: "🖍️")
        redBtn.addTarget(self, action: #selector(selectRed), for: .touchUpInside)
        
        let blueBtn = createToolButton(color: .blue, title: "📘")
        blueBtn.addTarget(self, action: #selector(selectBlue), for: .touchUpInside)
        
        let clearBtn = createToolButton(color: .darkGray, title: "🗑️")
        clearBtn.addTarget(self, action: #selector(clearCanvas), for: .touchUpInside)
        
        stackView.addArrangedSubview(clearBtn)
        stackView.addArrangedSubview(blueBtn)
        stackView.addArrangedSubview(redBtn)
        stackView.addArrangedSubview(yellowBtn)
    }
    
    private func createToolButton(color: UIColor, title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.backgroundColor = color.withAlphaComponent(0.8)
        btn.setTitle(title, for: .normal)
        btn.layer.cornerRadius = 20
        btn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return btn
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
        } else if gesture.state == .ended {
            // Snap to edges logic could go here
        }
    }
    
    @objc private func toggleMenu() {
        isExpanded.toggle()
        
        if isExpanded && !canvasActive {
            canvasActive = true
            delegate?.didToggleCanvas(isActive: true)
            mainButton.backgroundColor = .systemBlue
            mainButton.setTitle("❌", for: .normal)
        } else if !isExpanded {
            canvasActive = false
            delegate?.didToggleCanvas(isActive: false)
            mainButton.backgroundColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1.0)
            mainButton.setTitle("•••", for: .normal)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.stackView.alpha = self.isExpanded ? 1.0 : 0.0
            if self.isExpanded {
                self.frame.origin.x -= 250 // Expands to the left
                self.frame.size.width += 250
                self.mainButton.frame.origin.x += 250
            } else {
                self.mainButton.frame.origin.x -= 250
                self.frame.size.width -= 250
                self.frame.origin.x += 250
            }
        }
    }
    
    @objc private func selectYellow() {
        delegate?.didSelectTool(color: UIColor.systemYellow.withAlphaComponent(0.5), width: 20)
    }
    
    @objc private func selectRed() {
        delegate?.didSelectTool(color: .red, width: 3)
    }
    
    @objc private func selectBlue() {
        delegate?.didSelectTool(color: .blue, width: 3)
    }
    
    @objc private func clearCanvas() {
        delegate?.didSelectClear()
    }
}
