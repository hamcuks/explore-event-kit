//
//  EventViewModel.swift
//  ExploreEventKit
//
//  Created by Ivan Nur Ilham Syah on 04/05/24.
//

import Foundation
import EventKit
import SwiftUI

class EventViewModel: ObservableObject {
    @Published var events: [GroupOf<EKEvent>] = []
    @Published var event: EKEvent? = nil
    @Published var timeSuggestions: [GroupOf<BufferTime>] = []
    @Published var isLoading: Bool = false
    @Published var isEditMode: Bool = false
    @Published var selectedTimeSuggestions: [BufferTime] = []
    
    private let store = EKEventStore()
    
    /// Plan Detail
    @Published var title: String = ""
    
    /// Plan Duration
    @Published var startDate: Date = .now
    @Published var endDate: Date = .now
    
    /// User Focus Time
    let focusTimes: [PeakFocusTime] = [.morning, .afternoon, .evening, .custom]
    @Published var focusTime: PeakFocusTime = .morning
    @Published var startTime: Date = PeakFocusTime.morning.startTime!
    @Published var endTime: Date = PeakFocusTime.morning.endTime!
    
    /// Duration of Learning Session
    let learningDurations: [Int] = [15, 30, 45, 60]
    @Published var duration: Int = 15
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(onCalendarChanged), name: .EKEventStoreChanged, object: store)
    }
    
    @objc func onCalendarChanged() {
        self.fetchLearningPlan()
    }
    
    /// This functions will reset the form data to its
    /// default value
    func resetFormData() {
        self.title = ""
        self.startDate = .now
        self.endDate = .now
        self.focusTime = .morning
        self.startTime = PeakFocusTime.morning.startTime!
        self.endTime = PeakFocusTime.morning.endTime!
        self.duration = 15
        self.event = nil
        self.isEditMode = false
    }
    
    func setCurrentEvent(event: EKEvent) {
        self.event = event
        self.title = event.title
        self.focusTime = .custom
        self.startDate = event.startDate
        self.startTime = event.startDate
        self.endDate = event.endDate
        self.endTime = event.endDate
        self.duration = Calendar.current.dateComponents([.minute], from: event.startDate, to: event.endDate).minute!
    }
    
    private func requesFullAccessToEvents() {
        store.requestFullAccessToEvents { granted, error in
            if let error = error {
                print("Access:", error.localizedDescription)
            }
        }
    }
    
    /// Get the learning plan by filtering the events calendar title
    /// with "Taman Mini"
    func fetchLearningPlan() {
        
        self.requesFullAccessToEvents()
        
        /// Create NSPredicate with date range today until today + 7
        var predicate: NSPredicate? = nil
        
        predicate = store.predicateForEvents(
            withStart: .now,
            end: Calendar.current.date(byAdding: .day, value: 7, to: .now)!,
            calendars: nil
        )
        
        /// Store the events data into events variable then filter it by calendar
        /// title
        var events: [EKEvent] = []
        if let aPredicate = predicate {
            events = store.events(matching: aPredicate).filter { event in
                return event.calendar.title == "Taman Mini"
            }
        }
        
        /// Get the Set of dates then sorted it. Used to groupping the
        /// events data
        ///
        /// Example:
        /// (2024/05/01, 2024/05/02, 2024/05/03)
        let dates = Set(events.map {
            $0.startDate.stripTime()
        }).sorted()
        
        /// Map the dates data into GroupOf<EKEvent>
        ///
        /// The items filtered by the date. Example:
        /// [
        ///     GroupOf<EKEvent>(date: 2024/05/01, items: [events with corresponding date])
        ///     GroupOf<EKEvent>(date: 2024/05/02, items: [events with corresponding date])
        ///     GroupOf<EKEvent>(date: 2024/05/03, items: [events with corresponding date])
        /// ]
        self.events = dates.map { date in
            return GroupOf<EKEvent>(
                date: date,
                items: events.filter { event in
                    
                    /// Only return the events if the event start date equals with group date
                    let eventDate = event.startDate.stripTime()
                    return eventDate == date
                }
                    .sorted(by: {
                        
                        /// Sort the events as ascending by comparing
                        /// the current next start date with next event start date
                        $0.compareStartDate(with: $1) == .orderedAscending
                    })
            )
        }
    }
    
    /// This function will get all the user events based on date range.
    /// It will returns array with GroupOf<EKEvent>
    private func fetchEvents() -> [GroupOf<EKEvent>] {
        self.requesFullAccessToEvents()
        
        
        store.requestFullAccessToEvents {granted, error in
            if (error != nil) {
                print(error!)
            }
        }
        
        /// Create NSPredicate with start date and end date of user's inputted date
        var predicate: NSPredicate? = nil
        predicate = store.predicateForEvents(
            withStart: self.startDate.minTime(),
            end: self.endDate.maxTime(),
            calendars: nil
        )
        
        /// Store events into events variable. Then filtered based on user's prefered focus time
        var events: [EKEvent] = []
        if let aPredicate = predicate {
            events = store.events(matching: aPredicate)
            
            events = events.filter { event in
                
                /// Make sure return events within range of focus time
                return event.startDate.stripDate() >= self.startTime.stripDate() && event.endDate.stripDate() <= self.endTime.stripDate()
            }
        }
        
        /// Get the Set of dates then sorted it. Used to groupping the
        /// events data
        ///
        /// Example:
        /// (2024/05/01, 2024/05/02, 2024/05/03)
        let dates = Set(events.map {
            $0.startDate.stripTime()
        }).sorted()
        
        /// Map the dates data into GroupOf<EKEvent>
        ///
        /// The items filtered by the date. Example:
        /// [
        ///     GroupOf<EKEvent>(date: 2024/05/01, items: [events with corresponding date])
        ///     GroupOf<EKEvent>(date: 2024/05/02, items: [events with corresponding date])
        ///     GroupOf<EKEvent>(date: 2024/05/03, items: [events with corresponding date])
        /// ]
        return dates.map { date in
            return GroupOf<EKEvent>(
                date: date,
                items: events.filter { event in
                    /// Only return the events if the event start date equals with group date
                    let eventDate = event.startDate.stripTime()
                    return eventDate == date
                }
                    .sorted(by: {
                        
                        /// Sort the events as ascending by comparing
                        /// the current next start date with next event start date
                        $0.compareStartDate(with: $1) == .orderedAscending
                    })
                
            )
        }
        
        
    }
    
    /// This function will get the buffer time in user's events
    ///
    /// - Parameter: from GroupOfEvents
    ///
    /// Will return array with GroupOf<BufferTime>
    private func getBufferTime(from groupOfEvents: [GroupOf<EKEvent>]) -> [GroupOf<BufferTime>] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "GMT")!
        
        /// Map the groupOfEvents data into  array with GroupOf<BufferTime>
        return groupOfEvents.map { event in
            
            /// Get the buffers by comparing the current event and next event
            ///
            /// BufferTime:
            /// - the startTime should be greater 1 minute of current event end date
            /// - the endTime should be less 1 minute of next event start date
            /// - the duration should be endTime - startTime
            ///
            /// Example: Given 2 events, Event(start: 08.30, end: 09.00) and Event(start: 09.30, end: 10.00)
            /// the BufferTime should  be BufferTime(start: 09.01, end: 09.29, duration: 28)
            let buffers = event.items.enumerated().compactMap { (index, current) in
                
                /// Make sure the index+1 is not out of range
                if let next = event.items[safe: index+1] {
                    let startTime = current.endDate.addMinute(to: 1)
                    
                    let endTime = next.startDate.addMinute(to: -1)
                    
                    let diff = calendar.dateComponents([.minute], from: startTime, to: endTime).minute ?? 0
                    
                    return BufferTime(
                        startTime: startTime,
                        endTime: endTime,
                        duration: diff
                    )
                }
                
                /// If index+1 is out of range, then return nil
                return nil
            }
            
            return GroupOf<BufferTime>(
                date: event.date,
                items: buffers
            )
        }
    }
    
    /// This function will get the time suggestions on each groupped events
    ///
    /// - Parameter: from buffer: [BufferTime] and duration
    ///
    /// It will returns array of BufferTime
    private func getEachDayTimeSuggestions(from buffers: [BufferTime], duration: Int) -> [BufferTime] {
        
        /// Flat Map the buffers into array of BufferTime (time suggestions). Flat map will
        /// flat multidimensional into single array
        ///
        /// Result Example:
        /// From
        /// [
        ///     [suggestion1, suggestion2, suggestion3], -> Suggestion of BuffertTime 1
        ///     [suggestion4], -> Suggestion of BuffertTime 2
        ///     [suggestion5, suggestion6] -> Suggestion of BuffertTime 1
        /// ]
        ///
        /// To:
        /// [ suggestion1, suggestion2, suggestion3, suggestion4, suggestion5, suggestion6 ]
        return buffers.flatMap { buffer in
            var temp: [BufferTime] = []
            
            /// Make sure to get the suggestion time if the buffer.duration
            /// is greater or equal with choosed duration
            if buffer.duration >= duration {
                
                var current = buffer
                var currentEndTime = current.endTime
                
                repeat {
                    
                    
                    // Get interval time by add an X duration into current startTime
                    // Example: current start time is 07.01
                    // then intervaled time wil be = 07.01 + X
                    let intervaledTime = current.startTime.addMinute(
                        to: duration
                    )
                    
                    
                    // then change current end time to intervaled time
                    current.endTime = intervaledTime
                    
                    /// Only append if current.startTime and current.endTime buffer do not
                    /// pass local current time
                    if (.now <= current.startTime && .now <= current.endTime) {
                        // now append the current time.
                        // Current:
                        // start: 07.01
                        // end: 07.01 + x
                        temp.append(current)
                    }
                    
                    
                    // change current start time by add 1 minute
                    current.startTime = intervaledTime.addMinute(to: 1)
                    
                    // change current end time by add X minutes duration into intervaled time
                    currentEndTime = intervaledTime.addMinute(to: duration)
                    current.endTime = currentEndTime
                    
                } while currentEndTime < buffer.endTime
            }
            
            return temp
        }
    }
    
    /// This function will get the final suggestion. Store the GroupOf<BufferTime>
    /// into timeSuggestions variable
    func getFinalTimeSuggestion() {
        let events = self.fetchEvents()
        let buffers = self.getBufferTime(from: events)
        self.timeSuggestions = buffers.map { buffer in
            GroupOf<BufferTime>(
                date: buffer.date,
                items: self.getEachDayTimeSuggestions(
                    from: buffer.items, duration: self.duration
                )
            )
        }
    }
    
    /// This function used to create an event calendar with
    /// the selected time suggestions
    func createLearningPlan() throws {
        isLoading = true
        
        self.requesFullAccessToEvents()
        
        do {
            
            if self.isEditMode, let currentEvent = self.event, let suggestion = self.selectedTimeSuggestions.first {
                var event = store.event(withIdentifier: currentEvent.eventIdentifier)
                event?.title = self.title
                event?.calendar = store.defaultCalendarForNewEvents
                event?.startDate = suggestion.startTime
                event?.endDate = suggestion.endTime
                    
                try  store.save(event!, span: .thisEvent, commit: true)
            }
            else {
                
                /// Store the event by looping the time suggestions
                try selectedTimeSuggestions.forEach { suggestion in
                    let event = EKEvent(eventStore: store)
                    event.title = self.title
                    event.calendar = store.defaultCalendarForNewEvents
                    event.startDate = suggestion.startTime
                    event.endDate = suggestion.endTime
                    
                    event.calendar.title = "Taman Mini"
                    event.calendar.cgColor = CGColor(red: 10, green: 132, blue: 255, alpha: 1)
                    
                    
                    try  store.save(event, span: .thisEvent)
                    print(suggestion)
                }
                try store.commit()
            }
            
            isLoading = false
            
        } catch  {
            isLoading = false
            print(error)
        }
        
    }
    
    func removeEvent(event: EKEvent) throws {
        self.requesFullAccessToEvents()
        
        guard (try? store.remove(event, span: .thisEvent, commit: true)) != nil else {
            print("Error")
            
            throw EventError.failedToDeleteEvent
        }
        
    }
}

enum EventError: Error {
    case failedToCreateEvent
    case failedToDeleteEvent
}
