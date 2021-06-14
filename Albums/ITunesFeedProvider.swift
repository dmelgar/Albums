//
//  AlbumsProvider.swift
//  Albums
//
//  Created by David Melgar on 6/8/21.
//

import Foundation

/*
 ITunesFeedProviderProvider: Responsible for loading ITunes feed from whatever data source, ie network, file, etc.

 If there are other data objects being loaded or if session management is needed, could inherit from a baseclass
 to centralize session management and data access primitives.
 */

typealias LoadFeedCompletionBlock = (Feed?, Error?) -> Void

protocol ITunesFeedProviderProtocol {
    func load(url: URL, completion: @escaping ((Feed?, Error?) -> Void))
}

class ITunesFeedProvider: ITunesFeedProviderProtocol {

    func load(url: URL, completion: @escaping LoadFeedCompletionBlock) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil,
                      let data = data else {
                    completion(nil, ITunesFeedError.networkError(error))
                    return
                }

                do {
                    let message = try JSONDecoder().decode(Message.self, from: data)
                    completion(message.feed, nil)
                } catch {
                    completion(nil, ITunesFeedError.parseError(error))
                }
            }
        }
        task.resume()
    }
}
