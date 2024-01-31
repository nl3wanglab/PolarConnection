/// Copyright © 2021 Polar Electro Oy. All rights reserved.

import SwiftUI

@main
struct PolarConnection: App {
    @StateObject var bleSdkManager = PolarBleSdkManager()
    @StateObject var bleSdkManager2 = PolarBleSdkManager()
    
    var body: some Scene {
        WindowGroup {
            ScrollView {
                ContentView(deviceId: 1)
                    .environmentObject(bleSdkManager)
                ContentView(deviceId: 2)
                    .environmentObject(bleSdkManager2)
            }
        }
    }
}
