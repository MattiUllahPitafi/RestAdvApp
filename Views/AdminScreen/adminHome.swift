import SwiftUI

struct adminHome: View {
    @EnvironmentObject var userVM: UserViewModel
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // ✅ Top User Info Card
                if let user = userVM.user {
                    VStack(spacing: 8) {
                        Text("👤 \(user.name)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        if let restaurantId = userVM.restaurantId {
                            Text("🏢 Restaurant ID: \(restaurantId)")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .shadow(radius: 3)
                    .padding(.horizontal)
                }
                
                // ✅ Admin Dashboard Options
                ScrollView {
                    VStack(spacing: 20) {
                        NavigationLink(destination: Text("📋 Menu Management")) {
                            DashboardCard(icon: "menucard", title: "Manage Menu")
                        }
                        
                        NavigationLink(destination: ShowChef(adminUserId: userVM.user?.userId ?? 0)) {
                            DashboardCard(icon: "person.2", title: "Manage Chefs")
                        }

                        
                        NavigationLink(destination: showTable(adminUserId: userVM.user?.userId ?? 0)) {
                            DashboardCard(icon: "table", title: "Manage Tables")
                        }

                        
//                        NavigationLink(destination: Text("📦 Ingredients & Stock")) {
//                            DashboardCard(icon: "shippingbox", title: "Manage Stock")
//                        }
                        
                        NavigationLink(destination: Text("🎶 The Music Jukebox")) {
                            DashboardCard(icon: "music.note", title: "Music Jukebox")
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Admin Dashboard")
            .task {
                if let user = userVM.user, user.isAdmin {
                    await userVM.fetchAdminRestaurant(userId: user.userId)
                }
                isLoading = false
            }
        }
    }
}

// ✅ Reusable Dashboard Card Component
struct DashboardCard: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.blue)
                .frame(width: 40)
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}
