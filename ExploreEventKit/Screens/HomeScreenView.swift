//
//  HomeScreenView.swift
//  ExploreEventKit
//
//  Created by Ivan Nur Ilham Syah on 12/05/24.
//

import SwiftUI

struct HomeScreenView: View {
    @EnvironmentObject private var vm: EventViewModel
    @State private var isAddEventModalShowed: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if (vm.events.isEmpty) {
                    ContentUnavailableView(
                        "No Events",
                        systemImage: "calendar",
                        description: Text("There is no events data!")
                        
                    )
                } else {
                    
                    List{
                        ForEach(vm.events, id: \.id) { event in
                            Section(
                                header: Text(
                                    event.date.formatted(
                                        .dateTime.weekday().day().month().year()
                                    )
                                )
                            ) {
                                ForEach(event.items, id: \.self) { item in
                                    VStack(
                                        alignment: .leading,
                                        spacing: 8
                                    ) {
                                        Text("\(item.title)")
                                            .bold()
                                        
                                        
                                        HStack(spacing: 8) {
                                            Text("\(item.startDate.formatted(.dateTime.hour().minute()))")
                                                .foregroundStyle(Color.gray)
                                            Text("-")
                                                .foregroundStyle(Color.gray)
                                            Text("\(item.endDate.formatted(.dateTime.hour().minute()) )")
                                                .foregroundStyle(Color.gray)
                                        }
                                    }
                                    .swipeActions {
                                        Button(
                                            "Delete",
                                            role: .destructive,
                                            action: {
                                                Task {
                                                    do {
                                                        try vm.removeEvent(event: item)
                                                    } catch {
                                                        print("Error occurred!")
                                                    }
                                                }
                                            }
                                        )
                                        Button(
                                            "Details",
                                            action: {
                                                vm.setCurrentEvent(event: item)
                                                vm.isEditMode = true
                                                isAddEventModalShowed.toggle()
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        
                    }
                    
                }
                
            }
            .task {
                vm.fetchLearningPlan()
            }
            .navigationTitle("Your Events")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Event") {
                        isAddEventModalShowed.toggle()
                    }
                }
            }
            
            .sheet(isPresented: $isAddEventModalShowed) {
                vm.resetFormData()
                //                vm.fetchLearningPlan()
            } content: {
                AddEventSheetView(isOpened: $isAddEventModalShowed)
            }
            .refreshable {
                vm.fetchLearningPlan()
            }
            
        }
        
    }
}

#Preview {
    HomeScreenView()
        .environmentObject(EventViewModel())
}
