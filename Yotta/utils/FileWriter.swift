//
//  FileWriter.swift
//  Yotta
//
//  Created by Pedro Lacoste on 24-11-25.
//

import Foundation

final class FileWriter {

    private let fileURL: URL

    init(fileName: String) {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documents.appendingPathComponent(fileName)
    }

    func append(text: String) {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            if let handle = try? FileHandle(forWritingTo: fileURL) {
                handle.seekToEndOfFile()
                handle.write(text.data(using: .utf8)!)
                handle.closeFile()
            }
        } else {
            try? text.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }
}
