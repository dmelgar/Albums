//
//  AlbumsViewController.swift
//  Albums
//
//  Created by David Melgar on 6/3/21.
//

import UIKit

class AlbumsViewController: UIViewController {

    var albums = [Album]()
    var tableView = UITableView()
    var spinner = UIActivityIndicatorView(style: .large)

    let cellIdentifier = "AlbumCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        title = NSLocalizedString("Top 100 Albums", comment: "Main album list title")

        view = tableView
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.backgroundColor = .systemBackground

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()

        view.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([view.centerYAnchor.constraint(equalTo: spinner.centerYAnchor),
                                     view.centerXAnchor.constraint(equalTo: spinner.centerXAnchor)])

        loadData(tableView: tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        if let row = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: row, animated: false)
        }
    }

    func loadData(tableView: UITableView) {
        spinner.startAnimating()
        AlbumsProvider.load { albums, error in
            guard error == nil,
                  let albums = albums else {
                self.displayError(NSLocalizedString("Error loading albums. \(error?.localizedDescription ?? "")", comment: "Error message"), displayAction: false)
                return
            }
            self.albums = albums
            tableView.reloadData()
            self.spinner.stopAnimating()
        }
    }

    func displayError(_ txt: String, displayAction: Bool) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error title"),
                                      message: txt, preferredStyle: .alert)
        if displayAction {
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"),
                                          style: .default, handler: { action in
                // Retry loading data
                self.loadData(tableView: self.tableView)
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }
}

extension AlbumsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) else {
            displayError(NSLocalizedString("Unrecoverable error", comment: "Internal error"), displayAction: false)
            return UITableViewCell()
        }
        var content = cell.defaultContentConfiguration()

        content.imageProperties.reservedLayoutSize = CGSize(width: 40, height: 40)
        content.imageProperties.maximumSize = CGSize(width: 50, height: 50)

        let album = albums[indexPath.row]
        cell.tag = album.idInt()
        content.text = album.name
        content.secondaryText = album.artistName
        content.image = UIImage()

        if let artworkUrl = album.artworkUrl {
            UIImage.asyncLoad(url: artworkUrl) { image, error in
                // Check to make sure cell hasn't been reused while waiting to load image
                guard cell.tag == album.idInt() else { return }
                content.image = image
                cell.contentConfiguration = content
            }
        }

        cell.contentConfiguration = content
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension AlbumsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = AlbumDetailViewController()
        nextVC.loadData(album: albums[indexPath.row])
        navigationController?.pushViewController(nextVC, animated: true)
    }
}
