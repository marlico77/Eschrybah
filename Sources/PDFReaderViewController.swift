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
    
    private func setupNavigationBar() {
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
            // Habilita rolagem do PDF novamente
            if let scrollView = pdfView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
                scrollView.isScrollEnabled = true
            }
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
            
            // Trava rolagem do PDF
            if let scrollView = pdfView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
                scrollView.isScrollEnabled = false
            }
            
            let tip = UIAlertController(title: "Vidro Ativado", message: "A rolagem foi travada para você desenhar. Na próxima versão, esses grifos serão convertidos nativamente para o arquivo PDF.", preferredStyle: .alert)
            tip.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(tip, animated: true, completion: nil)
        }
    }
}
