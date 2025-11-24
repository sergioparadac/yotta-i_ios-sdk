//
//  LogManager.swift
//  Yotta
//
//  Created by Pedro Lacoste on 24-11-25.
//

import Foundation

public final class LogManager {

    public static let shared = LogManager()

    private let fileWriter = FileWriter(fileName: "network_log.txt")

    private init() {}

    func append(_ domain: String) {
        let entry = "[\(Date())] \(domain)\n"
        fileWriter.append(text: entry)
    }
}
