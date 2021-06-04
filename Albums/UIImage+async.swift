//
//  UIImage+async.swift
//  Albums
//
//  Created by David Melgar on 6/4/21.
//

import Foundation
import UIKit

extension UIImage {
    static func asyncLoad(url: URL, completion: @escaping ((UIImage?, Error?)->Void)) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
             DispatchQueue.main.async {
                guard error == nil,
                      let data = data else {
                    let configuration = UIImage.SymbolConfiguration(pointSize: 25)
                    let image = UIImage(systemName: "xmark.icloud", withConfiguration: configuration)
                    completion(image, error)
                    return
                }
                completion(UIImage(data: data), nil)
             }
        }
        task.resume()
    }
}
