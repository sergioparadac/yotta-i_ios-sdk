//
//  DomainExtractor.swift
//  Yotta
//
//  Created by Pedro Lacoste on 24-11-25.
//

import Foundation

final class DomainExtractor {

    static func extract(from packet: Data) -> String? {

        // SIMPLE DNS PARSER (solo nombres de dominio, no contenido)
        if isDNS(packet) {
            return parseDNSQuery(packet)
        }

        // SIMPLE SNI PARSER (TLS ClientHello)
        if isTLSClientHello(packet) {
            return parseSNI(packet)
        }

        return nil
    }

    private static func isDNS(_ packet: Data) -> Bool {
        // Verifica puerto 53 UDP (muy simplificado)
        return packet.count > 40
    }

    private static func parseDNSQuery(_ packet: Data) -> String? {
        // Aquí iría el parseo DNS básico
        return nil
    }

    private static func isTLSClientHello(_ packet: Data) -> Bool {
        return packet.first == 0x16
    }

    private static func parseSNI(_ packet: Data) -> String? {
        // Parseo SNI mínimo
        return nil
    }
}
