//
//  SNIReporter.swift
//  Yotta
//
//  Created by Pedro Lacoste on 12-11-25.
//

import Foundation

func sendSNIToAPI(_ sni: String) {
    guard let url = URL(string: "https://tu-api.com/sni") else { return }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let payload = ["sni": sni]
    guard let data = try? JSONSerialization.data(withJSONObject: payload, options: []) else { return }

    let task = URLSession.shared.uploadTask(with: request, from: data) { _, _, error in
        if let error = error {
            print("Error al enviar SNI: \(error)")
        } else {
            print("SNI enviado correctamente: \(sni)")
        }
    }

    task.resume()
}
