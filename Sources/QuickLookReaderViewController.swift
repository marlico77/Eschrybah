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
    
    private func setupAnnotationMenu() {
        let optionsButton = UIBarButtonItem(title: "Opções", style: .plain, target: self, action: #selector(showOptionsMenu))
        navigationItem.rightBarButtonItem = optionsButton
    }
    
    @objc private func showOptionsMenu() {
        let alert = UIAlertController(title: "Ferramentas", message: "Escolha uma ação", preferredStyle: .actionSheet)
        
        let toggleDrawing = UIAlertAction(title: canvasView == nil ? "Grifar na Tela (Vidro)" : "Desligar Vidro", style: .default) { _ in
            self.toggleCanvas()
        }
        
        let clearDrawing = UIAlertAction(title: "Limpar Grifos", style: .destructive) { _ in
            self.canvasView?.clear()
        }
        
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(toggleDrawing)
        if canvasView != nil {
            alert.addAction(clearDrawing)
        }
        alert.addAction(cancel)
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func toggleCanvas() {
        if let canvas = canvasView {
            canvas.removeFromSuperview()
            canvasView = nil
            // Enable interaction on preview controller again
            previewController.view.isUserInteractionEnabled = true
        } else {
            let canvas = AnnotationCanvasView(frame: .zero)
            canvas.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(canvas)
            
            NSLayoutConstraint.activate([
                canvas.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                canvas.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                canvas.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            canvasView = canvas
            // Disable interaction underneath so we can draw smoothly
            previewController.view.isUserInteractionEnabled = false
            
            let tip = UIAlertController(title: "Vidro Ativado", message: "Você está desenhando num vidro por cima do arquivo. A rolagem de página foi travada temporariamente.", preferredStyle: .alert)
            tip.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(tip, animated: true, completion: nil)
        }
    }
    
    // MARK: - QLPreviewControllerDataSource
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileURL as QLPreviewItem
    }
}
