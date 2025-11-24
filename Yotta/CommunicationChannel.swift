//
//  CommunicationChannel.swift
//  Yotta
//
//  Created by Pedro Lacoste on 24-11-25.
//

import Foundation
import NetworkExtension

final class CommunicationChannel {

    static let shared = CommunicationChannel()

    private init() {}

    func sendDomainToObservers(_ domain: String) {
        DomainObserver.shared.handle(domain: domain)
    }
}
