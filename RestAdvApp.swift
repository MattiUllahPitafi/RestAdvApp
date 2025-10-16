import SwiftUI

@main
struct RestAdvApp: App {
    @StateObject private var userVM = UserViewModel()
    @State private var path = NavigationPath()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $path) {
                ContentView(path: $path)
                    .environmentObject(userVM)
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .landing:
                            ContentView(path: $path)
                                .environmentObject(userVM)

                        case .login:
                            LoginView(path: $path)
                                .environmentObject(userVM)

                        case .signup:
                            SignUpView(path: $path)
                                .environmentObject(userVM)

                        case .userHome:
                            UserHome(rootPath: $path)
                                .environmentObject(userVM)
                        case .adminHome:
                            adminHome()
                                .environmentObject(userVM)
                        case.waiterHome:
                            waiterHome(rootPath: $path)
                                .environmentObject(userVM)
//

//                        case .chefView:
//                            chefView()
//                                .environmentObject(userVM)// Replace with ChefHomeView()
                        
                        case .ChefView:
                            ChefView(rootPath: $path)
                                .environmentObject(userVM)

                        case .menu(let restaurantId, let bookingId):
                            MenuView(restaurantId: restaurantId, bookingId: bookingId)
                                .environmentObject(userVM)

                        case .profile:
                            EmptyView()
                        case .booking(let restaurantId):
                            BookingView(restaurantId: restaurantId, path: $path)
                                .environmentObject(userVM)

                        }
                    }
            }
        }
    }
}

//import SwiftUI
//
//@main
//struct RestAdvApp: App {
//    @StateObject var userVM = UserViewModel()
//    @State private var path = NavigationPath()
//
//    var body: some Scene {
//        WindowGroup {
//            NavigationStack(path: $path) {
//                ContentView(path: $path)
//                    .environmentObject(userVM)
//                    .navigationDestination(for: AppRoute.self) { route in
//                        switch route {
//                        case .landing:
//                            ContentView(path: $path)
//                                .environmentObject(userVM)
//                        case .login:
//                            LoginView(path: $path)
//                                .environmentObject(userVM)
//                        case .signup:
//                            SignUpView(path: $path)
//                                .environmentObject(userVM)
//                        case .userHome:
//                            UserHome(rootPath: $path)
//                                .environmentObject(userVM)
//                        case .menu(let restaurantId, let bookingId):
//                            MenuView(restaurantId: restaurantId, bookingId: bookingId)
//                                .environmentObject(userVM)
//
//                        case .profile:
//                            EmptyView()
//                            case .booking(let restaurantId):
//                            BookingView(restaurantId: restaurantId, path: $path)
//                                .environmentObject(userVM)
//                        }
//                    }
//            }
//        }
//    }
//}
