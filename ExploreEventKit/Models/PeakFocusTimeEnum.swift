//
//  PeakFocusTimeEnum.swift
//  ExploreEventKit
//
//  Created by Ivan Nur Ilham Syah on 10/05/24.
//

import Foundation

enum PeakFocusTime: String {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case custom = "Custom"
}

extension PeakFocusTime {
    var isMorning: Bool { self == .morning }
    var isAfternoon: Bool { self == .afternoon }
    var isEvening: Bool { self == .evening }
    var isCustom: Bool { self == .custom }
    
    var startTime: Date? {
        let date: Date = Date()
        let calendar = Calendar.current
        
        switch self {
        case .morning:
            return calendar.date(
                bySettingHour: 4,
                minute: 0,
                second: 0,
                of: date
            )
        case .afternoon:
            return calendar.date(
                bySettingHour: 13,
                minute: 0,
                second: 0,
                of: date
            )
        case .evening:
            return calendar.date(
                bySettingHour: 18,
                minute: 0,
                second: 0,
                of: date
            )
        case .custom:
            return nil
        }
    }
    
    var endTime: Date? {
        let date: Date = Date()
        let calendar = Calendar.current
        
        switch self {
        case .morning:
            return calendar.date(
                bySettingHour: 11,
                minute: 59,
                second: 59,
                of: date
            )
        case .afternoon:
            return calendar.date(
                bySettingHour: 17,
                minute: 59,
                second: 59,
                of: date
            )
        case .evening:
            return calendar.date(
                bySettingHour: 22,
                minute: 59,
                second: 59,
                of: date
            )
        case .custom:
            return nil
        }
    }
}
