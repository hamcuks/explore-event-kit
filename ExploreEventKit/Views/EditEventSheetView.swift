//
//  EditEventSheetView.swift
//  ExploreEventKit
//
//  Created by Ivan Nur Ilham Syah on 12/05/24.
//

import SwiftUI

struct EditEventSheetView: View {
    
    @Binding var isOpened: Bool
    
    // Form OnChange
    @State private var isFieldChanged: Bool = false
    @State private var showDiscardSheet: Bool = false
    
    @EnvironmentObject private var vm: EventViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Plan Detail") {
                    TextField("Title", text: $vm.title)
                        .onChange(of: vm.title) { oldValue, newValue in
                            isFieldChanged = true
                        }
                }
                
                Section("Focus Time") {
                    
                    HStack{
                        Image(systemName: "moon.fill")
                            .frame(width: 30, height: 30, alignment: .center)
                            .background(.yellow)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                        
                        Picker("Focus Time", selection: $vm.focusTime) {
                            ForEach(vm.focusTimes, id: \.hashValue) { focus in
                                Text(focus.rawValue).tag(focus)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: vm.focusTime) { oldValue, newValue in
                            if !newValue.isCustom {
                                vm.startTime = newValue.startTime!
                                vm.endTime = newValue.endTime!
                            }
                            
                            isFieldChanged = true
                        }
                    }
                    
                    HStack(spacing: 12){
                        Image(systemName: "clock.fill")
                            .frame(width: 30, height: 30, alignment: .center)
                            .background(.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                        
                        DatePicker(
                            "Start Time",
                            selection: $vm.startTime,
                            displayedComponents: [.hourAndMinute]
                        )
                        .disabled(!vm.focusTime.isCustom)
                        .onChange(of: vm.startTime) { oldValue, newValue in
                            isFieldChanged = true
                        }
                    }
                    
                    HStack(spacing: 12){
                        Image(systemName: "clock.fill")
                            .frame(width: 30, height: 30, alignment: .center)
                            .background(.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                        
                        DatePicker(
                            "End Time",
                            selection: $vm.endTime,
                            in: vm.startTime...vm.startTime.maxTime(),
                            displayedComponents: [.hourAndMinute]
                        )
                        .disabled(!vm.focusTime.isCustom)
                        .onChange(of: vm.endTime) { oldValue, newValue in
                            isFieldChanged = true
                        }
                    }
                    
                }
                
                Section("Duration of Learning Session") {
                    
                    HStack{
                        Image(systemName: "gauge.with.needle.fill")
                            .frame(width: 30, height: 30, alignment: .center)
                            .background(.green)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                        
                        Picker("Learning Duration", selection: $vm.duration) {
                            ForEach(vm.learningDurations, id: \.self) { value in
                                Text("\(value) Minutes").tag(value)
                            }
                        }
                        .onChange(of: vm.duration) { oldValue, newValue in
                            isFieldChanged = true
                        }
                        
                    }
                    
                }
                
                if let event = vm.event {
                    Section("Your Plan") {
                        HStack(
                            spacing: 8
                        ) {
                            Text("\(event.title)")
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Text("\(event.startDate.formatted(.dateTime.hour().minute()))")
                                    .foregroundStyle(Color.gray)
                                Text("-")
                                    .foregroundStyle(Color.gray)
                                Text("\(event.endDate.formatted(.dateTime.hour().minute()) )")
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Event Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SuggestionTimeSheetView(isOpened: $isOpened)) {
                        Text("Next")
                    }
                    .disabled(
                        vm.title.isEmpty
                    )
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        
                        if isFieldChanged {
                            showDiscardSheet.toggle()
                            return
                        }
                        
                        isOpened = false
                    }
                }
            }
        }
        .interactiveDismissDisabled(true)
        .confirmationDialog("Discard Changes", isPresented: $showDiscardSheet) {
            Button("Discard Changes", role: .destructive) {
                vm.resetFormData()
                isOpened.toggle()
            }
        }
        
    }
}

#Preview {
    EditEventSheetView(isOpened: .constant(false))
        .environmentObject(EventViewModel())
}
