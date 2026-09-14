import UIKit
import PDFKit

class DocumentCell: UICollectionViewCell {
    
    let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = .systemBlue
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 16 // Mais arredondado
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.15
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowRadius = 8
        contentView.layer.masksToBounds = false // Para garantir que a sombra apareça fora do cornerRadius
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with url: URL) {
        titleLabel.text = url.lastPathComponent
        
        let ext = url.pathExtension.lowercased()
        
        // Setup initial generic icon
        switch ext {
        case "pdf":
            iconImageView.image = UIImage(named: "pdf_icon") ?? generatePlaceholder(color: .systemRed, text: "PDF")
            generatePDFThumbnail(url: url)
        case "epub":
            iconImageView.image = UIImage(named: "epub_icon") ?? generatePlaceholder(color: .systemOrange, text: "ePUB")
        case "txt", "md", "csv", "json":
            iconImageView.image = UIImage(named: "txt_icon") ?? generatePlaceholder(color: .systemGray, text: "TXT")
        case "docx", "doc":
            iconImageView.image = UIImage(named: "word_icon") ?? generatePlaceholder(color: .systemBlue, text: "DOC")
        default:
            iconImageView.image = UIImage(named: "generic_icon") ?? generatePlaceholder(color: .lightGray, text: "FILE")
        }
        
        iconImageView.backgroundColor = .clear
        iconImageView.layer.cornerRadius = 4
        iconImageView.clipsToBounds = true
    }
    
    private func generatePlaceholder(color: UIColor, text: String) -> UIImage? {
        let size = CGSize(width: 60, height: 80)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        color.setFill()
        UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 8).fill()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.white
        ]
        let textSize = text.size(withAttributes: attributes)
        let rect = CGRect(x: (size.width - textSize.width) / 2,
                          y: (size.height - textSize.height) / 2,
                          width: textSize.width,
                          height: textSize.height)
        text.draw(in: rect, withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func generatePDFThumbnail(url: URL) {
        DispatchQueue.global(qos: .background).async {
            if let document = PDFDocument(url: url), let page = document.page(at: 0) {
                let thumbnail = page.thumbnail(of: CGSize(width: 120, height: 160), for: .mediaBox)
                DispatchQueue.main.async {
                    self.iconImageView.image = thumbnail
                    self.iconImageView.contentMode = .scaleAspectFill
                }
            }
        }
    }
}
