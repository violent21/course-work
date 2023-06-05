//
//  PlistTests.swift
//  SmartCarMateTests
//
//  Created by Valentin on 06.06.2023.
//

import XCTest
import CoreData
@testable import SmartCarMate

class PlistTests: XCTestCase {
    
    var dataController: DataController!
    var mockContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        dataController = DataController()
        
        mockContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mockContext.persistentStoreCoordinator = dataController.container.persistentStoreCoordinator
    }
    
    override func tearDown() {
        super.tearDown()
        
        dataController = nil
        mockContext = nil
    }
    
    func testSave() {
        let expectation = self.expectation(description: "Save Expectation")
        
        dataController.save(context: mockContext)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error, "Save expectation should be fulfilled without error.")
        }
    }
    
//    func testAddExpense() {
//        let expectation = self.expectation(description: "Add Expense Expectation")
//
//        let action = "Car wash"
//        let amount: Double = 150.0
//
//        dataController.addExpense(action: action, amount: amount, context: mockContext)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            let fetchRequest: NSFetchRequest<Expenses> = Expenses.fetchRequest()
//
//            do {
//                let fetchedExpenses = try self.mockContext.fetch(fetchRequest)
//
//                XCTAssertEqual(fetchedExpenses.count, 8)
//                XCTAssertEqual(fetchedExpenses[0].action, action)
//                XCTAssertEqual(fetchedExpenses[0].amount, amount)
//
//                expectation.fulfill()
//            } catch {
//                XCTFail("Failed to fetch expenses: \(error.localizedDescription)")
//            }
//        }
//
//        waitForExpectations(timeout: 1) { error in
//            XCTAssertNil(error, "Add Expense expectation should be fulfilled without error.")
//        }
//    }
    
    func testEditExpense() {
        let expectation = self.expectation(description: "Edit Expense Expectation")
        
        let action = "Buy groceries"
        let amount: Double = 50.0
        
        let expenses = Expenses(context: mockContext)
        expenses.action = "Old action"
        expenses.amount = 100.0
        
        dataController.editExpense(expenses: expenses, action: action, amount: amount, context: mockContext)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(expenses.action, action)
            XCTAssertEqual(expenses.amount, amount)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error, "Edit Expense expectation should be fulfilled without error.")
        }
    }
    
    func testInit() {
        XCTAssertNotNil(dataController)
        XCTAssertNotNil(dataController.container)
    }
    
    func testDeleteExpense() {
            // Підготовка тестових даних
            let dataController = DataController()
            let context = dataController.container.viewContext
            
            let expense1 = Expenses(context: context)
            expense1.id = UUID()
            expense1.date = Date()
            expense1.action = "Expense 1"
            expense1.amount = 10.0
            
            let expense2 = Expenses(context: context)
            expense2.id = UUID()
            expense2.date = Date()
            expense2.action = "Expense 2"
            expense2.amount = 20.0
            
            dataController.save(context: context)
            
            //dataController.addExpense(action: "String", amount: "Do")

            XCTAssertFalse(context.deletedObjects.contains(expense1), "Витрата 1 не була успішно видалена")
            XCTAssertTrue(context.deletedObjects.contains(expense2), "Витрата 2 була помилково видалена")
            //XCTAssertEqual(dataController.totalExpensesCount(context: context), 1, "Неправильна кількість витрат після видалення")
        }
        
        func testAddExpenseWithInvalidData() {
            let dataController = DataController()
            let context = dataController.container.viewContext
            
            let invalidAmount = Double.nan

            dataController.addExpense(action: "Invalid Expense", amount: invalidAmount, context: context)

            //XCTAssertEqual(dataController.totalExpensesCount(context: context), 0, "Витрата з недійсною сумою була помилково збережена")
        }
}
