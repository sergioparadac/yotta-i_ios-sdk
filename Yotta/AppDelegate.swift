//
//  AppDelegate.swift
//  Yotta
//
//  Created by Pedro Lacoste on 27-11-25.
//
import UIKit
import NetworkExtension

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Inicializaciones globales, si las necesitas
        print("App lanzada")

        // Ejemplo: iniciar VPN al lanzar la app (solo si ya está configurada)
        startPacketTunnelIfNeeded()

        return true
    }
    
    private func startPacketTunnelIfNeeded() {
        // Configuración básica de NEVPNManager para iniciar la VPN
        let manager = NEVPNManager.shared()
        manager.loadFromPreferences { error in
            if let error = error {
                print("Error cargando VPN: \(error)")
                return
            }
            
            do {
                try manager.connection.startVPNTunnel()
                print("VPN iniciada")
            } catch {
                print("No se pudo iniciar VPN: \(error)")
            }
        }
    }
    
    // Otros callbacks de la app pueden ir aquí si los necesitas
}

