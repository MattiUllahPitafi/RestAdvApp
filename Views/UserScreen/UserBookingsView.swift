import SwiftUI

struct UserBookingsView: View {
    let bookings: [Booking]
    
    var body: some View {
        List(bookings) { booking in
            NavigationLink(destination: BookingDetailView(booking: booking)) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Restaurant: \(booking.restaurantName)")
                        .font(.headline)
                    Text("Booking Date: \(formatDate(booking.bookingDateTime))")
                        .font(.subheadline)
                    Text("Table ID: \(booking.tableId)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Status: \(booking.status)")
                        .font(.caption)
                        .foregroundColor(booking.status == "Booked" ? .green : .red)
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle("My Bookings")
    }
    
    // Reuse ISO8601 formatting
    func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}
