//
//  AlbumDetailViewController.swift
//  Albums
//
//  Created by David Melgar on 6/3/21.
//

import UIKit

class AlbumDetailViewController: UIViewController {

    private var album: Album?
    var stackView = UIStackView()
    let iTunesButton = UIButton()

    let themeColor = UIColor.systemBlue
    
    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let album = album else { return }
        
        view.backgroundColor = .systemBackground
        
        // Configure button
        iTunesButton.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
        iTunesButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iTunesButton)
        iTunesButton.setTitle(NSLocalizedString("View album in iTunes", comment: "iTunes button label"), for: .normal)
        iTunesButton.backgroundColor = themeColor
        NSLayoutConstraint.activate([
            iTunesButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            iTunesButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            iTunesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        // Configure scroll view
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                                        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
                                        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
                                        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
                                        scrollView.bottomAnchor.constraint(equalTo: iTunesButton.topAnchor, constant: -20)])

        // Configure stack view
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 20

        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 0),
            stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 0),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        populateStackView(album: album)
    }

    private func populateStackView(album: Album) {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        if let artworkUrl = album.artworkUrl {
            UIImage.asyncLoad(url: artworkUrl) { image, error in
                imageView.image = image
            }
        }

        if let url = album.iTunesURL,
           UIApplication.shared.canOpenURL(url) {
            iTunesButton.isHidden = false
        } else {
            iTunesButton.isHidden = true
        }

        stackView.addArrangedSubview(imageView)
        
        // Centering text doesn't take effect until added to parent view
        buildLabels(album: album).forEach {
            stackView.addArrangedSubview($0)
            $0.textAlignment = .center
        }
    }

    func labelForText(_ text: String?) -> UILabel? {
        guard let text = text else { return nil }
        let result = UILabel()
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        result.text = text
        return result
    }

    func buildLabels(album: Album) -> [UILabel] {
        var labels = [UILabel]()

        if let title = labelForText(album.name) {
            title.font = UIFont.systemFont(ofSize: 34, weight: .semibold)
            labels.append(title)
        }

        if let artist = labelForText(album.artistName) {
            artist.font = UIFont.systemFont(ofSize: 34)
            artist.textColor = themeColor
            labels.append(artist)
        }

        let genreString = album.genres.map({$0.name}).joined(separator: ", ")
        if let genres = labelForText(genreString) {
            genres.font = UIFont.systemFont(ofSize: 15)
            labels.append(genres)
        }

        if let label = labelForText(album.releaseDate) {
            label.font = UIFont.systemFont(ofSize: 15)
            labels.append(label)
        }

        if let copyright = labelForText(album.copyright) {
            copyright.font = UIFont.italicSystemFont(ofSize: 15)
            labels.append(copyright)
        }

        return labels
    }

    @objc func buttonAction(sender: UIButton) {
        if let url = album?.iTunesURL,
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}
