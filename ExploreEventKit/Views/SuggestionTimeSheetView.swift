//
//  SuggestionTimeSheetView.swift
//  ExploreEventKit
//
//  Created by Ivan Nur Ilham Syah on 10/05/24.
//

import SwiftUI

struct SuggestionTimeSheetView: View {
    @EnvironmentObject private var vm: EventViewModel
    @Binding var isOpened: Bool
    
    
    var body: some View {
        NavigationStack {
            VStack {
                if vm.isLoading {
                    ProgressView()
                } else {
                    if (vm.timeSuggestions.isEmpty) {
                        ContentUnavailableView(
                            "No Time Suggestions",
                            systemImage: "calendar",
                            description: Text("There is no time suggestions based on your preferences!")
                            
                        )
                        .frame(maxHeight: 250)
                        
                    } else {
                        
                        List {
                            ForEach(vm.timeSuggestions) { event in
                                
                                Section(
                                    header: Text(event.date, style: .date)
                                ) {
                                    if event.items.isEmpty {
                                        Text("No Time Suggestions")
                                    } else {
                                        ForEach(event.items, id: \.self) { item in
                                            SelectableList(
                                                data: item,
                                                isSingleOption: vm.isEditMode,
                                                groupValues: $vm.selectedTimeSuggestions
                                            )
                                        }
                                    }
                                }
                                
                            }
                        }
                        .onChange(of: vm.selectedTimeSuggestions) { old, new in
                            print(new)
                        }
                    }
                }
            }
            .navigationTitle("Time Suggestions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            try vm.createLearningPlan()
                        }
                        
                        if !vm.isLoading {
                            isOpened.toggle()
                        }
                    }
                    .disabled(vm.isLoading || vm.selectedTimeSuggestions.isEmpty)
                }
            }
            .refreshable {
                vm.getFinalTimeSuggestion()
            }
            
        }
        .interactiveDismissDisabled()
        .task {
            vm.getFinalTimeSuggestion()
        }
    }
}

struct SelectableList: View {
    
    var data: BufferTime
    var isSingleOption: Bool = false
    @Binding var groupValues: [BufferTime]
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(data.startTime.formatted(.dateTime.hour().minute()))")
            Text("-")
                .foregroundStyle(Color.gray)
            Text("\(data.endTime.formatted(.dateTime.hour().minute()) )")
            
            Spacer()
            
            if (groupValues.contains(data)) {
                Image(systemName: "checkmark")
                    .foregroundStyle(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !groupValues.contains(data) {
                if isSingleOption {
                    groupValues = [data]
                } else {
                    groupValues.append(data)
                }
            } else {
                groupValues = groupValues.filter { $0 != data }
            }
        }
    }
}

#Preview {
    SuggestionTimeSheetView(isOpened: .constant(false))
        .environmentObject(EventViewModel())
}
