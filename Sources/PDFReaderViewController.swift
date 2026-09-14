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
    
    private func setupNavigationBar() {
        let highlightButton = UIBarButtonItem(title: "Grifar", style: .plain, target: self, action: #selector(toggleHighlightMode))
        navigationItem.rightBarButtonItems = [highlightButton]
    }
    
    @objc private func toggleHighlightMode() {
        // Simple implementation: alert the user that drawing mode is conceptual for now
        // A full annotation system requires subclassing PDFView or adding gesture recognizers
        // to convert touches to PDFAnnotation instances.
        let alert = UIAlertController(title: "Modo de Anotação", message: "Selecione texto no PDF nativamente para usar a ferramenta de marca-texto nativa do iOS.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
