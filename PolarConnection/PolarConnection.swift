/// Copyright © 2021 Polar Electro Oy. All rights reserved.

import SwiftUI

@main
struct PolarConnection: App {
    @StateObject var bleSdkManager = PolarBleSdkManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(deviceId: 1)
                .environmentObject(bleSdkManager)
        }
    }
}
