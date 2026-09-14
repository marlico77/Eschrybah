import UIKit

struct Stroke {
    let path: UIBezierPath
    let color: UIColor
    let width: CGFloat
    let blendMode: CGBlendMode
}

class AnnotationCanvasView: UIView {
    
    var drawingColor: UIColor = .systemYellow {
        didSet { currentBlendMode = .normal }
    }
    var drawingWidth: CGFloat = 20.0
    var isEraser: Bool = false
    
    private var strokes: [Stroke] = []
    private var undoneStrokes: [Stroke] = []
    
    private var currentPath: UIBezierPath?
    private var currentBlendMode: CGBlendMode = .normal
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isMultipleTouchEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Undo / Redo / Clear
    
    func undo() {
        guard !strokes.isEmpty else { return }
        let stroke = strokes.removeLast()
        undoneStrokes.append(stroke)
        setNeedsDisplay()
    }
    
    func redo() {
        guard !undoneStrokes.isEmpty else { return }
        let stroke = undoneStrokes.removeLast()
        strokes.append(stroke)
        setNeedsDisplay()
    }
    
    func clear() {
        strokes.removeAll()
        undoneStrokes.removeAll()
        setNeedsDisplay()
    }
    
    // MARK: - Drawing Logic
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        for stroke in strokes {
            context.setBlendMode(stroke.blendMode)
            stroke.color.setStroke()
            stroke.path.lineWidth = stroke.width
            stroke.path.lineCapStyle = .round
            stroke.path.lineJoinStyle = .round
            stroke.path.stroke()
        }
        
        if let currentPath = currentPath, !isEraser {
            context.setBlendMode(currentBlendMode)
            drawingColor.setStroke()
            currentPath.lineWidth = drawingWidth
            currentPath.lineCapStyle = .round
            currentPath.lineJoinStyle = .round
            currentPath.stroke()
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        
        if isEraser {
            eraseStroke(at: point)
        } else {
            currentPath = UIBezierPath()
            currentPath?.move(to: point)
            undoneStrokes.removeAll() // Any new drawing invalidates redo history
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        
        if isEraser {
            eraseStroke(at: point)
        } else {
            currentPath?.addLine(to: point)
            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isEraser, let path = currentPath {
            let newStroke = Stroke(path: path, color: drawingColor, width: drawingWidth, blendMode: currentBlendMode)
            strokes.append(newStroke)
            currentPath = nil
            setNeedsDisplay()
        }
    }
    
    // MARK: - Eraser Logic
    
    private func eraseStroke(at point: CGPoint) {
        // Aumentamos a área de toque para facilitar a exclusão
        let touchRect = CGRect(x: point.x - 20, y: point.y - 20, width: 40, height: 40)
        
        var indexesToRemove: [Int] = []
        
        for (index, stroke) in strokes.enumerated() {
            if stroke.path.bounds.intersects(touchRect) {
                // Checagem mais fina: iterar por pontos ou simplificar usando contains,
                // mas UIBezierPath.contains é para preenchimento. Para strokes, usamos bounds
                // ou criamos um stroked path (mais caro, mas no iOS 12 é ok para apps simples).
                indexesToRemove.append(index)
            }
        }
        
        if !indexesToRemove.isEmpty {
            for index in indexesToRemove.reversed() {
                strokes.remove(at: index)
            }
            setNeedsDisplay()
        }
    }
}
