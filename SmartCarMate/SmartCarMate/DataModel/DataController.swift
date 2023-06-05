import Foundation
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "ExpenseModel")
    
    init() {
        container.loadPersistentStores { desc, error in
            if let error = error {
                print("Failed to load the data: \(error.localizedDescription)")
            }
        }
    }
    
    func save(context: NSManagedObjectContext){
        do {
            try context.save()
            print("Saved successfully")
        } catch {
            print("Failed to save expense: \(error.localizedDescription)")
        }
    }
    
    func addExpense(action: String, amount: Double, context: NSManagedObjectContext){
        let expenses = Expenses(context: context)
        expenses.id = UUID()
        expenses.date = Date()
        expenses.action = action
        expenses.amount = amount
        
        save(context: context)
    }
    
    func editExpense(expenses: Expenses, action: String, amount: Double, context: NSManagedObjectContext){
        expenses.date = Date()
        expenses.action = action
        expenses.amount = amount
        
        save(context: context)
    }
}
