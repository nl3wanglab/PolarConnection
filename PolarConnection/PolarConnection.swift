/// Copyright © 2021 Polar Electro Oy. All rights reserved.

import SwiftUI

class PolarDeviceManager : ObservableObject {
    @Published var bleSdkManager1: PolarBleSdkManager
    @Published var bleSdkManager2: PolarBleSdkManager

    init() {
        self.bleSdkManager1 = PolarBleSdkManager()
        self.bleSdkManager2 = PolarBleSdkManager()
    }

    func areDeviceIdsSame() -> Bool {
        return bleSdkManager1.deviceId == bleSdkManager2.deviceId
    }
    
    func isConnectedOrConnecting() -> Bool {
        let state1 = bleSdkManager1.deviceConnectionState
        let state2 = bleSdkManager2.deviceConnectionState
        
        if case .connecting = state1 {
            return true
        } else if case .connected = state1 {
            return true
        } else if case .connecting = state2 {
            return true
        } else if case .connected = state2 {
            return true
        }
        
        return false
    }
}

@main
struct PolarConnection: App {
    @ObservedObject var deviceManager = PolarDeviceManager()
    
    var body: some Scene {
        WindowGroup {
            ScrollView {
                ContentView(deviceId: 1, bleSdkManager: deviceManager.bleSdkManager1)
                    .environmentObject(deviceManager)
                ContentView(deviceId: 2, bleSdkManager: deviceManager.bleSdkManager2)
                    .environmentObject(deviceManager)
            }
        }
    }
}
