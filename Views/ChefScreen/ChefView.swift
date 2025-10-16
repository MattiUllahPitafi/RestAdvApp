//
//import SwiftUI
//
//// MARK: - Models
//struct ChefOrder: Codable, Identifiable {
//    let orderId: Int
//    let order: OrderDetails
//
//    var id: Int { orderId }
//}
//
//struct OrderDetails: Codable {
//    let orderDate: String
//    let status: String
//    let dishes: [DishDetails]
//}
//
//struct DishDetails: Codable, Identifiable {
//    let dishId: Int
//    let dishName: String
//    let quantity: Int
//
//    var id: Int { dishId }
//}
//
//// MARK: - ViewModel
//class ChefOrdersViewModel: ObservableObject {
//    @Published var orders: [ChefOrder] = []
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//
//    // Fetch orders assigned to chef
//    func fetchOrders(for chefId: Int) {
//        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/cheforder/byid/\(chefId)") else {
//            errorMessage = "Invalid URL"
//            return
//        }
//
//        isLoading = true
//        errorMessage = nil
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            DispatchQueue.main.async {
//                self.isLoading = false
//            }
//
//            if let error = error {
//                DispatchQueue.main.async {
//                    self.errorMessage = error.localizedDescription
//                }
//                return
//            }
//
//            guard let data = data else { return }
//
//            do {
//                let decoded = try JSONDecoder().decode([ChefOrder].self, from: data)
//                DispatchQueue.main.async {
//                    // ✅ filter out Completed and Cancelled
//                    self.orders = decoded.filter { order in
//                        let status = order.order.status.lowercased()
//                        return status != "completed"
//                        && status != "Cancelled" && status != "cancelled" && status != "CANCELLED"
//                        && status != "Cancelled"
//                    }
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    self.errorMessage = "Failed to decode: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//
//    // Update order status
//    func updateOrderStatus(orderId: Int, status: String, completion: @escaping (Bool) -> Void) {
//        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/order/status/\(orderId)") else {
//            completion(false)
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // Must wrap plain string inside quotes for JSON
//        let body = "\"\(status)\"".data(using: .utf8)
//        request.httpBody = body
//
//        URLSession.shared.dataTask(with: request) { _, response, _ in
//            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//                DispatchQueue.main.async { completion(true) }
//            } else {
//                DispatchQueue.main.async { completion(false) }
//            }
//        }.resume()
//    }
//}
//
//// MARK: - View
//struct chefView: View {
//    @EnvironmentObject var userVM: UserViewModel
//    @StateObject private var viewModel = ChefOrdersViewModel()
//
//    var body: some View {
//        VStack {
//            Text("Chef-Home")
//                .foregroundColor(.green)
//            Text("Orders To Prepare")
//                .foregroundColor(.orange)
//
//            if viewModel.isLoading {
//                ProgressView("Loading orders...")
//            } else if let error = viewModel.errorMessage {
//                Text("⚠️ \(error)").foregroundColor(.red)
//            } else {
//                List(viewModel.orders) { order in
//                    Section(header: Text("Order #\(order.orderId) - \(order.order.status)")) {
//                        ForEach(order.order.dishes) { dish in
//                            HStack {
//                                Text(dish.dishName)
//                                Spacer()
//                                Text("x\(dish.quantity)")
//                            }
//                        }
//                        Text("📅 \(order.order.orderDate)")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//
//                        // ✅ Action buttons
//                        HStack {
//                            Button("Start Prep") {
//                                viewModel.updateOrderStatus(orderId: order.orderId, status: "InProgress") { success in
//                                    if success {
//                                        viewModel.fetchOrders(for: userVM.loggedInUserId ?? 0)
//                                    }
//                                }
//                            }
//                            .buttonStyle(.borderedProminent)
//
//                            Button("Completed") {
//                                viewModel.updateOrderStatus(orderId: order.orderId, status: "Completed") { success in
//                                    if success {
//                                        viewModel.fetchOrders(for: userVM.loggedInUserId ?? 0)
//                                    }
//                                }
//                            }
//                            .buttonStyle(.bordered)
//                        }
//                    }
//                }
//            }
//        }
//        .font(.title2)
//        .onAppear {
//            if let chefId = userVM.loggedInUserId {
//                viewModel.fetchOrders(for: chefId)
//            }
//        }
//    }
//}
//
//// MARK: - Preview
//struct chefView_Previews: PreviewProvider {
//    static var previews: some View {
//        chefView()
//            .environmentObject(UserViewModel())
//    }
//}import SwiftUI

import SwiftUI

// MARK: - Models
struct ChefOrder: Codable, Identifiable {
    let orderId: Int
    let order: OrderDetails
    
    var id: Int { orderId }
}

struct OrderDetails: Codable {
    let orderDate: String
    let status: String
    let bookingDateTime: String?
    let dishes: [DishDetails]
}

struct DishDetails: Codable, Identifiable {
    let orderItemId: Int
    let dishId: Int
    let dishName: String
    let quantity: Int
    let prepTimeMinutes: Int?
    let skippedIngredients: [String]
    var id: Int { orderItemId }}

// MARK: - ViewModel
@MainActor
class ChefOrdersViewModel: ObservableObject {
    @Published var visibleOrders: [ChefOrder] = []
    @Published var upcomingOrders: [ChefOrder] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let isoWithFractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    private let isoNoFraction: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private func parseISODate(_ s: String) -> Date? {
        if let d = isoWithFractional.date(from: s) { return d }
        if let d = isoNoFraction.date(from: s) { return d }
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        let patterns = [
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss.S",
            "yyyy-MM-dd'T'HH:mm:ss.SS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS"
        ]
        for p in patterns {
            df.dateFormat = p
            if let d = df.date(from: s) { return d }
        }
        return nil
    }

    // Fetch orders
    func fetchOrders(for chefId: Int) async {
        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/cheforder/byid/\(chefId)") else {
            errorMessage = "Invalid API URL"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse,
               !(httpResponse.mimeType?.contains("application/json") ?? false) {
                let text = String(data: data, encoding: .utf8) ?? "<non-text response>"
                errorMessage = "Server did not return JSON. Response:\n" + text.prefix(2000)
                isLoading = false
                return
            }

            let decoded = try JSONDecoder().decode([ChefOrder].self, from: data)
            let now = Date()

            let (visible, upcoming) = decoded.reduce(into: ([ChefOrder](), [ChefOrder]())) { acc, order in
                let status = order.order.status.lowercased()
                guard status != "completed", status != "cancelled" else { return }

                guard let bookingStr = order.order.bookingDateTime,
                      let bookingDate = parseISODate(bookingStr) else { return }

                let maxPrep = order.order.dishes.compactMap { $0.prepTimeMinutes }.max() ?? 0
                let threshold = bookingDate
                    .addingTimeInterval(TimeInterval(-(maxPrep * 60)))
                    .addingTimeInterval(3600)

                if now >= threshold && now <= bookingDate {
                    acc.0.append(order)
                } else if now < threshold {
                    acc.1.append(order)
                }
            }

            visibleOrders = visible
            upcomingOrders = upcoming
            isLoading = false

        } catch {
            errorMessage = "Failed to load orders: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // Update order status (async)
    func updateOrderStatus(orderId: Int, status: String) async -> Bool {
        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/order/status/\(orderId)") else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "\"\(status)\"".data(using: .utf8)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                return true
            }
        } catch { }

        return false
    }
}

// MARK: - Main View
struct ChefView: View {
    @Binding var rootPath: NavigationPath
    @EnvironmentObject var userVM: UserViewModel
    @StateObject private var viewModel = ChefOrdersViewModel()
    
    var body: some View {
        VStack {
            Text("Chef Home")
                .foregroundColor(.green)
                .font(.title)
            
            if viewModel.isLoading {
                ProgressView("Loading orders...")
            } else if let error = viewModel.errorMessage {
                Text("⚠️ \(error)").foregroundColor(.red)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        if !viewModel.visibleOrders.isEmpty {
                            Text("Orders To Prepare")
                                .font(.headline)
                                .foregroundColor(.orange)
                            
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.visibleOrders) { order in
                                    ChefOrderCard(order: order) {
                                        Task {
                                            let success = await viewModel.updateOrderStatus(orderId: order.orderId, status: "InProgress")
                                            if success {
                                                await viewModel.fetchOrders(for: userVM.loggedInUserId ?? 0)
                                            }
                                        }
                                    } onCompleted: {
                                        Task {
                                            let success = await viewModel.updateOrderStatus(orderId: order.orderId, status: "Completed")
                                            if success {
                                                await viewModel.fetchOrders(for: userVM.loggedInUserId ?? 0)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        if !viewModel.upcomingOrders.isEmpty {
                            Text("Upcoming Orders")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.upcomingOrders) { order in
                                    ChefOrderCard(order: order,
                                                  onStartPrep: {},
                                                  onCompleted: {})
                                        .opacity(1)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            if let chefId = userVM.loggedInUserId {
                await viewModel.fetchOrders(for: chefId)
            }
        }
    }
}

// MARK: - Reusable Components
struct ChefOrderCard: View {
    let order: ChefOrder
    let onStartPrep: () -> Void
    let onCompleted: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Order #\(order.orderId)")
                .font(.headline)
            
            Text("Status: \(order.order.status)")
                .font(.subheadline)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(order.order.dishes) { dish in
                    DishRow(dish: dish)
                }
            }
            
            HStack {
                Button("Start Prep", action: onStartPrep)
                    .buttonStyle(.borderedProminent)
                    
                Button("Completed", action: onCompleted)
                    .buttonStyle(.bordered)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

//struct DishRow: View {
//    let dish: DishDetails
//
//    var body: some View {
//        HStack {
//            Text(dish.dishName)
//            Spacer()
//            Text("x\(dish.quantity)")
//        }
//        .font(.callout)
//    }
//}
import SwiftUI

struct DishRow: View {
    let dish: DishDetails

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(dish.dishName)
                    .font(.headline)
                Spacer()
                Text("x\(dish.quantity)")
                    .font(.subheadline)
            }

            // Show skipped ingredients if any
            if !dish.skippedIngredients.isEmpty {
                HStack(spacing: 6) {
                    Text("Skipped:")
                        .font(.subheadline)
                        .foregroundColor(.red)

                    // Display each skipped ingredient as a red capsule
                    ForEach(dish.skippedIngredients, id: \.self) { ingredient in
                        Text(ingredient)
                            .font(.headline)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
// MARK: - Preview
struct ChefView_Previews: PreviewProvider {
    static var previews: some View {
        ChefView(rootPath: .constant(NavigationPath()))
            .environmentObject(UserViewModel())
    }
}
