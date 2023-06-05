import SwiftUI
import UserNotifications

@main
struct SmartCarMateApp: App {
    let persistenceController = PersistenceController.shared
    
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
    
}
