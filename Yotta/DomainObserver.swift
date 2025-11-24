//
//  DomainObserver.swift
//  Yotta
//
//  Created by Pedro Lacoste on 24-11-25.
//

import Foundation

public final class DomainObserver {

    public static let shared = DomainObserver()

    private init() {}

    public var onDomainDetected: ((String) -> Void)?

    func handle(domain: String) {
        onDomainDetected?(domain)
        LogManager.shared.append(domain)
    }
}
