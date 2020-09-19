//
//  DuplicatedFileCheckable.swift
//  Created by Nixon Shih on 2020/9/17.
//

import Foundation

internal protocol DuplicatedFileCheckable {
    mutating func checkDuplicate(of fileURL: URL) throws -> Bool
}
