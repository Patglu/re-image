//
//  ComparingAppApp.swift
//  ComparingApp
//
//  Created by Sibusiso Mbonani on 2023/08/29.
//

import SwiftUI

@main
struct ComparingAppApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                HomeView()
                    .environmentObject(ComparingClothesViewModel())
            }
        }
    }
}
