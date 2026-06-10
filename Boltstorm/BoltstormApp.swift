//
//  BoltstormApp.swift
//  Boltstorm
//
//  Created by Louis Basile on 5/27/26.
//

import SwiftUI

@main
struct BoltstormApp: App {
    init() {
        ManaSymbology.registerFont()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
