import SwiftUI

struct EditExpenseView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.dismiss) var dismiss
    
    var expense: FetchedResults<Expenses>.Element
    
    @State private var action = ""
    @State private var amount: Double = 0
    
    var body: some View {
        let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
        
        VStack(spacing: 16) {
            TextField("Action", text: $action)
                .onAppear {
                    action = expense.action!
                    amount = expense.amount
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
            
            TextField("Amount", value: $amount, formatter: formatter)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
            
            Button(action: saveExpense) {
                Text("Save")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
    
    private func saveExpense() {
        DataController().editExpense(expenses: expense, action: action, amount: amount, context: managedObjectContext)
        dismiss()
    }
}
