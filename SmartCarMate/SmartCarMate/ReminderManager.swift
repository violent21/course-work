import Foundation
import SwiftUI
import UserNotifications
import CoreData

struct Reminder: Identifiable {
    let id = UUID()
    var title: String
    var date: Date
    var isCompleted: Bool = false
}

extension Reminder {
    var isDateExpired: Bool {
        return Date() > date
    }
}

class ReminderManager: ObservableObject {
    @Published var reminders = [Reminder]()
    private var timer: Timer?
    
    init() {
        startTimer()
    }
    
    deinit {
        stopTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateReminders()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateReminders() {
        objectWillChange.send()
    }
    
    func addReminder(title: String, date: Date) {
        let newReminder = Reminder(title: title, date: date)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Разрешение на отправку уведомлений получено")
            } else {
                print("Разрешение на отправку уведомлений отклонено")
            }
        }
        reminders.append(newReminder)
        scheduleNotification(for: newReminder)
    }
    
    func updateReminder(_ reminder: Reminder, title: String, date: Date) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].title = title
            reminders[index].date = date
            cancelNotification(for: reminder)
            scheduleNotification(for: reminders[index])
        }
    }
    
    func deleteReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders.remove(at: index)
            cancelNotification(for: reminder)
        }
    }
    
    func scheduleNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = "Reminder"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification(for reminder: Reminder) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
    }
}
