//import SwiftUI
//
//// MARK: - Models
//struct ChefModel: Identifiable, Codable {
//    var id: Int { userId }
//    let userId: Int
//    let userName: String
//    let specialities: [String]
//}
//
//// MARK: - ViewModel
//@MainActor
//class ChefViewModel: ObservableObject {
//    @Published var chefs: [ChefModel] = []
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    @Published var successMessage: String?
//
//    // ✅ Fetch chefs for admin's restaurant
//    func fetchChefs(adminUserId: Int) {
//        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/admin/GetAllChef/\(adminUserId)") else {
//            errorMessage = "Invalid URL"
//            return
//        }
//
//        isLoading = true
//        errorMessage = nil
//
//        Task {
//            do {
//                let (data, response) = try await URLSession.shared.data(from: url)
//                guard let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200 else {
//                    errorMessage = "Failed to load chefs."
//                    isLoading = false
//                    return
//                }
//
//                let chefs = try JSONDecoder().decode([ChefModel].self, from: data)
//                self.chefs = chefs
//            } catch {
//                errorMessage = "Error: \(error.localizedDescription)"
//            }
//            isLoading = false
//        }
//    }
//
//    // ✅ Create new chef
//    func createChef(adminUserId: Int, name: String, email: String, password: String, dishNames: [String]) async -> Bool {
//        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/admin/CreateChef") else {
//            errorMessage = "Invalid URL"
//            return false
//        }
//
//        let payload: [String: Any] = [
//            "adminUserId": adminUserId,
//            "user": [
//                "Name": name,
//                "Email": email,
//                "PasswordHash": password,
//                "Role": "Chef"
//            ],
//            "dishNames": dishNames
//        ]
//
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
//            errorMessage = "Invalid data"
//            return false
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//            guard let httpRes = response as? HTTPURLResponse else { return false }
//
//            if httpRes.statusCode == 200 {
//                successMessage = "✅ Chef created successfully!"
//                return true
//            } else {
//                let err = String(data: data, encoding: .utf8) ?? "Unknown error"
//                errorMessage = "⚠️ Failed: \(err)"
//                return false
//            }
//        } catch {
//            errorMessage = "Error: \(error.localizedDescription)"
//            return false
//        }
//    }
//}
//
//// MARK: - ShowChef Main View
//struct ShowChef: View {
//    @StateObject private var viewModel = ChefViewModel()
//    @State private var showingAddChef = false
//    let adminUserId: Int
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                if viewModel.isLoading {
//                    ProgressView("Loading Chefs...")
//                } else if let error = viewModel.errorMessage {
//                    Text("⚠️ \(error)").foregroundColor(.red)
//                } else {
//                    if viewModel.chefs.isEmpty {
//                        Text("No chefs found yet.")
//                            .foregroundColor(.gray)
//                            .padding()
//                    } else {
//                        List(viewModel.chefs) { chef in
//                            VStack(alignment: .leading, spacing: 8) {
//                                Text("👨‍🍳 \(chef.userName)")
//                                    .font(.headline)
//
//                                if !chef.specialities.isEmpty {
//                                    // 🏷 Show each speciality as a tag
//                                    WrapHStack(spacing: 8) {
//                                        ForEach(chef.specialities, id: \.self) { speciality in
//                                            Text(speciality)
//                                                .padding(.horizontal, 10)
//                                                .padding(.vertical, 5)
//                                                .background(Color.blue.opacity(0.1))
//                                                .foregroundColor(.blue)
//                                                .cornerRadius(10)
//                                        }
//                                    }
//                                } else {
//                                    Text("No specialities yet.")
//                                        .italic()
//                                        .foregroundColor(.gray)
//                                }
//                            }
//                            .padding(.vertical, 6)
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Chefs")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: { showingAddChef = true }) {
//                        Label("Add", systemImage: "plus.circle.fill")
//                    }
//                }
//            }
//            .onAppear {
//                viewModel.fetchChefs(adminUserId: adminUserId)
//            }
//            .sheet(isPresented: $showingAddChef) {
//                AddChefView(adminUserId: adminUserId, viewModel: viewModel)
//            }
//        }
//    }
//}
//
//// MARK: - Add Chef Sheet
//struct AddChefView: View {
//    let adminUserId: Int
//    @ObservedObject var viewModel: ChefViewModel
//
//    @State private var name = ""
//    @State private var email = ""
//    @State private var password = ""
//    @State private var dishNames = ""
//    @Environment(\.dismiss) private var dismiss
//    @State private var isSubmitting = false
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Chef Details")) {
//                    TextField("Name", text: $name)
//                    TextField("Email", text: $email)
//                        .keyboardType(.emailAddress)
//                    SecureField("Password", text: $password)
//                }
//
//                Section(header: Text("Specialities")) {
//                    TextField("Dish names (comma separated)", text: $dishNames)
//                }
//
//                if let message = viewModel.successMessage ?? viewModel.errorMessage {
//                    Text(message)
//                        .foregroundColor(message.contains("✅") ? .green : .red)
//                        .multilineTextAlignment(.center)
//                }
//
//                Button(action: submitChef) {
//                    HStack {
//                        if isSubmitting { ProgressView() }
//                        Text("Create Chef").bold()
//                    }
//                    .frame(maxWidth: .infinity)
//                }
//                .disabled(isSubmitting)
//            }
//            .navigationTitle("Add Chef")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") { dismiss() }
//                }
//            }
//        }
//    }
//
//    private func submitChef() {
//        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
//            viewModel.errorMessage = "⚠️ Please fill all fields"
//            return
//        }
//
//        isSubmitting = true
//        Task {
//            let dishes = dishNames.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
//            let success = await viewModel.createChef(adminUserId: adminUserId, name: name, email: email, password: password, dishNames: dishes)
//
//            if success {
//                viewModel.fetchChefs(adminUserId: adminUserId)
//                dismiss()
//            }
//            isSubmitting = false
//        }
//    }
//}
//
//// MARK: - Helper View (Wrap layout)
//struct WrapHStack<Content: View>: View {
//    let spacing: CGFloat
//    let content: () -> Content
//
//    init(spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
//        self.spacing = spacing
//        self.content = content
//    }
//
//    var body: some View {
//        FlexibleView(availableWidth: UIScreen.main.bounds.width - 60, spacing: spacing, alignment: .leading, content: content)
//    }
//}
//
//// MARK: - FlexibleView to wrap tags
//struct FlexibleView<Content: View>: View {
//    let availableWidth: CGFloat
//    let spacing: CGFloat
//    let alignment: HorizontalAlignment
//    let content: () -> Content
//
//    init(availableWidth: CGFloat, spacing: CGFloat, alignment: HorizontalAlignment, @ViewBuilder content: @escaping () -> Content) {
//        self.availableWidth = availableWidth
//        self.spacing = spacing
//        self.alignment = alignment
//        self.content = content
//    }
//
//    var body: some View {
//        VStack(alignment: alignment, spacing: spacing) {
//            content()
//        }
//    }
//}
import SwiftUI

// MARK: - Models
struct ChefModel: Identifiable, Codable {
    var id: Int { userId }
    let userId: Int
    let name: String
    let email: String?
    let specialities: [String]
    
    enum CodingKeys: String, CodingKey {
        case userId
        case name
        case email
        case specialities
    }
}

// MARK: - ViewModel
@MainActor
class ChefViewModel: ObservableObject {
    @Published var chefs: [ChefModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let baseURL = "http://10.211.55.7/BooknowAPI/api/admin"
    
    // ✅ Fetch chefs (async)
    func fetchChefs(adminUserId: Int) {
        guard let url = URL(string: "\(baseURL)/GetAllChef/\(adminUserId)") else {
            errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpRes = response as? HTTPURLResponse else {
                    errorMessage = "No response from server."
                    isLoading = false
                    return
                }
                
                if httpRes.statusCode == 200 {
                    do {
                        let decoded = try JSONDecoder().decode([ChefModel].self, from: data)
                        self.chefs = decoded
                    } catch {
                        let msg = String(data: data, encoding: .utf8) ?? "Invalid format"
                        self.errorMessage = msg
                    }
                } else {
                    let err = String(data: data, encoding: .utf8) ?? "Unknown error"
                    errorMessage = "⚠️ Server error: \(err)"
                }
            } catch {
                errorMessage = "❌ \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    // ✅ Create chef
    func createChef(adminUserId: Int, name: String, email: String, password: String, dishNames: [String]) async -> Bool {
        guard let url = URL(string: "\(baseURL)/CreateChef") else {
            errorMessage = "Invalid URL"
            return false
        }
        
        let payload: [String: Any] = [
            "adminUserId": adminUserId,
            "user": [
                "Name": name,
                "Email": email,
                "PasswordHash": password,
                "Role": "Chef"
            ],
            "dishNames": dishNames
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            errorMessage = "Invalid JSON payload."
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpRes = response as? HTTPURLResponse else {
                errorMessage = "Invalid server response."
                return false
            }
            
            if httpRes.statusCode == 200 {
                if let serverMessage = String(data: data, encoding: .utf8) {
                    successMessage = "✅ \(serverMessage)"
                } else {
                    successMessage = "✅ Chef created successfully!"
                }
                return true
            } else {
                let err = String(data: data, encoding: .utf8) ?? "Unknown error"
                errorMessage = "⚠️ Failed: \(err)"
                return false
            }
        } catch {
            errorMessage = "❌ Network error: \(error.localizedDescription)"
            return false
        }
    }
}

// MARK: - ShowChef Main View
struct ShowChef: View {
    @StateObject private var viewModel = ChefViewModel()
    @State private var showingAddChef = false
    let adminUserId: Int
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Chefs...")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.center)
                } else if viewModel.chefs.isEmpty {
                    Text("No chefs found yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(viewModel.chefs) { chef in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("👨‍🍳 \(chef.name)")
                                .font(.headline)
                            if let email = chef.email {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            if !chef.specialities.isEmpty {
                                FlowLayout(items: chef.specialities, spacing: 8) { spec in
                                    Text(spec)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(10)
                                }
                            } else {
                                Text("No specialities yet.")
                                    .italic()
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Chefs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddChef = true }) {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                }
            }
            .onAppear {
                viewModel.fetchChefs(adminUserId: adminUserId)
            }
            .sheet(isPresented: $showingAddChef) {
                AddChefView(adminUserId: adminUserId, viewModel: viewModel)
            }
        }
    }
}

// MARK: - Add Chef Sheet
struct AddChefView: View {
    let adminUserId: Int
    @ObservedObject var viewModel: ChefViewModel
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var dishNames = ""
    @State private var isSubmitting = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Chef Details")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $password)
                }
                
                Section(header: Text("Specialities")) {
                    TextField("Dish names (comma separated)", text: $dishNames)
                }
                
                if let message = viewModel.successMessage ?? viewModel.errorMessage {
                    Text(message)
                        .foregroundColor(message.contains("✅") ? .green : .red)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: submitChef) {
                    HStack {
                        if isSubmitting { ProgressView() }
                        Text("Create Chef").bold()
                    }
                    .frame(maxWidth: .infinity)
                }
                .disabled(isSubmitting)
            }
            .navigationTitle("Add Chef")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func submitChef() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            viewModel.errorMessage = "⚠️ Please fill all fields."
            return
        }
        
        isSubmitting = true
        Task {
            let dishes = dishNames
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            
            let success = await viewModel.createChef(
                adminUserId: adminUserId,
                name: name,
                email: email,
                password: password,
                dishNames: dishes
            )
            
            if success {
                await MainActor.run {
                    viewModel.fetchChefs(adminUserId: adminUserId)
                    dismiss()
                }
            }
            isSubmitting = false
        }
    }
}

// MARK: - FlowLayout (Chip Wrapper)
struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: spacing)], spacing: spacing) {
            ForEach(items, id: \.self) { item in
                content(item)
            }
        }
    }
}
