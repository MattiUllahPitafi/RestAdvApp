// AppRoute.swift
import Foundation

enum AppRoute: Hashable {
    case landing
    case login
    case signup
    case userHome
    case adminHome
    case waiterHome
    case ChefView
    case profile
    case menu(restaurantId: Int, bookingId: Int)
    case booking(restaurantId: Int)
}
