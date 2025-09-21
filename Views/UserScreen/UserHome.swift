import SwiftUI

struct UserHome: View {
    @Binding var rootPath: NavigationPath
    @EnvironmentObject var userVM: UserViewModel

    @State private var restaurants: [Restaurant] = []
    @State private var bookings: [Booking] = []
    @State private var orders: [Order] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var searchText = ""

    private var filteredRestaurants: [Restaurant] {
        if searchText.isEmpty {
            return restaurants
        } else {
            return restaurants.filter { r in
                r.name.localizedCaseInsensitiveContains(searchText) ||
                r.location.localizedCaseInsensitiveContains(searchText) ||
                r.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        TabView {
            homeTab
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            profileTab
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .onAppear {
            fetchRestaurants()
            fetchUserBookingsAndOrders()
        }
    }

    // MARK: - Home Tab
    private var homeTab: some View {
        VStack {
            SearchBar(text: $searchText)

            if isLoading {
                ProgressView("Loading restaurants...")
                    .padding()
            } else if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredRestaurants) { restaurant in
                            RestaurantCardView(
                                restaurant: restaurant,
                                onMenuTap: {
                                    rootPath.append(AppRoute.booking(restaurantId: restaurant.id))
                                },
                                onCardTap: {
                                    rootPath.append(AppRoute.booking(restaurantId: restaurant.id))
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }

    // MARK: - Profile Tab
    private var profileTab: some View {
        ProfileView(bookings: $bookings, orders: $orders)
            .environmentObject(userVM)
    }

    // MARK: - API Calls
    private func fetchRestaurants() {
        APIService.shared.fetchRestaurants { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let res):
                    restaurants = res
                case .failure(let err):
                    errorMessage = err.localizedDescription
                }
            }
        }
    }

    private func fetchUserBookingsAndOrders() {
        guard let userId = userVM.user?.userId else { return }

        APIService.shared.getUserBookings(userId: userId) { result in
            DispatchQueue.main.async {
                if case .success(let res) = result {
                    bookings = res
                }
            }
        }

        APIService.shared.getUserOrders(userId: userId) { result in
            DispatchQueue.main.async {
                if case .success(let res) = result {
                    orders = res
                }
            }
        }
    }
}
