//
//  PacketTunnelProvider.swift
//  Yotta
//
//  Created by Pedro Lacoste on 24-11-25.
//

import Foundation

import NetworkExtension



class PacketTunnelProvider: NEPacketTunnelProvider {
    
    var pendingDomains: [String] = []

    override func startTunnel(options: [String : NSObject]?,
                              completionHandler: @escaping (Error?) -> Void) {

        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        settings.ipv4Settings = NEIPv4Settings(addresses: ["10.0.0.2"],
                                               subnetMasks: ["255.255.255.0"])

        setTunnelNetworkSettings(settings) { error in
            completionHandler(error)
        }

        startPacketCapture()
    }

    private func startPacketCapture() {
        packetFlow.readPackets { packets, _ in
            for packet in packets {
                if let domain = DomainExtractor.extract(from: packet) {
                    self.pendingDomains.append(domain)
                }
            }
            self.startPacketCapture()
        }
    }

    /// Recibe mensajes de la app
    override func handleAppMessage(_ messageData: Data,
                                   completionHandler: ((Data?) -> Void)?) {

        guard let command = String(data: messageData, encoding: .utf8) else {
            completionHandler?(nil)
            return
        }

        if command == "getdomains" {
            let response = try? JSONSerialization.data(withJSONObject: pendingDomains)
            pendingDomains.removeAll()
            completionHandler?(response)
            return
        }

        completionHandler?(nil)
    }
}
