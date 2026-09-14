import UIKit

class AnnotationCanvasView: UIView {
    
    private var paths: [UIBezierPath] = []
    private var currentPath: UIBezierPath?
    
    var drawingColor: UIColor = UIColor.systemYellow.withAlphaComponent(0.5)
    var drawingWidth: CGFloat = 15.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        // Add a visual indicator that glass mode is active
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        currentPath = UIBezierPath()
        currentPath?.lineWidth = drawingWidth
        currentPath?.lineCapStyle = .round
        currentPath?.lineJoinStyle = .round
        currentPath?.move(to: location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let path = currentPath else { return }
        let location = touch.location(in: self)
        path.addLine(to: location)
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let path = currentPath {
            paths.append(path)
        }
        currentPath = nil
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawingColor.setStroke()
        
        for path in paths {
            path.stroke()
        }
        
        if let path = currentPath {
            path.stroke()
        }
    }
    
    func clear() {
        paths.removeAll()
        setNeedsDisplay()
    }
}
