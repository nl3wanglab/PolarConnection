//  Copyright © 2023 Polar. All rights reserved.
import Foundation

class OfflineRecordingUtils {
        
    static func mapOfflineRecordingFileNameToMeasurementType(fileName: String) throws -> PmdMeasurementType {
        let baseFileName = fileName.components(separatedBy: CharacterSet.decimalDigits).first ?? fileName
        switch(baseFileName) {
        case "ACC", "ACC.REC": return .acc
        case "GYRO", "GYRO.REC": return .gyro
        case "MAG", "MAG.REC": return .mgn
        case "PPG", "PPG.REC": return .ppg
        case "PPI", "PPI.REC": return .ppi
        case "HR", "HR.REC": return .offline_hr
        default: throw BleGattException.gattDataError(description: "Unknown offline file \(fileName)")
        }
    }
}
