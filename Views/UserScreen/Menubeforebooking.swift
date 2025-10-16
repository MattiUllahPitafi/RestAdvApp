import SwiftUI

struct MenuBeforeBooking: View {
    let restaurantId: Int
    
    @State private var dishes: [Dish] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var quantities: [Int: Int] = [:] // dishId : quantity
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Menu...")
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                List {
                    ForEach(dishes) { dish in
                        HStack(spacing: 12) {
                            // Dish image
                            AsyncImage(url: URL(string: "http://10.211.55.7/\(dish.dishImageUrl)")) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(width: 70, height: 70)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            // Dish details
                            VStack(alignment: .leading, spacing: 4) {
                                Text(dish.dishName)
                                    .font(.headline)
                                
                                Text("Rs \(dish.price, specifier: "%.0f") • ⏱ \(dish.prepTimeMinutes) min")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            
                        }
                        .padding(.vertical, 6)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Menu")
        .onAppear {
            fetchMenu()
        }
    }
    
    // MARK: - API Call
    private func fetchMenu() {
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
}

