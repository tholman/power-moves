//
//  powermovesApp.swift
//  powermoves
//
//  Created by Tim Holman on 9/20/23.
//

import SwiftUI

@main
struct PowerMovesApp: App {
    
    @State var isInserted = true
    @State var colorIndex = 0
    
    var body: some Scene {
        
        let colors: [NSColor] = [.red, .blue, .orange]
        MenuBarExtra(isInserted: $isInserted) {
            Button("Shift") {
                colorIndex = (colorIndex+1) % colors.count
            }
        } label: {
            let configuration = NSImage.SymbolConfiguration(pointSize: 17, weight: .light)
                        .applying(.init(paletteColors: [colors[colorIndex]]))
            let image = NSImage(systemSymbolName: "battery.0", accessibilityDescription: nil)
            let updateImage = image?.withSymbolConfiguration(configuration)
            Image(nsImage: updateImage!)
        }
    }
}

struct AppMenu: View {
    var body: some View {
        Text("App Menu Item")
    }
}
