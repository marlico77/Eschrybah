import UIKit
import PDFKit

class PDFReaderViewController: UIViewController {
    
    let fileURL: URL
    var pdfView: PDFView!
    
    init(fileURL: URL) {
        self.fileURL = fileURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        title = fileURL.lastPathComponent
        
        pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        if let document = PDFDocument(url: fileURL) {
            pdfView.document = document
            pdfView.displayMode = .singlePageContinuous
            pdfView.autoScales = true
        }
        
        setupNavigationBar()
    }
    
    private var canvasView: AnnotationCanvasView?
    private var floatingMenu: FloatingMenuButton!
    
    private func setupNavigationBar() {
        // Remover menu superior
        navigationItem.rightBarButtonItem = nil
        setupFloatingMenu()
    }
    
    private func setupFloatingMenu() {
        floatingMenu = FloatingMenuButton()
        floatingMenu.delegate = self
        // Não usar AutoLayout para permitir arrastar livremente via frame/center
        view.addSubview(floatingMenu)
    }
}

extension PDFReaderViewController: FloatingMenuDelegate {
    func didSelectTool(color: UIColor, width: CGFloat) {
        canvasView?.drawingColor = color
        canvasView?.drawingWidth = width
    }
    
    func didSelectClear() {
        canvasView?.clear()
    }
    
    func didToggleCanvas(isActive: Bool) {
        if isActive {
            let canvas = AnnotationCanvasView(frame: .zero)
            canvas.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(canvas, belowSubview: floatingMenu)
            
            NSLayoutConstraint.activate([
                canvas.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                canvas.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                canvas.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            canvasView = canvas
            
            if let scrollView = pdfView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
                scrollView.isScrollEnabled = false
            }
        } else {
            canvasView?.removeFromSuperview()
            canvasView = nil
            if let scrollView = pdfView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
                scrollView.isScrollEnabled = true
            }
        }
    }
}
