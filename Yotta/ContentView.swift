//
//  ContentView.swift
//  Yotta
//
//  Created by Pedro Lacoste on 27-11-25.
//


import SwiftUI

struct ContentView: View {
    @StateObject var vm = SNIViewModel()

    var body: some View {
        NavigationView {
            List(vm.dominios, id: \.self) { dominio in
                Text(dominio)
            }
            .navigationTitle("SNI detectados")
        }
    }
}


#Preview {
    ContentView()
}
