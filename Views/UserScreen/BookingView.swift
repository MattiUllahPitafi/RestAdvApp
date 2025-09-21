//trying floorplan
import SwiftUI

struct MusicItem: Identifiable, Codable {
    let id: Int
    let title: String
    let artist: String
    let genreName: String

    enum CodingKeys: String, CodingKey {
        case id = "musicId"
        case title
        case artist
        case genreName
    }
}

struct BookingResponse: Codable {
    let bookingId: Int
    let message: String
}


struct BookingView: View {
    let restaurantId: Int
    @Binding var path: NavigationPath
    @EnvironmentObject var userVM: UserViewModel

    @State private var selectedDate = Date()
    @State private var tables: [Table] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedTable: Table?

    // Music
    @State private var musicList: [MusicItem] = []
    @State private var selectedMusicId: Int?
    @State private var musicLoading = false
    @State private var musicErrorMessage: String?
    @State private var showMusicList = false

    // Coin categories
    let coinCategories = [
        (id: 1, name: "Gold"),
        (id: 2, name: "Diamond"),
        (id: 3, name: "Platinum")
    ]
    @State private var selectedCoinCategoryId: Int?

    // Booking
    @State private var specialRequest = ""
    @State private var isBooking = false
    @State private var bookingMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            if selectedTable == nil {
                DatePicker("Select Booking Time", selection: $selectedDate)
                    .datePickerStyle(.compact)
                    .padding(.horizontal)
                
                Button("Check Availability") {
                    fetchTables(for: selectedDate)
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
                
                if isLoading {
                    ProgressView("Loading tables...")
                } else if let error = errorMessage {
                    Text("Error: \(error)").foregroundColor(.red)
                } else {
                    FloorPlanStaticView(
                        tables: tables,
                        onSelect: { table in
                            if table.status == "Available" {
                                selectedTable = table
                            }
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // ✅ only here
                }

            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Booking Details").font(.title2).bold()
                    
                    Text("Table: \(selectedTable!.name)")
                    Text("Location: \(selectedTable!.location)")
                    Text("Person: \(selectedTable!.capacity)")
                    Text("Price: \(selectedTable!.price, specifier: "%.0f") PKR")
                    
                    DatePicker("Booking Date & Time", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    
                    TextField("Special Request", text: $specialRequest)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Toggle("Add Music", isOn: $showMusicList)
                        .onChange(of: showMusicList) { value in
                            if value && musicList.isEmpty {
                                fetchMusicList()
                            }
                        }
                    
                    if showMusicList {
                        if musicLoading {
                            ProgressView("Loading music...")
                        } else if let error = musicErrorMessage {
                            Text(error).foregroundColor(.red)
                        } else {
                            Picker("Select Music", selection: $selectedMusicId) {
                                Text("None").tag(nil as Int?)
                                ForEach(musicList) { music in
                                    Text("\(music.title) - \(music.artist)").tag(music.id as Int?)
                                }
                            }
                            .pickerStyle(.wheel)
                            
                            if selectedMusicId != nil {
                                Picker("Coin Category", selection: $selectedCoinCategoryId) {
                                    Text("Select Coin").tag(nil as Int?)
                                    ForEach(coinCategories, id: \.id) { coin in
                                        Text(coin.name).tag(coin.id as Int?)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    }
                    
                    VStack {
                        Button(action: confirmBooking) {
                            HStack {
                                if isBooking {
                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                Text(isBooking ? "Booking..." : "Confirm Booking")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isBooking || userVM.user?.userId == nil ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                            .animation(.easeInOut, value: isBooking)
                        }
                        .disabled(isBooking || userVM.user?.userId == nil)
                        if let message = bookingMessage {
                            Text(message)
                                .foregroundColor(.green)
                                .padding(.top)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Book Table")
    }

    // MARK: - Fetch Tables
    private func fetchTables(for date: Date) {
        isLoading = true
        errorMessage = nil

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        let dateString = isoFormatter.string(from: date)

        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/tables/available/\(restaurantId)?datetime=\(dateString)") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = "Error: \(error.localizedDescription)"
                    return
                }
                guard let data = data else {
                    errorMessage = "No data received"
                    return
                }
                do {
                    tables = try JSONDecoder().decode([Table].self, from: data)
                } catch {
                    errorMessage = "Failed to decode tables: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    // MARK: - Fetch Music
    private func fetchMusicList() {
        musicLoading = true
        musicErrorMessage = nil

        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/Music/getall") else {
            musicErrorMessage = "Invalid URL"
            musicLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                musicLoading = false
                if let error = error {
                    musicErrorMessage = "Error: \(error.localizedDescription)"
                    return
                }
                guard let data = data else {
                    musicErrorMessage = "No data received"
                    return
                }
                do {
                    musicList = try JSONDecoder().decode([MusicItem].self, from: data)
                } catch {
                    musicErrorMessage = "Failed to decode music: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    // MARK: - Confirm Booking
    private func confirmBooking() {
        guard let userId = userVM.user?.userId else {
            bookingMessage = "⚠️ Please log in first."
            return
        }
        guard let table = selectedTable else {
            bookingMessage = "⚠️ Please select a table."
            return
        }

        isBooking = true
        bookingMessage = nil

        let bookingRequest: [String: Any?] = [
            "userId": userId,
            "tableId": table.tableId,
            "bookingDateTime": ISO8601DateFormatter().string(from: selectedDate),
            "specialRequest": specialRequest,
            "status": "AutoBooked",
            "restaurantId": restaurantId,
            "musicId": selectedMusicId,
            "coinCategoryId": selectedCoinCategoryId
        ]

        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/Bookings/create") else {
            bookingMessage = "Invalid URL"
            isBooking = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bookingRequest.compactMapValues { $0 })
        } catch {
            bookingMessage = "Failed to encode booking"
            isBooking = false
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isBooking = false
                if let error = error {
                    bookingMessage = "Error: \(error.localizedDescription)"
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    bookingMessage = "No response from server"
                    return
                }

                if httpResponse.statusCode == 200 {
                    bookingMessage = "✅ Booking confirmed successfully!"
                    if let data = data,
                       let bookingResponse = try? JSONDecoder().decode(BookingResponse.self, from: data) {
                        path.append(AppRoute.menu(
                            restaurantId: restaurantId,
                            bookingId: bookingResponse.bookingId
                        ))
                    }
                } else {
                    bookingMessage = "Failed to confirm booking (Status: \(httpResponse.statusCode))"
                }
            }
        }.resume()
    }
}

//import SwiftUI
//
//struct MusicItem: Identifiable, Codable {
//    let id: Int
//    let title: String
//    let artist: String
//    let genreName: String
//
//    enum CodingKeys: String, CodingKey {
//        case id = "musicId"
//        case title
//        case artist
//        case genreName
//    }
//}
//
//struct BookingResponse: Codable {
//    let bookingId: Int
//    let message: String
//}
//
//struct BookingView: View {
//    let restaurantId: Int
//    @Binding var path: NavigationPath
//    @EnvironmentObject var userVM: UserViewModel
//
//    @State private var selectedDate = Date()
//    @State private var tables: [Table] = []
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//    @State private var selectedTable: Table?
//
//    // Music
//    @State private var musicList: [MusicItem] = []
//    @State private var selectedMusicId: Int?
//    @State private var musicLoading = false
//    @State private var musicErrorMessage: String?
//    @State private var showMusicList = false
//
//    // Coin categories
//    let coinCategories = [
//        (id: 1, name: "Gold"),
//        (id: 2, name: "Diamond"),
//        (id: 3, name: "Platinum")
//    ]
//    @State private var selectedCoinCategoryId: Int?
//
//    // Booking
//    @State private var specialRequest = ""
//    @State private var isBooking = false
//    @State private var bookingMessage: String?
//
//    var body: some View {
//        VStack(spacing: 16) {
//            if selectedTable == nil {
//                DatePicker("Select Booking Time", selection: $selectedDate)
//                    .datePickerStyle(.compact)
//                    .padding(.horizontal)
//
//                Button("Check Availability") {
//                    fetchTables(for: selectedDate)
//                }
//                .buttonStyle(.borderedProminent)
//                .padding(.bottom)
//
//                if isLoading {
//                    ProgressView("Loading tables...")
//                } else if let error = errorMessage {
//                    Text("Error: \(error)").foregroundColor(.red)
//                } else {
//                    ScrollView {
//                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
//                            ForEach(tables) { table in
//                                VStack {
//                                    Text(table.name)
//                                        .font(.headline)
//                                        .foregroundColor(.white)
//                                    Text(table.location)
//                                        .font(.caption).bold()
//                                        .foregroundColor(.black.opacity(0.8))
//                                    Text("\(table.price, specifier: "%.0f") PKR")
//                                        .font(.caption2)
//                                        .foregroundColor(.white.opacity(0.7))
//                                }
//                                .padding()
//                                .frame(maxWidth: .infinity)
//                                .background(table.status == "Available" ? Color.yellow : Color.gray)
//                                .cornerRadius(10)
//                                .onTapGesture {
//                                    if table.status == "Available" {
//                                        selectedTable = table
//                                    }
//                                }
//                            }
//                        }
//                        .padding()
//                    }
//                }
//            } else {
//                VStack(alignment: .leading, spacing: 16) {
//                    Text("Booking Details").font(.title2).bold()
//
//                    Text("Table: \(selectedTable!.name)")
//                    Text("Location: \(selectedTable!.location)")
//                    Text("Person: \(selectedTable!.capacity)")
//                    Text("Price: \(selectedTable!.price, specifier: "%.0f") PKR")
//
//                    DatePicker("Booking Date & Time", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
//
//                    TextField("Special Request", text: $specialRequest)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//
//                    Toggle("Add Music", isOn: $showMusicList)
//                        .onChange(of: showMusicList) { value in
//                            if value && musicList.isEmpty {
//                                fetchMusicList()
//                            }
//                        }
//
//                    if showMusicList {
//                        if musicLoading {
//                            ProgressView("Loading music...")
//                        } else if let error = musicErrorMessage {
//                            Text(error).foregroundColor(.red)
//                        } else {
//                            Picker("Select Music", selection: $selectedMusicId) {
//                                Text("None").tag(nil as Int?)
//                                ForEach(musicList) { music in
//                                    Text("\(music.title) - \(music.artist)").tag(music.id as Int?)
//                                }
//                            }
//                            .pickerStyle(.wheel)
//
//                            if selectedMusicId != nil {
//                                Picker("Coin Category", selection: $selectedCoinCategoryId) {
//                                    Text("Select Coin").tag(nil as Int?)
//                                    ForEach(coinCategories, id: \.id) { coin in
//                                        Text(coin.name).tag(coin.id as Int?)
//                                    }
//                                }
//                                .pickerStyle(.segmented)
//                            }
//                        }
//                    }
//                    VStack{
//                        Button(action: confirmBooking) {
//                            HStack {
//                                if isBooking {
//                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
//                                }
//                                Text(isBooking ? "Booking..." : "Confirm Booking")
//                                    .fontWeight(.semibold)
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(isBooking || userVM.user?.userId == nil ? Color.gray : Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(12)
//                            .shadow(radius: 4)
//                            .animation(.easeInOut, value: isBooking)
//                        }
//                        .disabled(isBooking || userVM.user?.userId == nil)
//                        if let message = bookingMessage {
//                            Text(message)
//                                .foregroundColor(.green)
//                                .padding(.top)
//                        }
//
//                    }
//
//                    .padding()
//                }
//            }
//        }
//        .navigationTitle("Book Table")
//    }
//
//    // MARK: - Fetch Tables
//    private func fetchTables(for date: Date) {
//        isLoading = true
//        errorMessage = nil
//
//        let isoFormatter = ISO8601DateFormatter()
//        isoFormatter.formatOptions = [.withInternetDateTime]
//        let dateString = isoFormatter.string(from: date)
//
//        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/tables/available/\(restaurantId)?datetime=\(dateString)") else {
//            errorMessage = "Invalid URL"
//            isLoading = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            DispatchQueue.main.async {
//                isLoading = false
//                if let error = error {
//                    errorMessage = "Error: \(error.localizedDescription)"
//                    return
//                }
//                guard let data = data else {
//                    errorMessage = "No data received"
//                    return
//                }
//                do {
//                    tables = try JSONDecoder().decode([Table].self, from: data)
//                } catch {
//                    errorMessage = "Failed to decode tables: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//
//    // MARK: - Fetch Music
//    private func fetchMusicList() {
//        musicLoading = true
//        musicErrorMessage = nil
//
//        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/Music/getall") else {
//            musicErrorMessage = "Invalid URL"
//            musicLoading = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            DispatchQueue.main.async {
//                musicLoading = false
//                if let error = error {
//                    musicErrorMessage = "Error: \(error.localizedDescription)"
//                    return
//                }
//                guard let data = data else {
//                    musicErrorMessage = "No data received"
//                    return
//                }
//                do {
//                    musicList = try JSONDecoder().decode([MusicItem].self, from: data)
//                } catch {
//                    musicErrorMessage = "Failed to decode music: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//
//    // MARK: - Confirm Booking
//    private func confirmBooking() {
//        guard let userId = userVM.user?.userId else {
//            bookingMessage = "⚠️ Please log in first."
//            return
//        }
//        guard let table = selectedTable else {
//            bookingMessage = "⚠️ Please select a table."
//            return
//        }
//
//        isBooking = true
//        bookingMessage = nil
//
//        let bookingRequest: [String: Any?] = [
//            "userId": userId,
//            "tableId": table.tableId,
//            "bookingDateTime": ISO8601DateFormatter().string(from: selectedDate),
//            "specialRequest": specialRequest,
//            "status": "AutoBooked",
//            "restaurantId": restaurantId,
//            "musicId": selectedMusicId,
//            "coinCategoryId": selectedCoinCategoryId
//        ]
//
//        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/Bookings/create") else {
//            bookingMessage = "Invalid URL"
//            isBooking = false
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: bookingRequest.compactMapValues { $0 })
//        } catch {
//            bookingMessage = "Failed to encode booking"
//            isBooking = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                isBooking = false
//                if let error = error {
//                    bookingMessage = "Error: \(error.localizedDescription)"
//                    return
//                }
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    bookingMessage = "No response from server"
//                    return
//                }
//
//                if httpResponse.statusCode == 200 {
//                    bookingMessage = "✅ Booking confirmed successfully!"
//                    if let data = data,
//                       let bookingResponse = try? JSONDecoder().decode(BookingResponse.self, from: data) {
//                        path.append(AppRoute.menu(
//                            restaurantId: restaurantId,
//                            bookingId: bookingResponse.bookingId
//                        ))
//                    }
//                } else {
//                    bookingMessage = "Failed to confirm booking (Status: \(httpResponse.statusCode))"
//                }
//            }
//        }.resume()
//    }
//}

//import SwiftUI
//
//struct MusicItem: Identifiable, Codable {
//    let id: Int
//    let title: String
//    let artist: String
//    let genreName: String
//
//    enum CodingKeys: String, CodingKey {
//        case id = "musicId"
//        case title
//        case artist
//        case genreName
//    }
//}
//
//struct BookingResponse: Codable {
//    let bookingId: Int
//    let message: String
//}
//
//struct BookingView: View {
//    let restaurantId: Int
//    @Binding var path: NavigationPath
//    @EnvironmentObject var userVM: UserViewModel
//
//    @State private var selectedDate = Date()
//    @State private var tables: [Table] = []
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//    @State private var selectedTable: Table?
//
//    // Music
//    @State private var musicList: [MusicItem] = []
//    @State private var selectedMusicId: Int?
//    @State private var musicLoading = false
//    @State private var musicErrorMessage: String?
//    @State private var showMusicList = false
//
//    // Coin categories
//    let coinCategories = [
//        (id: 1, name: "Gold"),
//        (id: 2, name: "Diamond"),
//        (id: 3, name: "Platinum")
//    ]
//    @State private var selectedCoinCategoryId: Int?
//
//    // Booking
//    @State private var specialRequest = ""
//    @State private var isBooking = false
//    @State private var bookingMessage: String?
//
//    var body: some View {
//        VStack(spacing: 16) {
//            if selectedTable == nil {
//                // Table selection flow
//                DatePicker("Select Booking Time", selection: $selectedDate)
//                    .datePickerStyle(.compact)
//                    .padding(.horizontal)
//
//                Button("Check Availability") {
//                    fetchTables(for: selectedDate)
//                }
//                .buttonStyle(.borderedProminent)
//                .padding(.bottom)
//
//                if isLoading {
//                    ProgressView("Loading tables...")
//                } else if let error = errorMessage {
//                    Text("Error: \(error)").foregroundColor(.red)
//                } else {
//                    ScrollView {
//                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
//                            ForEach(tables) { table in
//                                VStack {
//                                    Text(table.name)
//                                        .font(.headline)
//                                        .foregroundColor(.white)
//                                    Text(table.location)
//                                        .font(.caption).bold()
//                                        .foregroundColor(.black.opacity(0.8))
//                                    Text("\(table.price, specifier: "%.0f") PKR")
//                                        .font(.caption2)
//                                        .foregroundColor(.white.opacity(0.7))
//                                }
//                                .padding()
//                                .frame(maxWidth: .infinity)
//                                .background(table.status == "Available" ? Color.yellow : Color.gray)
//                                .cornerRadius(10)
//                                .onTapGesture {
//                                    if table.status == "Available" {
//                                        selectedTable = table
//                                    }
//                                }
//                            }
//                        }
//                        .padding()
//                    }
//                }
//            } else {
//                // Booking details form
//                VStack(alignment: .leading, spacing: 16) {
//                    Text("Booking Details")
//                        .font(.title2).bold()
//
//                    Text("Table: \(selectedTable!.name)")
//                    Text("Location: \(selectedTable!.location)")
//                    Text("Person: \(selectedTable!.capacity)")
//                    Text("Price: \(selectedTable!.price, specifier: "%.0f") PKR")
//
//                    DatePicker("Booking Date & Time", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
//
//                    TextField("Special Request", text: $specialRequest)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//
//                    Toggle("Add Music", isOn: $showMusicList)
//                        .onChange(of: showMusicList) { value in
//                            if value && musicList.isEmpty {
//                                fetchMusicList()
//                            }
//                        }
//
//                    if showMusicList {
//                        if musicLoading {
//                            ProgressView("Loading music...")
//                        } else if let error = musicErrorMessage {
//                            Text(error).foregroundColor(.red)
//                        } else {
//                            Picker("Select Music", selection: $selectedMusicId) {
//                                Text("None").tag(nil as Int?)
//                                ForEach(musicList) { music in
//                                    Text("\(music.title) - \(music.artist)").tag(music.id as Int?)
//                                }
//                            }
//                            .pickerStyle(.wheel)
//
//                            if selectedMusicId != nil {
//                                Picker("Coin Category", selection: $selectedCoinCategoryId) {
//                                    Text("Select Coin").tag(nil as Int?)
//                                    ForEach(coinCategories, id: \.id) { coin in
//                                        Text(coin.name).tag(coin.id as Int?)
//                                    }
//                                }
//                                .pickerStyle(.segmented)
//                            }
//                        }
//                    }
//
//                    Button(action: confirmBooking) {
//                        HStack {
//                            if isBooking {
//                                ProgressView()
//                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                            }
//                            Text(isBooking ? "Booking..." : "Confirm Booking")
//                                .fontWeight(.semibold)
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(isBooking || userVM.user?.userId == nil ? Color.gray : Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(12)
//                        .shadow(radius: 4)
//                        .animation(.easeInOut, value: isBooking)
//                    }
//                    .disabled(isBooking || userVM.user?.userId == nil)
//
////                    if let message = bookingMessage as String? {
////                        Text(message)
////                            .foregroundColor(.green)
////                            .padding(.top)
////                    }
//                }
//                .padding()
//            }
//        }
//        .navigationTitle("Book Table")
//    }
//
//    // MARK: - Fetch Tables
//    private func fetchTables(for date: Date) {
//        isLoading = true
//        errorMessage = nil
//
//        let isoFormatter = ISO8601DateFormatter()
//        isoFormatter.formatOptions = [.withInternetDateTime]
//        let dateString = isoFormatter.string(from: date)
//
//        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/tables/available/\(restaurantId)?datetime=\(dateString)") else {
//            errorMessage = "Invalid URL"
//            isLoading = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            DispatchQueue.main.async {
//                isLoading = false
//                if let error = error {
//                    errorMessage = "Error: \(error.localizedDescription)"
//                    return
//                }
//                guard let data = data else {
//                    errorMessage = "No data received"
//                    return
//                }
//                do {
//                    tables = try JSONDecoder().decode([Table].self, from: data)
//                } catch {
//                    errorMessage = "Failed to decode tables: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//
//    // MARK: - Fetch Music
//    private func fetchMusicList() {
//        musicLoading = true
//        musicErrorMessage = nil
//
//        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/Music/getall") else {
//            musicErrorMessage = "Invalid URL"
//            musicLoading = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            DispatchQueue.main.async {
//                musicLoading = false
//                if let error = error {
//                    musicErrorMessage = "Error: \(error.localizedDescription)"
//                    return
//                }
//                guard let data = data else {
//                    musicErrorMessage = "No data received"
//                    return
//                }
//                do {
//                    musicList = try JSONDecoder().decode([MusicItem].self, from: data)
//                } catch {
//                    musicErrorMessage = "Failed to decode music: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//
//    // MARK: - Confirm Booking
//    private func confirmBooking() {
//        guard let userId = userVM.user?.userId else {
//            bookingMessage = "⚠️ Please log in first."
//            return
//        }
//
//        guard let table = selectedTable else {
//            bookingMessage = "⚠️ Please select a table."
//            return
//        }
//
//        isBooking = true
//        bookingMessage = nil
//
//        let bookingRequest: [String: Any?] = [
//            "userId": userId,
//            "tableId": table.tableId,
//            "bookingDateTime": ISO8601DateFormatter().string(from: selectedDate),
//            "specialRequest": specialRequest,
//            "status": "AutoBooked",
//            "restaurantId": restaurantId,
//            "musicId": selectedMusicId,
//            "coinCategoryId": selectedCoinCategoryId
//        ]
//
//        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/Bookings/create") else {
//            bookingMessage = "Invalid URL"
//            isBooking = false
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: bookingRequest.compactMapValues { $0 })
//        } catch {
//            bookingMessage = "Failed to encode booking"
//            isBooking = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                isBooking = false
//                if let error = error {
//                    bookingMessage = "Error: \(error.localizedDescription)"
//                    return
//                }
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    bookingMessage = "No response from server"
//                    return
//                }
//
//                if httpResponse.statusCode == 200 {
//                    bookingMessage = "✅ Booking confirmed successfully!"
//
//                    if let data = data,
//                       let bookingResponse = try? JSONDecoder().decode(BookingResponse.self, from: data),
//                       let userId = userVM.user?.userId {
//
//                        // Navigate using a route (not the view itself)
//                        path.append(AppRoute.menu(
//                            restaurantId: restaurantId,
//                            bookingId: bookingResponse.bookingId,
//                            userId: userId
//                        ))
//
//                    }
//                }
// else {
//                    bookingMessage = "Failed to confirm booking (Status: \(httpResponse.statusCode))"
//                }
//            }
//        }.resume()
//    }
//}

//import SwiftUI
//
//struct BookingView: View {
//    let restaurantId: Int
//    @EnvironmentObject var userVM: UserViewModel
//
//    @State private var tables: [RestaurantTable] = []
//    @State private var selectedTableId: Int?
//    @State private var bookingDate = Date()
//    @State private var specialRequest = ""
//    @State private var isLoading = true
//    @State private var errorMessage: String?
//    @State private var successMessage: String?
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Book a Table")
//                .font(.title)
//                .fontWeight(.bold)
//
//            if isLoading {
//                ProgressView("Loading tables...")
//            } else if let error = errorMessage {
//                Text(error)
//                    .foregroundColor(.red)
//            } else {
//                Picker("Select a Table", selection: $selectedTableId) {
//                    ForEach(tables, id: \.tableId) { table in
//                        Text("Table #\(table.tableId) - \(table.location) - \(table.price, specifier: "%.0f") coins")
//                            .tag(Optional(table.tableId)) // ✅ fixed binding issue
//                    }
//                }
//                .pickerStyle(.wheel)
//
//                DatePicker("Select Date & Time", selection: $bookingDate, displayedComponents: [.date, .hourAndMinute])
//                    .padding()
//
//                TextField("Special Request", text: $specialRequest)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//
//                Button(action: confirmBooking) {
//                    Text("Confirm Booking")
//                        .frame(maxWidth: .infinity)
//                    #imageLiteral(resourceName: "Screenshot 2025-09-02 at 1.58.07 PM.png")                  .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//
//                if let success = successMessage {
//                    Text(success)
//                        .foregroundColor(.green)
//                }
//            }
//
//            Spacer()
//        }
//        .padding()
//        .onAppear(perform: fetchTables)
//    }
//
//    // ✅ Fetch available tables
//    private func fetchTables() {
//        guard let url = URL(string: "http://localhost:5241/api/Tables/byrestaurant/\(restaurantId)") else {
//            errorMessage = "Invalid URL"
//            isLoading = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            DispatchQueue.main.async {
//                isLoading = false
//                if let error = error {
//                    errorMessage = "Error: \(error.localizedDescription)"
//                    return
//                }
//
//                guard let data = data else {
//                    errorMessage = "No data received"
//                    return
//                }
//
//                do {
//                    let decoded = try JSONDecoder().decode([RestaurantTable].self, from: data)
//                    tables = decoded
//                    if !tables.isEmpty {
//                        selectedTableId = tables.first?.tableId
//                    }
//                } catch {
//                    errorMessage = "Failed to decode tables: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//
//    // ✅ Confirm booking
//    private func confirmBooking() {
//        guard let selectedTableId = selectedTableId,
//              let userId = userVM.user?.userId else { // ✅ fixed userId access
//            errorMessage = "Please select a table and make sure you are logged in."
//            return
//        }
//
//        let bookingRequest = BookingRequest(
//            userId: userId,
//            tableId: selectedTableId,
//            bookingDateTime: bookingDate,
//            specialRequest: specialRequest,
//            status: "AutoBooked",
//            restaurantId: restaurantId
//        )
//
//        guard let url = URL(string: "http://localhost:5241/api/Bookings/create") else {
//            errorMessage = "Invalid URL"
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            request.httpBody = try JSONEncoder().encode(bookingRequest)
//        } catch {
//            errorMessage = "Failed to encode booking: \(error.localizedDescription)"
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { _, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    errorMessage = "Error: \(error.localizedDescription)"
//                    return
//                }
//
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    errorMessage = "No response from server"
//                    return
//                }
//
//                if httpResponse.statusCode == 200 {
//                    successMessage = "✅ Booking confirmed successfully!"
//                } else {
//                    errorMessage = "Failed to confirm booking (Status: \(httpResponse.statusCode))"
//                }
//            }
//        }.resume()
//    }
//}

//import SwiftUI
//
//struct MusicItem: Identifiable, Codable {
//    let id: Int
//    let title: String
//    let artist: String
//    let genreName: String
//
//    enum CodingKeys: String, CodingKey {
//        case id = "musicId"
//        case title
//        case artist
//        case genreName
//    }
//}
//struct BookingResponse: Codable {
//    let bookingId: Int
//    let message: String
//}
//
//
//struct BookingView: View {
//    let restaurantId: Int
//    @Binding var path: NavigationPath
//    @EnvironmentObject var userVM: UserViewModel
//
//    @State private var selectedDate = Date()
//    @State private var tables: [Table] = []
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//    @State private var selectedTable: Table?
//
//    // Music
//    @State private var musicList: [MusicItem] = []
//    @State private var selectedMusicId: Int?
//    @State private var musicLoading = false
//    @State private var musicErrorMessage: String?
//    @State private var showMusicList = false
//
//    // Coin categories
//    let coinCategories = [
//        (id: 1, name: "Gold"),
//        (id: 2, name: "Diamond"),
//        (id: 3, name: "Platinum")
//    ]
//    @State private var selectedCoinCategoryId: Int?
//
//    // Booking status
//    @State private var specialRequest = ""
//    @State private var isBooking = false
//    @State private var bookingMessage: String?
//
//    var body: some View {
//        VStack(spacing: 16) {
//            if selectedTable == nil {
//                DatePicker("Select Booking Time", selection: $selectedDate)
//                    .datePickerStyle(.compact)
//                    .padding(.horizontal)
//
//                Button("Check Availability") {
//                    fetchTables(for: selectedDate)
//                }
//                .buttonStyle(.borderedProminent)
//                .padding(.bottom)
//
//                if isLoading {
//                    ProgressView("Loading tables...")
//                } else if let error = errorMessage {
//                    Text("Error: \(error)").foregroundColor(.red)
//                } else {
//                    ScrollView {
//                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
//                            ForEach(tables) { table in
//                                VStack {
//                                    Text(table.name)
//                                        .font(.headline)
//                                        .foregroundColor(.white)
//                                    Text(table.location)
//                                        .font(.caption).bold()
//                                        .foregroundColor(.black.opacity(0.8))
//                                    Text("\(table.price, specifier: "%.0f") PKR")
//                                        .font(.caption2)
//                                        .foregroundColor(.white.opacity(0.7))
//                                }
//                                .padding()
//                                .frame(maxWidth: .infinity)
//                                .background(table.status == "Available" ? Color.orange : Color.gray)
//                                .cornerRadius(10)
//                                .onTapGesture {
//                                    if table.status == "Available" {
//                                        selectedTable = table
//                                    }
//                                }
//                            }
//                        }
//                        .padding()
//                    }
//                }
//            } else {
//                VStack(alignment: .leading, spacing: 16) {
//                    Text("Booking Details")
//                        .font(.title2).bold()
//
//                    Text("Table: \(selectedTable!.name)")
//                    Text("Location: \(selectedTable!.location)")
//                    Text("Price: \(selectedTable!.price, specifier: "%.0f") PKR")
//                    DatePicker("Booking Date & Time", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
//
//                    TextField("Special Request", text: $specialRequest)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//
//                    Toggle("Add Music", isOn: $showMusicList)
//                        .onChange(of: showMusicList) { value in
//                            if value && musicList.isEmpty {
//                                fetchMusicList()
//                            }
//                        }
//
//                    if showMusicList {
//                        if musicLoading {
//                            ProgressView("Loading music...")
//                        } else if let error = musicErrorMessage {
//                            Text(error).foregroundColor(.red)
//                        } else {
//                            Picker("Select Music", selection: $selectedMusicId) {
//                                Text("None").tag(nil as Int?)
//                                ForEach(musicList) { music in
//                                    Text("\(music.title) - \(music.artist)").tag(music.id as Int?)
//                                }
//                            }
//                            .pickerStyle(.wheel)
//
//                            if selectedMusicId != nil {
//                                Picker("Coin Category", selection: $selectedCoinCategoryId) {
//                                    Text("Select Coin").tag(nil as Int?)
//                                    ForEach(coinCategories, id: \.id) { coin in
//                                        Text(coin.name).tag(coin.id as Int?)
//                                    }
//                                }
//                                .pickerStyle(.segmented)
//                            }
//                        }
//                    }
//
//                    Button(action: confirmBooking) {
//                        Text(isBooking ? "Booking..." : "Confirm Booking")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                    .disabled(isBooking || userVM.loggedInUserId == nil)
//
//                    if let message = bookingMessage {
//                        Text(message)
//                            .foregroundColor(.green)
//                    }
//                }
//                .padding()
//            }
//        }
//        .navigationTitle("Book Table")
//    }
//
