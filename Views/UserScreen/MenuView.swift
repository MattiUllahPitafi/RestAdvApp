
// MARK: - Ingredient Row
struct IngredientRow: View {
    let dishId: Int
    let quantity: Int
    let index: Int
    let ingredient: Ingredient
    @Binding var skippedIngredients: [Int: [[Int]]]

    private var binding: Binding<Bool> {
        let currentSets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)
        let isSelected = !currentSets[index].contains(ingredient.ingredientId)

        return Binding<Bool>(
            get: { isSelected },
            set: { newValue in
                var sets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)
                if newValue {
                    sets[index].removeAll { $0 == ingredient.ingredientId }
                } else {
                    sets[index].append(ingredient.ingredientId)
                }
                skippedIngredients[dishId] = sets
            }
        )
    }

    var body: some View {
        HStack {
            CheckboxView(isOn: binding)
            Text(ingredient.name)
                .font(.footnote)
        }
    }
};
import SwiftUI

// MARK: - Custom Checkbox
struct CheckboxView: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: { isOn.toggle() }) {
            Image(systemName: isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(isOn ? .blue : .gray)
        }
        .buttonStyle(.plain)
    }
}


struct MenuView: View {
    let restaurantId: Int
    let bookingId: Int
    
    @EnvironmentObject var userVM: UserViewModel
    
    @State private var dishes: [Dish] = []
    @State private var quantities: [Int: Int] = [:] // dishId : quantity
    @State private var skippedIngredients: [Int: [[Int]]] = [:] // dishId → array of skipped sets, one per quantity
    
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    @State private var isSubmittingOrder = false
    @State private var orderMessage: String?
    
    // ✅ Total bill calculation
    var totalBill: Double {
        dishes.reduce(0.0) { result, dish in
            result + (dish.price * Double(quantities[dish.dishId] ?? 0))
        }
    }
    
    // ✅ Helper: Binding for ingredient checkbox
    private func bindingForIngredient(dishId: Int, quantity: Int, index: Int, ingredientId: Int) -> Binding<Bool> {
        let currentSets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)
        let isSelected = !currentSets[index].contains(ingredientId)
        
        return Binding<Bool>(
            get: { isSelected },
            set: { newValue in
                var sets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)
                if newValue {
                    sets[index].removeAll { $0 == ingredientId }
                } else {
                    sets[index].append(ingredientId)
                }
                skippedIngredients[dishId] = sets
            }
        )
    }
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Menu...")
            } else if let error = errorMessage {
                Text("Error: \(error)").foregroundColor(.red)
            } else {
                List {
                    ForEach(dishes) { dish in
                        VStack(alignment: .leading, spacing: 6) {
                            // 🔹 Dish row with + / - controls
                            HStack {
                                AsyncImage(url: URL(string: "http://10.211.55.7/\(dish.dishImageUrl)")) { image in
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color.gray.opacity(0.1)
                                }
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)

                                VStack(alignment: .leading) {
                                    Text(dish.dishName).font(.headline)
                                    Text("Rs \(dish.price, specifier: "%.0f") • \(dish.prepTimeMinutes) min")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                // ✅ Quantity controls
                                HStack(spacing: 12) {
                                    // Minus button
                                    Button(action: {
                                        let current = quantities[dish.dishId] ?? 0
                                        if current > 0 {
                                            let newQuantity = current - 1
                                            quantities[dish.dishId] = newQuantity

                                            // Keep skippedIngredients in sync
                                            var sets = skippedIngredients[dish.dishId] ?? []
                                            if sets.count > newQuantity {
                                                sets.removeLast(sets.count - newQuantity)
                                            }
                                            skippedIngredients[dish.dishId] = sets
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                            .font(.title2)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())

                                    Text("\(quantities[dish.dishId] ?? 0)")
                                        .frame(width: 30)

                                    // Plus button
                                    Button(action: {
                                        let current = quantities[dish.dishId] ?? 0
                                        let newQuantity = current + 1
                                        quantities[dish.dishId] = newQuantity

                                        // Keep skippedIngredients in sync
                                        var sets = skippedIngredients[dish.dishId] ?? []
                                        while sets.count < newQuantity {
                                            sets.append([]) // add empty skipped set
                                        }
                                        skippedIngredients[dish.dishId] = sets
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.title2)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            } // end HStack

                            // 🔹 Ingredients per quantity (below HStack)
                            if let quantity = quantities[dish.dishId], quantity > 0, !dish.ingredients.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(0..<quantity, id: \.self) { index in
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(dish.dishName) #\(index + 1)")
                                                .font(.subheadline)
                                                .foregroundColor(.blue)

                                            ForEach(dish.ingredients) { ingredient in
                                                IngredientRow(
                                                    dishId: dish.dishId,
                                                    quantity: quantity,
                                                    index: index,
                                                    ingredient: ingredient,
                                                    skippedIngredients: $skippedIngredients
                                                )
                                            }
                                        }
                                        .padding(.leading, 70)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    }

                    // ✅ Summary & Place Order section
                    VStack(spacing: 12) {
                        HStack {
                            Spacer()
                            Text("Total: Rs \(totalBill, specifier: "%.0f")")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            Spacer()
                        }

                        Button(action: submitOrder) {
                            if isSubmittingOrder {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Place Order")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(totalBill > 0 ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .disabled(isSubmittingOrder || totalBill == 0)

                        if let message = orderMessage {
                            Text(message)
                                .foregroundColor(orderMessage == "Order placed successfully!" ? .green : .red)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Menu")
        .onAppear {
            fetchMenu()
        }
    }

        // ✅ Fetch menu from API
        func fetchMenu() {
            guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/menu/restaurant/\(restaurantId)") else {
                errorMessage = "Invalid menu URL"
                isLoading = false
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    isLoading = false
                    if let error = error {
                        errorMessage = error.localizedDescription
                        return
                    }
                    
                    guard let data = data else {
                        errorMessage = "No data received"
                        return
                    }
                    
                    do {
                        dishes = try JSONDecoder().decode([Dish].self, from: data)
                    } catch {
                        errorMessage = "Decoding failed: \(error.localizedDescription)"
                    }
                }
            }.resume()
        }
        
        // ✅ Submit order to API
        func submitOrder() {
            guard let userId = userVM.loggedInUserId else {
                orderMessage = "Please log in to place an order."
                return
            }
            
            // 🔥 Split items if skipped sets differ
            var orderItems: [[String: Any]] = []
            
            for (dishId, quantity) in quantities where quantity > 0 {
                let skippedSets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)
                
                // if all skipped sets are identical, merge into one row
                if skippedSets.allSatisfy({ $0 == skippedSets.first }) {
                    orderItems.append([
                        "DishId": dishId,
                        "Quantity": quantity,
                        "SkippedIngredients": skippedSets.first ?? []
                    ])
                } else {
                    // otherwise, split into multiple rows
                    for set in skippedSets {
                        orderItems.append([
                            "DishId": dishId,
                            "Quantity": 1,
                            "SkippedIngredients": set
                        ])
                    }
                }
            }
            
            guard !orderItems.isEmpty else {
                orderMessage = "Please select at least one dish."
                return
            }
            
            let orderData: [String: Any] = [
                "UserId": userId,
                "BookingId": bookingId,
                "OrderItems": orderItems
            ]
            
            guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/order/add") else {
                orderMessage = "Invalid order URL."
                return
            }
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: orderData) else {
                orderMessage = "Failed to encode order data."
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            isSubmittingOrder = true
            orderMessage = nil
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    isSubmittingOrder = false
                    
                    if let error = error {
                        orderMessage = "Error: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        orderMessage = "No response from server."
                        return
                    }
                    
                    if !(200...299).contains(httpResponse.statusCode) {
                        let serverMsg = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown server error."
                        orderMessage = "Server error (\(httpResponse.statusCode)): \(serverMsg)"
                        return
                    }
                    
                    // ✅ Success
                    orderMessage = "Order placed successfully!"
                    quantities = [:]
                    skippedIngredients = [:]
                }
            }.resume()
        }
    }

