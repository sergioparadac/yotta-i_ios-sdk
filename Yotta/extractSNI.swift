//
//  extractSNI.swift
//  Yotta
//
//  Created by Pedro Lacoste on 12-11-25.
//

import Foundation

func extractSNI(from packet: Data) -> String? {
    let bytes = [UInt8](packet)
    guard bytes.count > 5, bytes[0] == 0x16 else { return nil }

    var index = 5
    guard bytes[index] == 0x01 else { return nil }
    index += 4 + 2 + 32
    let sessionIDLength = Int(bytes[index])
    index += 1 + sessionIDLength

    let cipherSuiteLength = Int(bytes[index]) << 8 | Int(bytes[index + 1])
    index += 2 + cipherSuiteLength

    let compressionMethodLength = Int(bytes[index])
    index += 1 + compressionMethodLength

    guard index + 2 <= bytes.count else { return nil }
    let extensionsLength = Int(bytes[index]) << 8 | Int(bytes[index + 1])
    index += 2

    let extensionsEnd = index + extensionsLength
    while index + 4 <= extensionsEnd && index + 4 <= bytes.count {
        let extType = Int(bytes[index]) << 8 | Int(bytes[index + 1])
        let extLen = Int(bytes[index + 2]) << 8 | Int(bytes[index + 3])
        index += 4

        if extType == 0x00 {
            guard index + 5 <= bytes.count else { return nil }
            let sniLen = Int(bytes[index + 3]) << 8 | Int(bytes[index + 4])
            let sniStart = index + 5
            let sniEnd = sniStart + sniLen
            guard sniEnd <= bytes.count else { return nil }
            let sniBytes = bytes[sniStart..<sniEnd]
            return String(bytes: sniBytes, encoding: .utf8)
        }

        index += extLen
    }

    return nil
}
