import UIKit

class DocumentEngineManager {
    static let shared = DocumentEngineManager()
    
    private init() {}
    
    func openDocument(at url: URL, from viewController: UIViewController) {
        let ext = url.pathExtension.lowercased()
        
        var targetViewController: UIViewController?
        
        switch ext {
        case "pdf":
            targetViewController = PDFReaderViewController(fileURL: url)
        case "txt", "md", "csv", "json", "rtf", "log":
            targetViewController = TextReaderViewController(fileURL: url)
        case "epub":
            targetViewController = EpubReaderViewController(fileURL: url)
        case "docx", "doc", "xlsx", "xls", "pptx", "ppt", "pages", "numbers", "key":
            targetViewController = QuickLookReaderViewController(fileURL: url)
        default:
            // Fallback to QuickLook for unknown types
            targetViewController = QuickLookReaderViewController(fileURL: url)
        }
        
        if let vc = targetViewController {
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
