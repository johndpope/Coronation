/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view controller to support selection of virtual content.
*/

import UIKit

class ContentCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: ContentCell.self)
    
    @IBOutlet weak var imageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                imageView.backgroundColor = .clear
                imageView.layer.borderWidth = 1.0
                imageView.layer.borderColor = UIColor.lightGray.cgColor
                contentView.alpha = 1.0
            } else {
                imageView.backgroundColor = .clear
                imageView.layer.borderWidth = 0.0
                contentView.alpha = 0.5
            }
        }
    }
}

class CollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: CollectionViewCell.self)
    
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.tintColor = UIColor(red: 240/255, green: 185/255, blue: 180/255, alpha: 1.0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.frame.size.width / 2
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                contentView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                contentView.layer.borderColor = UIColor(red: 240/255, green: 185/255, blue: 180/255, alpha: 1.0).cgColor
                contentView.layer.borderWidth = 1.0
                contentView.alpha = 1.0
                contentView.layer.cornerRadius = contentView.frame.size.width / 2
            } else {
                contentView.backgroundColor = .clear
                contentView.layer.borderWidth = 0.0
                contentView.alpha = 0.5
                contentView.layer.cornerRadius = contentView.frame.size.width / 2
            }
        }
    }
}


class ContentSelectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var selectedVirtualContent: VirtualContentType = .crown

    /// Invoked when the `selectedVirtualContent` property changes.
    var selectionHandler: (VirtualContentType) -> Void = { _ in }

    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: 5, height: 292)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let itemIndex = selectedVirtualContent.rawValue
        let indexPath = IndexPath(item: itemIndex, section: 0)
        collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: .bottom)
    }

    // MARK: - UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return VirtualContentType.orderedValues.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCell.reuseIdentifier, for: indexPath) as? ContentCell else {
            fatalError("Expected `\(ContentCell.self)` type for reuseIdentifier \(ContentCell.reuseIdentifier). Check the configuration in Main.storyboard.")
        }

        let content = VirtualContentType(rawValue: indexPath.item)!
        cell.imageView.contentMode = .scaleAspectFit
        cell.imageView?.image = UIImage(named: content.imageName)
        cell.isSelected = indexPath.item == selectedVirtualContent.rawValue
        
        return cell
    }

    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedVirtualContent = VirtualContentType(rawValue: indexPath.item)!
        selectionHandler(selectedVirtualContent)
        dismiss(animated: true, completion: nil)
    }
}
