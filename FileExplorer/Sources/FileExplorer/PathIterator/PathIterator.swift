//
//  PathIterator.swift
//  Created by Nixon Shih on 2020/9/16.
//

import Foundation

public protocol PathIterator {
    func next() -> URL?
}
