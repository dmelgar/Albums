//
//  AlbumsViewController.swift
//  Albums
//
//  Created by David Melgar on 6/3/21.
//

import UIKit

class ITunesFeedViewController: UIViewController {

    var feed: Feed?
    var tableView = UITableView()
    var spinner = UIActivityIndicatorView(style: .large)
    var feedProvider: ITunesFeedProviderProtocol
    var feedURL: URL?
    static let defaultFeedURL = URL(string: "https://rss.itunes.apple.com/api/v1/us/itunes-music/top-songs/all/100/explicit.json")
    
    // Allow ITunesFeedProvider to be injected for testability
    init(feedProvider: ITunesFeedProviderProtocol? = nil, feedURL: URL? = defaultFeedURL) {
        self.feedURL = feedURL
        self.feedProvider = feedProvider ?? ITunesFeedProvider()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.feedProvider = ITunesFeedProvider()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = .systemBackground

        view = tableView
        tableView.register(ITunesFeedTableViewCell.self, forCellReuseIdentifier: ITunesFeedTableViewCell.cellIdentifier)
        tableView.backgroundColor = .systemBackground

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()

        view.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([view.centerYAnchor.constraint(equalTo: spinner.centerYAnchor),
                                     view.centerXAnchor.constraint(equalTo: spinner.centerXAnchor)])

        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        if let row = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: row, animated: false)
        }
    }

    func loadData() {
        guard let feedURL = feedURL else { return }
        spinner.startAnimating()
        feedProvider.load(url: feedURL) { feed, error in
            guard error == nil,
                  let feed = feed else {
                self.displayError(NSLocalizedString("Error loading albums. \(error?.localizedDescription ?? "")", comment: "Error message"), displayAction: true)
                return
            }
            self.feed = feed
            self.title = feed.title
            self.tableView.reloadData()
            self.spinner.stopAnimating()
        }
    }
}

// Error handling
extension ITunesFeedViewController {
    func displayError(_ txt: String, displayAction: Bool) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error title"),
                                      message: txt, preferredStyle: .alert)
        if displayAction {
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"),
                                          style: .default, handler: { action in
                // Retry loading data
                self.loadData()
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }
}

extension ITunesFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ITunesFeedTableViewCell.cellIdentifier) as? ITunesFeedTableViewCell,
              let album = feed?.results[indexPath.row] else {
            displayError(NSLocalizedString("Unrecoverable error", comment: "Internal error"), displayAction: false)
            return UITableViewCell()
        }
        cell.update(album: album)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed?.results.count ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension ITunesFeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let album = feed?.results[indexPath.row] else { return }
        let nextVC = AlbumDetailViewController(album: album)
        navigationController?.pushViewController(nextVC, animated: true)
    }
}
