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
//    // Fetch all orders assigned to chef
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
//                    self.orders = decoded
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    self.errorMessage = "Failed to decode: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//
//    // Update order status (Start Prep / Completed)
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
//        // Must wrap string in quotes for JSON
//        let body = "\"\(status)\"".data(using: .utf8)
//        request.httpBody = body
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
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
//                        // ✅ Buttons to update status
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
//}
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
    let dishes: [DishDetails]
}

struct DishDetails: Codable, Identifiable {
    let dishId: Int
    let dishName: String
    let quantity: Int
    
    var id: Int { dishId }
}

// MARK: - ViewModel
class ChefOrdersViewModel: ObservableObject {
    @Published var orders: [ChefOrder] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Fetch orders assigned to chef
    func fetchOrders(for chefId: Int) {
        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/cheforder/byid/\(chefId)") else {
            errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode([ChefOrder].self, from: data)
                DispatchQueue.main.async {
                    // ✅ filter out Completed and Cancelled
                    self.orders = decoded.filter { order in
                        let status = order.order.status.lowercased()
                        return status != "completed"
                        && status != "Cancelled" && status != "cancelled" && status != "CANCELLED"
                        && status != "Cancelled"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    // Update order status
    func updateOrderStatus(orderId: Int, status: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/order/status/\(orderId)") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Must wrap plain string inside quotes for JSON
        let body = "\"\(status)\"".data(using: .utf8)
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async { completion(true) }
            } else {
                DispatchQueue.main.async { completion(false) }
            }
        }.resume()
    }
}

// MARK: - View
struct chefView: View {
    @EnvironmentObject var userVM: UserViewModel
    @StateObject private var viewModel = ChefOrdersViewModel()
    
    var body: some View {
        VStack {
            Text("Chef-Home")
                .foregroundColor(.green)
            Text("Orders To Prepare")
                .foregroundColor(.orange)
            
            if viewModel.isLoading {
                ProgressView("Loading orders...")
            } else if let error = viewModel.errorMessage {
                Text("⚠️ \(error)").foregroundColor(.red)
            } else {
                List(viewModel.orders) { order in
                    Section(header: Text("Order #\(order.orderId) - \(order.order.status)")) {
                        ForEach(order.order.dishes) { dish in
                            HStack {
                                Text(dish.dishName)
                                Spacer()
                                Text("x\(dish.quantity)")
                            }
                        }
                        Text("📅 \(order.order.orderDate)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        // ✅ Action buttons
                        HStack {
                            Button("Start Prep") {
                                viewModel.updateOrderStatus(orderId: order.orderId, status: "InProgress") { success in
                                    if success {
                                        viewModel.fetchOrders(for: userVM.loggedInUserId ?? 0)
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Completed") {
                                viewModel.updateOrderStatus(orderId: order.orderId, status: "Completed") { success in
                                    if success {
                                        viewModel.fetchOrders(for: userVM.loggedInUserId ?? 0)
                                    }
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
        }
        .font(.title2)
        .onAppear {
            if let chefId = userVM.loggedInUserId {
                viewModel.fetchOrders(for: chefId)
            }
        }
    }
}

// MARK: - Preview
struct chefView_Previews: PreviewProvider {
    static var previews: some View {
        chefView()
            .environmentObject(UserViewModel())
    }
}
