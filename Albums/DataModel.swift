//
//  DataModel.swift
//  Albums
//
//  Created by David Melgar on 6/4/21.
//

import Foundation

struct Message: Decodable {
    let feed:Feed
}
struct Feed: Decodable {
    let results: [Album]
}

struct Album: Decodable {
    let id: String
    let name: String
    let artistName: String
    private let artworkUrl100: String
    let genres: [Genre]
    let releaseDate: String
    let copyright: String
    private let url: String

    func idInt() -> Int {
        return Int(id) ?? 0
    }

    var iTunesURL: URL? {
        URL(string: url)
    }

    var artworkUrl: URL? {
        URL(string: artworkUrl100)
    }
}

struct Genre: Decodable {
    let name: String
}
