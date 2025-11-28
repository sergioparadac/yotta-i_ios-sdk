//
//  SNIViewModel.swift
//  Yotta
//
//  Created by Pedro Lacoste on 27-11-25.
//

import SwiftUI
import Combine

class SNIViewModel: ObservableObject {
    @Published var dominios: [String] = []
    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default.publisher(for: .sniDetected)
            .compactMap { $0.object as? String }
            .receive(on: RunLoop.main)
            .sink { [weak self] dominio in
                guard let self = self else { return }
                if !self.dominios.contains(dominio) {
                    self.dominios.append(dominio)
                }
            }
    }
}
