//
//  DataModel.swift
//  Albums
//
//  Created by David Melgar on 6/4/21.
//

import Foundation
import UIKit

struct Message: Decodable {
    let feed: Feed
}
struct Feed: Decodable {
    let title: String
    let results: [Album]
}

struct Album: Decodable {
    let id: String
    let name: String
    let artistName: String
    private let artworkUrl100: String?
    let genres: [Genre]
    let releaseDate: String?
    let copyright: String?
    private let url: String?

    func idInt() -> Int {
        return Int(id) ?? 0
    }

    var iTunesURL: URL? {
        guard let url = url else { return nil }
        return URL(string: url)
    }

    var artworkUrl: URL? {
        guard let artworkUrl100 = artworkUrl100 else { return nil }
        return URL(string: artworkUrl100)
    }

}

struct Genre: Decodable {
    let name: String
}
