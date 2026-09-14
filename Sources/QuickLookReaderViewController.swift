import UIKit
import QuickLook

class QuickLookReaderViewController: UIViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    let fileURL: URL
    let previewController = QLPreviewController()
    
    init(fileURL: URL) {
        self.fileURL = fileURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = fileURL.lastPathComponent
        
        previewController.dataSource = self
        previewController.delegate = self
        
        addChild(previewController)
        view.addSubview(previewController.view)
        
        previewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            previewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            previewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            previewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        previewController.didMove(toParent: self)
        setupAnnotationMenu()
    }
    
    private var canvasView: AnnotationCanvasView?
    private var floatingMenu: FloatingMenuButton!
    
    private func setupAnnotationMenu() {
        navigationItem.rightBarButtonItem = nil
        setupFloatingMenu()
    }
    
    private func setupFloatingMenu() {
        floatingMenu = FloatingMenuButton()
        floatingMenu.delegate = self
        floatingMenu.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingMenu)
        
        NSLayoutConstraint.activate([
            floatingMenu.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            floatingMenu.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            floatingMenu.widthAnchor.constraint(equalToConstant: 300),
            floatingMenu.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - QLPreviewControllerDataSource
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileURL as QLPreviewItem
    }
}

extension QuickLookReaderViewController: FloatingMenuDelegate {
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
            previewController.view.isUserInteractionEnabled = false
        } else {
            canvasView?.removeFromSuperview()
            canvasView = nil
            previewController.view.isUserInteractionEnabled = true
        }
    }
}
