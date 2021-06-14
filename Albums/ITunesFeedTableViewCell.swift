//
//  AlbumsTableViewCell.swift
//  Albums
//
//  Created by David Melgar on 6/11/21.
//

import UIKit

class ITunesFeedTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "albumCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        var content = self.defaultContentConfiguration()
        content.imageProperties.reservedLayoutSize = CGSize(width: 40, height: 40)
        content.imageProperties.maximumSize = CGSize(width: 50, height: 50)
        contentConfiguration = content
    }
    
    func update(album: Album) {
        tag = album.idInt()
        guard var content = contentConfiguration as? UIListContentConfiguration else { return }
        content.text = album.name
        content.secondaryText = album.artistName
        content.image = UIImage()

        if let artworkUrl = album.artworkUrl {
            UIImage.asyncLoad(url: artworkUrl) { image, error in
                // Check to make sure cell hasn't been reused while waiting to load image
                guard self.tag == album.idInt() else { return }
                guard let image = image else {
                    let configuration = UIImage.SymbolConfiguration(pointSize: 25)
                    content.image = UIImage(systemName: "xmark.icloud", withConfiguration: configuration)
                    self.contentConfiguration = content
                    return
                }
                content.image = image
                self.contentConfiguration = content
            }
        }
        contentConfiguration = content
    }
}
