//
//  Extensions.swift
//  ExploreEventKit
//
//  Created by Ivan Nur Ilham Syah on 04/05/24.
//

import Foundation

extension Date {
    func stripTime() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        let date = calendar.date(from: components)
        return date!
    }
    
    func stripDate() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: self)
        let date = calendar.date(from: components)
        return date!
    }
    
    func addMinute(to: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(
            byAdding: .minute,
            value: to,
            to: self
        )!
    }
    
    func subtract(by component: Calendar.Component, value: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: component, value: -value, to: self)!
    }
    
    func maxDate() -> Date {
        Calendar.current.date(byAdding: .day, value: 7, to: self)!
    }
    
    func minTime() -> Date {
        let calendar = Calendar.current
        
        return calendar.date(
            bySettingHour: 00,
            minute: 00,
            second: 00,
            of: self
        )!
    }
    
    func maxTime() -> Date {
        let calendar = Calendar.current
        
        return calendar.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: self
        )!
    }
}

extension Collection where Indices.Iterator.Element == Index {
    public subscript(safe index: Index) -> Iterator.Element? {
        return (startIndex <= index && index < endIndex) ? self[index] : nil
    }
}
