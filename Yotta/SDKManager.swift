//
//  SDKManager.swift
//  Yotta
//
//  Created by Pedro Lacoste on 24-11-25.
//

import Foundation
import NetworkExtension

public final class SDKManager {

    public static let shared = SDKManager()

    private init() {}

    private var manager: NETunnelProviderManager?

    public func setup(completion: @escaping (Error?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error = error {
                completion(error)
                return
            }

            let manager = managers?.first ?? NETunnelProviderManager()
            manager.protocolConfiguration = NETunnelProviderProtocol()
            manager.localizedDescription = "Domain Monitoring"
            manager.isEnabled = true

            manager.saveToPreferences { error in
                self.manager = manager
                completion(error)
            }
        }
    }

    public func startMonitoring(completion: @escaping (Error?) -> Void) {
        guard let manager = manager else {
            completion(NSError(domain: "SDKManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Manager not initialized"]))
            return
        }

        manager.loadFromPreferences { error in
            if let error = error { completion(error); return }

            do {
                try manager.connection.startVPNTunnel()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func stopMonitoring() {
        manager?.connection.stopVPNTunnel()
    }
}
