//
//  VPNManager.swift
//  Yotta
//
//  Created by Pedro Lacoste on 12-11-25.
//

import NetworkExtension

class VPNManager {
    static let shared = VPNManager()
    private let manager = NEVPNManager.shared()

    func setupVPN(completion: @escaping (Error?) -> Void) {
        manager.loadFromPreferences { error in
            guard error == nil else { return completion(error) }

            let protocolConfig = NETunnelProviderProtocol()
            protocolConfig.providerBundleIdentifier = "com.tuempresa.SNITrackerTunnel"
            protocolConfig.serverAddress = "SNITrackerVPN"

            self.manager.protocolConfiguration = protocolConfig
            self.manager.localizedDescription = "SNI Tracker VPN"
            self.manager.isEnabled = true

            self.manager.saveToPreferences { error in
                completion(error)
            }
        }
    }

    func startVPN() {
        do {
            try manager.connection.startVPNTunnel()
        } catch {
            print("Error al iniciar VPN: \(error)")
        }
    }

    func stopVPN() {
        manager.connection.stopVPNTunnel()
    }
}
