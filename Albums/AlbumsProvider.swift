//
//  AlbumsProvider.swift
//  Albums
//
//  Created by David Melgar on 6/8/21.
//

import Foundation

/*
 AlbumsProvider: Responsible for loading album array for whatever data source, ie network, file, etc.

 If there are other data objects being loaded or if session management is needed, could use a baseclass
 to centralize session management and data access primitives.
 */
class AlbumsProvider {
    static func load(completion: @escaping (([Album]?, Error?) -> Void)) {
        guard let url = URL(string: "https://rss.itunes.apple.com/api/v1/us/itunes-music/top-songs/all/100/explicit.json") else {
            completion(nil, AlbumError.badUrl)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil,
                      let data = data else {
                    completion(nil, AlbumError.networkError(error))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(Message.self, from: data)
                    completion(result.feed.results, nil)
                } catch {
                    completion(nil, AlbumError.parseError(error))
                }
            }
        }
        task.resume()
    }
}
