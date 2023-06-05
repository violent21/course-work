import Foundation
import CoreData

class ReminderDataManager {
    private let persistenceController: PersistenceController
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }
}
