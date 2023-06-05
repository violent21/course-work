import SwiftUI
import CoreData
import UserNotifications
import MapKit
import CoreLocation

struct MileageEntry: Identifiable {
    let id = UUID()
    let date: Date
    let mileage: Double
}

struct ContentView: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor.systemGray4
    }
    @State private var distance: Double = 0
    @State private var fuelConsumption: Double = 0
    @State private var fuelPrice: Double = 0

    private var fuelUsed: Double {
        return (distance / 100) * fuelConsumption
    }

    private var totalCost: Double {
        return fuelUsed * fuelPrice
    }
    
    @State private var action = ""
    @State private var amount: Double = 0
    @State private var amountText: String = ""
    @State private var showAddView = false
    @ObservedObject private var reminderManager = ReminderManager()
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 46.4825, longitude: 30.7233), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    @State private var userTrackingMode: MapUserTrackingMode = .none
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var expense: FetchedResults<Expenses>
    
    @State private var showingAddView = false
    
    @State private var mileageEntries: [MileageEntry] = [
        MileageEntry(date: Date().addingTimeInterval(-86400 * 5), mileage: 2000),
        MileageEntry(date: Date().addingTimeInterval(-86400 * 4), mileage: 2300),
        MileageEntry(date: Date().addingTimeInterval(-86400 * 3), mileage: 2500),
        MileageEntry(date: Date().addingTimeInterval(-86400 * 2), mileage: 2900),
        MileageEntry(date: Date().addingTimeInterval(-86400 * 1), mileage: 3200)
    ]
    @State private var newMileage: String = ""
    @State private var showAlert = false
    
    var body: some View {
        let _: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
        
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter
        }()
        
        TabView {
            NavigationView {
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
                        // Преобразование текста в Double при сохранении
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
                    
                    Divider()
                    
                    VStack {
                        Text("Enter mileage history")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.bottom, 2)
                        
                        HStack {
                            TextField("Enter Mileage", text: $newMileage)
                                .keyboardType(.decimalPad)
                                .padding(.horizontal)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            
                            Button(action: {
                                addMileageEntry()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                    .imageScale(.large)
                            }
                            .padding(.trailing)
                        }
                        .padding(.top)
                    }
                    Divider()
                    Spacer()
                    
                    VStack {
                        Text("Fuel burnt calculator")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.bottom, 4)
                        Form {
                            Section(header: Text("Distance")) {
                                TextField("Distance (km)", value: $distance, formatter: createDecimalFormatter())
                                    .keyboardType(.decimalPad)
                            }
                            
                            Section(header: Text("Fuel Consumption")) {
                                TextField("Fuel Consumption (L/100km)", value: $fuelConsumption, formatter: createDecimalFormatter())
                                    .keyboardType(.decimalPad)
                            }
                            
                            Section(header: Text("Fuel Price")) {
                                TextField("Fuel Price", value: $fuelPrice, formatter: createDecimalFormatter())
                                    .keyboardType(.decimalPad)
                            }
                            
                            Section(header: Text("Fuel Used")) {
                                Text("\(fuelUsed, specifier: "%.2f") liters")
                            }
                            
                            Section(header: Text("Total Cost")) {
                                Text("\(totalCost, specifier: "%.2f") UAH")
                            }
                        }
                    }
                }
                .padding()
                .navigationTitle("Home")
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Success"), message: Text("Data saved successfully"), dismissButton: .default(Text("OK")))
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
 
            NavigationView {
                VStack(alignment: .leading) {
                    Text("Total amount spent: \(Int(totalAmountSpent()))" + " UAH")
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    List {
                        ForEach(expense) { expense in
                            NavigationLink(destination: EditExpenseView(expense: expense)) {
                                HStack{
                                    VStack(alignment: .leading, spacing: 6){
                                        Text(expense.action!)
                                            .bold()
                                        
                                        Text("\(Int(expense.amount))") + Text(" UAH").foregroundColor(.red)
                                    }
                                    Spacer()
                                    Text(calcTimeSince(date: expense.date!))
                                        .foregroundColor(.gray)
                                        .italic()
                                }
                            }
                        }
                        .onDelete(perform: deleteExpense)
                    }
                    .listStyle(.plain)
                }
                .navigationTitle("History")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("History")
            }
            
            NavigationView {
                List {
                    ForEach(reminderManager.reminders) { reminder in
                        //ForEach(reminders) { reminder in
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: reminder.isCompleted ? "checkmark.square.fill" : "square")
                                    .onTapGesture {
                                        toggleReminderCompletion(reminder)
                                    }
                                Text(reminder.title)
                                    .font(.headline)
                            }
                            Text(dateFormatter.string(from: reminder.date))
                                .font(.subheadline)
                                .foregroundColor(reminder.isDateExpired ? .red : .gray)
                        }
                    }
                    .onDelete(perform: deleteReminder)
                }
                .navigationTitle("Reminders")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showAddView = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showAddView) {
                    AddReminderView(reminderManager: reminderManager)
                }
                .onReceive(reminderManager.objectWillChange) { _ in
                    // Обновление списка при изменении данных
                }
            }
            .tabItem {
                Image(systemName: "calendar.badge.plus")
                Text("Reminders")
            }
            
            NavigationView {
                GeometryReader { geometry in
                    VStack {
                        MapView(region: $region, userTrackingMode: $userTrackingMode)
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.9)
                            .edgesIgnoringSafeArea(.all)
                        VStack {
                            HStack {
                                Button(action: {
                                    if userTrackingMode == .follow {
                                        userTrackingMode = .none
                                    } else {
                                        userTrackingMode = .follow
                                    }
                                }) {
                                    Image(systemName: userTrackingMode == .follow ? "location.fill" : "location")
                                        .frame(width: 36, height: 36)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                                .padding(16)
                                
                                Button(action: {
                                    region.span.latitudeDelta /= 2
                                    region.span.longitudeDelta /= 2
                                }) {
                                    Image(systemName: "plus")
                                        .frame(width: 36, height: 36)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                                .padding(16)
                                
                                Button(action: {
                                    region.span.latitudeDelta *= 2
                                    region.span.longitudeDelta *= 2
                                }) {
                                    Image(systemName: "minus")
                                        .frame(width: 36, height: 36)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                                .padding(16)
                            }
                        }
                        .accentColor(.blue)
                    }
                }
            }
            .tabItem {
                Image(systemName: "fuelpump")
                Text("Map")
            }

            NavigationView {
                VStack {
                    VStack {
                        HStack {
                            TextField("Enter Mileage", text: $newMileage)
                                .keyboardType(.decimalPad)
                                .padding(.horizontal)
                            
                            Button(action: {
                                addMileageEntry()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                    .imageScale(.large)
                            }
                            .padding(.trailing)
                        }
                        .padding(.top)
                        
                        Divider()
                        
                        if mileageEntries.isEmpty {
                            Text("No Mileage Entries")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            mileageChart()
                                .frame(height: 250)
                                .padding()
                        }
                    }
                }
                .navigationTitle("Mileage Manager")
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Invalid Mileage"), message: Text("Please enter a higher mileage value"), dismissButton: .default(Text("OK")))
                }
            }
            .tabItem {
                Image(systemName: "engine.combustion")
                Text("Mileage")
            }
        }
    }
    
    private func createDecimalFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 10
        return formatter
    }
    
    private func totalAmountSpent() -> Double {
        var totalAmount: Double = 0
        for item in expense {
            //if Calendar.current.isDateInToday(item.date!) {
            totalAmount += item.amount
            //}
        }
        return totalAmount
    }
    
    private func deleteExpense(offsets: IndexSet){
        withAnimation {
            offsets.map { expense[$0] }.forEach(managedObjectContext.delete)
            
            DataController().save(context: managedObjectContext)
        }
    }
    
    func deleteReminder(at offsets: IndexSet) {
        offsets.forEach { index in
            let reminder = reminderManager.reminders[index]
            reminderManager.deleteReminder(reminder)
        }
    }
    
    func toggleReminderCompletion(_ reminder: Reminder) {
        if let index = reminderManager.reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminderManager.reminders[index].isCompleted.toggle()
        }
    }
    
    func addMileageEntry() {
        guard let mileage = Double(newMileage) else {
            return
        }
        
        let lastMileage = mileageEntries.last?.mileage ?? 0
        
        if mileage < lastMileage {
            showAlert = true
            return
        }
        
        let entry = MileageEntry(date: Date(), mileage: mileage)
        mileageEntries.append(entry)
        newMileage = ""
    }
    
    func mileageChart() -> some View {
        let sortedEntries = mileageEntries.sorted(by: { $0.date < $1.date })
        let mileageValues = sortedEntries.map { Int($0.mileage) }
        let dates = sortedEntries.map { $0.date }
        
        let minValue = mileageValues.min() ?? 0
        let maxValue = mileageValues.max() ?? 0
        
        return VStack {
            HStack {
                Text("\(formatDate(date: dates.first ?? Date()))")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("\(formatDate(date: dates.last ?? Date()))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 300)
                    
                    HStack(alignment: .bottom, spacing: 0) {
                        ForEach(0..<mileageValues.count, id: \.self) { index in
                            VStack {
                                Spacer()
                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(width: geometry.size.width / CGFloat(mileageValues.count), height: calculateBarHeight(value: Double(mileageValues[index]), minValue: Double(minValue), maxValue: Double(maxValue), height: geometry.size.height))
                                    .clipped() // Ограничиваем прямоугольник границами контейнера
                                    .padding(.bottom) // Добавляем небольшой отступ вниз, чтобы прямоугольник не прилипал к границе
                                Text("\(mileageValues[index])")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                    .padding(.top, 4)
                                    .frame(width: geometry.size.width / CGFloat(mileageValues.count))
                                    .clipped() // Ограничиваем текст границами контейнера
                                Text("\(formatDate(date: dates[index]))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(width: geometry.size.width / CGFloat(mileageValues.count))
                            }
                        }
                    }
                }
            }
        }
    }
    
    func calculateBarHeight(value: Double, minValue: Double, maxValue: Double, height: CGFloat) -> CGFloat {
        let range = maxValue - minValue
        let normalizedValue = value - minValue
        let ratio = normalizedValue / range
        
        return ratio * height
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
