//
//  AlbumError.swift
//  Albums
//
//  Created by David Melgar on 6/8/21.
//

import Foundation

enum AlbumError: Error {
    case badUrl
    case networkError(Error?)
    case parseError(Error)
}
