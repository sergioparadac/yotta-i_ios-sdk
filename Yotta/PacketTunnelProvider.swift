//
//  PacketTunnelProvider.swift
//  Yotta
//
//  Created by Pedro Lacoste on 12-11-25.
//

import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        settings.ipv4Settings = NEIPv4Settings(addresses: ["192.168.1.2"], subnetMasks: ["255.255.255.0"])
        settings.ipv4Settings?.includedRoutes = [NEIPv4Route.default()]
        settings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8"])

        setTunnelNetworkSettings(settings) { error in
            guard error == nil else { return completionHandler(error) }

            self.packetFlow.readPackets { packets, protocols in
                for packet in packets {
                    self.handlePacket(packet)
                }
            }

            completionHandler(nil)
        }
    }

    func protocolForPacket(_ packet: Data) -> NSNumber? {
        guard packet.count > 0 else { return nil }
        let firstByte = packet[packet.startIndex]

        switch firstByte >> 4 {
        case 4:
            return NSNumber(value: AF_INET)   // IPv4
        case 6:
            return NSNumber(value: AF_INET6)  // IPv6
        default:
            return nil
        }
    }

    
    func handlePacket(_ packet: Data) {
        if let sni = extractSNI(from: packet) {
            print("SNI detectado: \(sni)")
            sendSNIToAPI(sni)
        }

        if let proto = protocolForPacket(packet) {
            packetFlow.writePackets([packet], withProtocols: [proto])
        } else {
            print("Protocolo desconocido, no se reenvía el paquete")
        }
    }


    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
