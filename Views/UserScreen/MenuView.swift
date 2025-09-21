import SwiftUI

struct MenuView: View {
    let restaurantId: Int
    let bookingId: Int  // pass bookingId when navigating here

    @EnvironmentObject var userVM: UserViewModel

    @State private var dishes: [Dish] = []
    @State private var quantities: [Int: Int] = [:] // dishId : quantity
    @State private var isLoading = true
    @State private var errorMessage: String?

    @State private var isSubmittingOrder = false
    @State private var orderMessage: String?

    // ✅ Fixed: cast price to Double & use dishId
    var totalBill: Double {
        dishes.reduce(0.0) { result, dish in
            result + (Double(dish.price) * Double(quantities[dish.dishId] ?? 0))
        }
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
                        HStack {
                            AsyncImage(url: URL(string: "http://10.211.55.4/\(dish.dishImageUrl)")) { image in
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

                            Stepper(value: Binding(
                                get: { quantities[dish.dishId] ?? 0 },
                                set: { quantities[dish.dishId] = $0 }
                            ), in: 0...99) {
                                Text("\(quantities[dish.dishId] ?? 0)")
                                    .frame(width: 30)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    // ✅ Total Bill Row
                    HStack {
                        Spacer()
                        Text("Total: Rs \(totalBill, specifier: "%.0f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        Spacer()
                    }
                }

                // ✅ Place Order button
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
                .padding()

                if let message = orderMessage {
                    Text(message)
                        .foregroundColor(orderMessage == "Order placed successfully!" ? .green : .red)
                        .padding(.horizontal)
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
        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/menu/restaurant/\(restaurantId)") else {
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

        // Prepare OrderItems array, only dishes with quantity > 0
        let orderItems = quantities.compactMap { (dishId, quantity) -> [String: Any]? in
            guard quantity > 0 else { return nil }
            return ["DishId": dishId, "Quantity": quantity]
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

        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/order/add") else {
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

                orderMessage = "Order placed successfully!"
                // ✅ Clear selections after success
                quantities = [:]
            }
        }.resume()
    }
}
//
//import SwiftUI
//
//struct MenuView: View {
//    let restaurantId: Int
//    let bookingId: Int
//
//    @EnvironmentObject var userVM: UserViewModel
//
//    @State private var dishes: [Dish] = []
//    @State private var quantities: [Int: Int] = [:]
//    @State private var isLoading = true
//    @State private var errorMessage: String?
//
//    @State private var isSubmittingOrder = false
//    @State private var orderMessage: String?
//
//    var totalBill: Double {
//        dishes.reduce(0.0) { result, dish in
//            result + (Double(dish.price) * Double(quantities[dish.dishId] ?? 0))
//        }
//    }
//
//    var body: some View {
//        VStack {
//            if isLoading {
//                ProgressView("Loading Menu...")
//            } else if let error = errorMessage {
//                Text("Error: \(error)").foregroundColor(.red)
//            } else {
//                List {
//                    ForEach(dishes) { dish in
//                        HStack {
//                            AsyncImage(url: URL(string: "http://10.211.55.4/\(dish.dishImageUrl)")) { image in
//                                image.resizable().aspectRatio(contentMode: .fill)
//                            } placeholder: {
//                                Color.gray.opacity(0.1)
//                            }
//                            .frame(width: 60, height: 60)
//                            .cornerRadius(8)
//
//                            VStack(alignment: .leading) {
//                                Text(dish.dishName).font(.headline)
//                                Text("Rs \(dish.price, specifier: "%.0f") • \(dish.prepTimeMinutes) min")
//                                    .font(.subheadline)
//                                    .foregroundColor(.gray)
//                            }
//
//                            Spacer()
//
//                            Stepper(value: Binding(
//                                get: { quantities[dish.dishId] ?? 0 },
//                                set: { quantities[dish.dishId] = $0 }
//                            ), in: 0...99) {
//                                Text("\(quantities[dish.dishId] ?? 0)")
//                                    .frame(width: 30)
//                            }
//                        }
//                        .padding(.vertical, 4)
//                    }
//
//                    HStack {
//                        Spacer()
//                        Text("Total: Rs \(totalBill, specifier: "%.0f")")
//                            .font(.title2)
//                            .fontWeight(.bold)
//                            .foregroundColor(.orange)
//                        Spacer()
//                    }
//                }
//
//                Button(action: submitOrder) {
//                    if isSubmittingOrder {
//                        ProgressView().frame(maxWidth: .infinity).padding()
//                    } else {
//                        Text("Place Order")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(totalBill > 0 ? Color.blue : Color.gray)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                }
//                .disabled(isSubmittingOrder || totalBill == 0)
//                .padding()
//
//                if let message = orderMessage {
//                    Text(message)
//                        .foregroundColor(orderMessage == "Order placed successfully!" ? .green : .red)
//                        .padding(.horizontal)
//                }
//            }
//        }
//        .navigationTitle("Menu")
//        .onAppear { fetchMenu() }
//    }
//
//    func fetchMenu() {
//        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/menu/restaurant/\(restaurantId)") else {
//            errorMessage = "Invalid menu URL"
//            isLoading = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            DispatchQueue.main.async {
//                isLoading = false
//                if let error = error {
//                    errorMessage = error.localizedDescription
//                    return
//                }
//                guard let data = data else {
//                    errorMessage = "No data received"
//                    return
//                }
//                do {
//                    dishes = try JSONDecoder().decode([Dish].self, from: data)
//                } catch {
//                    errorMessage = "Decoding failed: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//
//    func submitOrder() {
//        guard let userId = userVM.loggedInUserId else {
//            orderMessage = "Please log in to place an order."
//            return
//        }
//
//        let orderItems = quantities.compactMap { (dishId, quantity) -> [String: Any]? in
//            guard quantity > 0 else { return nil }
//            return ["DishId": dishId, "Quantity": quantity]
//        }
//        guard !orderItems.isEmpty else {
//            orderMessage = "Please select at least one dish."
//            return
//        }
//
//        let orderData: [String: Any] = [
//            "UserId": userId,
//            "BookingId": bookingId,
//            "OrderItems": orderItems
//        ]
//
//        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/order/add") else {
//            orderMessage = "Invalid order URL."
//            return
//        }
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: orderData) else {
//            orderMessage = "Failed to encode order data."
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//
//        isSubmittingOrder = true
//        orderMessage = nil
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                isSubmittingOrder = false
//                if let error = error {
//                    orderMessage = "Error: \(error.localizedDescription)"
//                    return
//                }
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    orderMessage = "No response from server."
//                    return
//                }
//                if !(200...299).contains(httpResponse.statusCode) {
//                    let serverMsg = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown server error."
//                    orderMessage = "Server error (\(httpResponse.statusCode)): \(serverMsg)"
//                    return
//                }
//                orderMessage = "Order placed successfully!"
//                quantities = [:]
//            }
//        }.resume()
//    }
//}
