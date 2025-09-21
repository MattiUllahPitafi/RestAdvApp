import SwiftUI

struct RestaurantCardView: View {
    var restaurant: Restaurant
    var onMenuTap: () -> Void
    var onCardTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Restaurant image
            AsyncImage(url: URL(string: restaurant.imageUrl)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(height: 160)
            .clipped()

            VStack(alignment: .leading, spacing: 6) {
                Text(restaurant.name)
                    .font(.headline)

                Text(restaurant.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(restaurant.category)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()

            // Orange menu stripe — Tappable separately
            Rectangle()
                .fill(Color.orange)
                .frame(height: 40)
                .overlay(
                    Text("View Menu")
                        .foregroundColor(.white)
                        .bold()
                )
                .onTapGesture {
                    onMenuTap()
                }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
        .onTapGesture {
            onCardTap()
        }
    }
}
