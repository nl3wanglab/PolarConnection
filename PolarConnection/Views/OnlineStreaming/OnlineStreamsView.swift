/// Copyright © 2022 Polar Electro Oy. All rights reserved.

import Foundation
import SwiftUI
import PolarBleSdk

struct OnlineStreamsView: View {
    @EnvironmentObject private var bleSdkManager: PolarBleSdkManager
    @State private var urlToShare: IdentifiableURL?
    
    func isHRData(contents: String) -> Bool {
        let lines = contents.split(separator: "\n")
        guard let header = lines.first else {
            return false
        }
        return header == "HR CONTACT_SUPPORTED CONTACT_STATUS RR_AVAILABLE RR(ms)"
    }
    
    func shareURL(url: URL) {
        // Assuming you have a function to get the device ID
        let deviceId = bleSdkManager.get_connected_device_Id()

        // Get the original file name from the URL
        let originalFileName = url.lastPathComponent

        // Extract the file extension
//        let fileExtension = url.pathExtension

        // Create the new file name with device ID and original file name
        let newFileName = "\(deviceId)_\(originalFileName)"

        // Create the destination URL with the new file name
        let destinationURL = url.deletingLastPathComponent().appendingPathComponent(newFileName)

        do {
            // Read the contents of the original file
            let fileContents = try Data(contentsOf: url)
            
            if let fileContentsString = String(data: fileContents, encoding: .utf8) {
                NSLog("File contents: \(fileContentsString)")

                if isHRData(contents: fileContentsString) {
                    NSLog("The file contains HR data.")
                    // Proceed with parsing and other operations for HR data
                }
            } else {
                NSLog("Unable to convert file contents to string")
            }

            // Write the contents to the new file
            try fileContents.write(to: destinationURL)
            
            // Update the urlToShare property with the modified URL
            urlToShare = IdentifiableURL(url: destinationURL)
        } catch {
            urlToShare = IdentifiableURL(url: url)
        }
    }

//    func shareURL(url: URL) {
//            urlToShare = IdentifiableURL(url: url)
//        }

    
    var body: some View {
        if case .connected = bleSdkManager.deviceConnectionState,
           bleSdkManager.onlineStreamingFeature.isSupported {
            VStack {
                ForEach(PolarDeviceDataType.allCases) { dataType in
                    HStack {
                        OnlineStreamingButton(dataType: dataType)
                        Spacer()
                        if case let .success(urlOptional) = bleSdkManager.onlineStreamingFeature.isStreaming[dataType],
                           let url = urlOptional {
                            
                            ShareButton() { shareURL(url: url) }
                                .padding(.trailing)
                        }
                    }
                }
            }
            .fullScreenCover(item: $bleSdkManager.onlineStreamSettings) { streamSettings in
                let settings = streamSettings
                SettingsView(streamedFeature: settings.feature, streamSettings: settings)
            }
            .sheet(
                item: Binding(
                    get: { urlToShare },
                    set: { newValue in
                        if let url = urlToShare?.url {
                            bleSdkManager.onlineStreamLogFileShared(at: url)
                        }
                        urlToShare = newValue
                    }
                ),
                
                /*item: $urlToShare,
                 onDismiss: {
                 if let url = self.urlToShare?.url {
                 bleSdkManager.onlineStreamLogFileShared(at: url)
                 }
                 urlToShare = nil
                 },*/
                content: { identifiableURL in ActivityViewController(activityItems: [identifiableURL.url], applicationActivities: nil)}
            )
        }
    }
}

struct OnlineStreamingButton: View {
    let dataType: PolarDeviceDataType
    @EnvironmentObject private var bleSdkManager: PolarBleSdkManager
    
    var body: some View {
        Button(getStreamButtonText(dataType, bleSdkManager.onlineStreamingFeature.isStreaming[dataType]),
               action: { streamButtonToggle(dataType) })
        .buttonStyle(SecondaryButtonStyle(buttonState: getStreamButtonState(dataType)))
    }
    
    private func getStreamButtonText(_ feature:PolarDeviceDataType, _ isStreaming: OnlineStreamingState?) -> String {
        let text = getShortNameForDataType(feature)
        let buttonText:String
        switch(isStreaming!) {
        case .inProgress:
            buttonText = "Stop \(text) Stream"
        case .success(url: _):
            buttonText = "Start \(text) Stream"
        case .failed(error: _):
            buttonText = "Start \(text) Stream"
        }
        return buttonText
    }
    
    private func streamButtonToggle(_ feature:PolarDeviceDataType) {
        NSLog("Stream toggle for feature \(feature)")
        if(bleSdkManager.isStreamOn(feature: feature)) {
            bleSdkManager.onlineStreamStop(feature: feature)
        } else {
            if(feature == PolarDeviceDataType.ppi || feature == PolarDeviceDataType.hr) {
                bleSdkManager.onlineStreamStart(feature: feature)
            } else {
                bleSdkManager.getOnlineStreamSettings(feature: feature)
            }
        }
    }
    
    private func getStreamButtonState(_ feature: PolarDeviceDataType) -> ButtonState {
        if(bleSdkManager.onlineStreamingFeature.availableOnlineDataTypes[feature] ?? false) {
            if bleSdkManager.isStreamOn(feature: feature) {
                return ButtonState.pressedDown
            } else {
                return ButtonState.released
            }
        } else {
            return ButtonState.disabled
        }
    }
}

fileprivate struct ShareButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 28))
        }
    }
}

fileprivate struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

fileprivate struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

extension PolarDeviceDataType: Identifiable {
    public var id: Int {
        switch self {
        case .ecg:
            return 1
        case .acc:
            return 2
        case .ppg:
            return 3
        case .ppi:
            return 4
        case .gyro:
            return 5
        case .magnetometer:
            return 6
        case .hr:
            return 7
        }
    }
}

struct OnlineStreamsView_Previews: PreviewProvider {
    private static let onlineStreamingFeature = OnlineStreamingFeature(
        isSupported: true,
        availableOnlineDataTypes: [PolarDeviceDataType.hr: true, PolarDeviceDataType.acc: false, PolarDeviceDataType.ppi: true, PolarDeviceDataType.gyro: false, PolarDeviceDataType.magnetometer: true, PolarDeviceDataType.ecg: false],
        isStreaming: [PolarDeviceDataType.hr: .inProgress, PolarDeviceDataType.acc:  .inProgress, PolarDeviceDataType.ppi:  .inProgress, PolarDeviceDataType.gyro:  .inProgress, PolarDeviceDataType.magnetometer:  .inProgress, PolarDeviceDataType.ecg:  .inProgress]
    )
    
    private static let polarBleSdkManager: PolarBleSdkManager = {
        let polarBleSdkManager = PolarBleSdkManager()
        polarBleSdkManager.onlineStreamingFeature = onlineStreamingFeature
        return polarBleSdkManager
    }()
    
    static var previews: some View {
        return OnlineStreamsView()
            .environmentObject(polarBleSdkManager)
    }
}
