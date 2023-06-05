import SwiftUI
import UserNotifications

struct AddReminderView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var reminderManager: ReminderManager
    @State private var title = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Reminder Details")) {
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                Section {
                    Button(action: addReminder) {
                        Text("Save")
                    }
                }
            }
            .navigationTitle("Add Reminder")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                    }
                }
            }
        }
    }
    
    func addReminder() {
        reminderManager.addReminder(title: title, date: date)
        presentationMode.wrappedValue.dismiss()
    }
}
