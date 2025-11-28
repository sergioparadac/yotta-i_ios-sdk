//
//  PacketTunnelProvider.swift
//  Yotta
//
//  Created by Pedro Lacoste on 27-11-25.
//

import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {

    override func startTunnel(options: [String : NSObject]?,
                              completionHandler: @escaping (Error?) -> Void) {

        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        settings.ipv4Settings = NEIPv4Settings(addresses: ["10.0.0.2"], subnetMasks: ["255.255.255.0"])
        settings.mtu = 1500

        setTunnelNetworkSettings(settings) { error in
            completionHandler(error)
            if error == nil {
                self.readPackets()
            }
        }
    }

    private func readPackets() {
        packetFlow.readPackets { packets, protocols in
            for packet in packets {
                if let sni = self.extractSNI(from: packet) {
                    NotificationCenter.default.post(name: .sniDetected, object: sni)
                }
            }
            self.readPackets()
        }
    }

    private func extractSNI(from packet: Data) -> String? {
        guard packet.count > 5 else { return nil }

        var cursor = 0
        while cursor < packet.count - 5 {
            if packet[cursor] == 0x16 { // Handshake TLS
                let length = Int(packet[cursor + 3]) << 8 | Int(packet[cursor + 4])
                if cursor + 5 + length > packet.count { break }

                let handshake = packet[cursor + 5..<cursor + 5 + length]
                return parseClientHelloSNI(handshake: handshake)
            }
            cursor += 1
        }
        return nil
    }

    private func parseClientHelloSNI(handshake: Data) -> String? {
        var cursor = 38 // saltamos header + random + etc.
        guard handshake.count > cursor else { return nil }

        // Session ID
        let sessionIDLength = Int(handshake[cursor])
        cursor += 1 + sessionIDLength
        if cursor >= handshake.count { return nil }

        // Cipher Suites
        guard cursor + 2 <= handshake.count else { return nil }
        let cipherSuitesLength = Int(handshake[cursor]) << 8 | Int(handshake[cursor + 1])
        cursor += 2 + cipherSuitesLength
        if cursor >= handshake.count { return nil }

        // Compression Methods
        let compressionMethodsLength = Int(handshake[cursor])
        cursor += 1 + compressionMethodsLength
        if cursor >= handshake.count { return nil }

        // Extensions
        guard cursor + 2 <= handshake.count else { return nil }
        let extensionsLength = Int(handshake[cursor]) << 8 | Int(handshake[cursor + 1])
        cursor += 2
        let extensionsEnd = cursor + extensionsLength
        if extensionsEnd > handshake.count { return nil }

        while cursor + 4 <= extensionsEnd {
            let extType = Int(handshake[cursor]) << 8 | Int(handshake[cursor + 1])
            let extLen  = Int(handshake[cursor + 2]) << 8 | Int(handshake[cursor + 3])
            cursor += 4

            if extType == 0x00 { // Server Name
                guard cursor + extLen <= extensionsEnd else { return nil }

                var extCursor = cursor
                _ = Int(handshake[extCursor]) << 8 | Int(handshake[extCursor + 1])
                extCursor += 2

                while extCursor + 3 <= cursor + extLen {
                    let nameType = handshake[extCursor]
                    let nameLen  = Int(handshake[extCursor + 1]) << 8 | Int(handshake[extCursor + 2])
                    extCursor += 3
                    if extCursor + nameLen > cursor + extLen { break }

                    if nameType == 0 { // host_name
                        let domainData = handshake[extCursor..<extCursor+nameLen]
                        return String(data: domainData, encoding: .utf8)
                    }
                    extCursor += nameLen
                }
            }
            cursor += extLen
        }

        return nil
    }
}
