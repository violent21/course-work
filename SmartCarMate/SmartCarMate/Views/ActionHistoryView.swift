import SwiftUI

struct ActionHistoryView: View {
    @State private var action = ""
    @State private var amount: Double = 0
    @State private var amountText: String = ""
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var expense: FetchedResults<Expenses>
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            
            VStack {
                Text("Enter action history")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 4)
                
                TextField("Action", text: $action)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            
            TextField("Amount", text: $amountText)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            Button(action: {
                guard let amount = Double(amountText) else {
                    return
                }
                
                DataController().addExpense(action: action, amount: amount, context: managedObjectContext)
                action = ""
                amountText = ""
                showAlert = true
            }) {
                Text("Save")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Success"), message: Text("Data saved successfully"), dismissButton: .default(Text("OK")))
        }
    }
}

struct ActionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ActionHistoryView()
    }
}
