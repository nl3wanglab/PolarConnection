//  Copyright © 2023 Polar. All rights reserved.
import Foundation

class OfflineRecordingUtils {
        
    static func mapOfflineRecordingFileNameToMeasurementType(fileName: String) throws -> PmdMeasurementType {
        let baseFileName = fileName.components(separatedBy: CharacterSet.decimalDigits).first ?? fileName
        switch(baseFileName) {
        case "ACC": return .acc
        case "GYRO": return .gyro
        case "MAG": return .mgn
        case "PPG": return .ppg
        case "PPI": return .ppi
        case "HR": return .offline_hr
        default: throw BleGattException.gattDataError(description: "Unknown offline file \(fileName)")
        }
    }
}
