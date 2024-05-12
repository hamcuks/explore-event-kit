//
//  GrouppedOfObject.swift
//  ExploreEventKit
//
//  Created by Ivan Nur Ilham Syah on 11/05/24.
//

import Foundation

struct GroupOf<T: Hashable>: Identifiable, Hashable {
    var id: String = UUID().uuidString
    let date: Date
    let items: [T]
}

struct BufferTime: Identifiable, Hashable {
    var id: UUID = UUID()
    
    var startTime: Date
    var endTime: Date
    var duration: Int
}

