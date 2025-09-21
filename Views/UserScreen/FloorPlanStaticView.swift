//import SwiftUI
//
//struct FloorPlanStaticView: View {
//    var body: some View {
//        ZStack {
//            Color.white.ignoresSafeArea()
//
//            // Stage (Top Center)
//            RoundedRectangle(cornerRadius: 8)
//                .fill(Color.purple.opacity(0.9))
//                .frame(width: 200, height: 60)
//                .overlay(Text("🎤 Stage").foregroundColor(.white).bold())
//                .position(x: 200, y: 80)
//
//            // Window (Left side vertical bar)
//            Rectangle()
//                .fill(Color.blue.opacity(0.6))
//                .frame(width: 35, height: 200)
//                .overlay(
//                    Text("🪟 🪟")
//                        .font(.largeTitle)
//                        .rotationEffect(.degrees(-0)
//                                       )
//
//                )
//                .position(x: 40, y: 250)
//
//            // Wall (Right side vertical bar)
//            Rectangle()
//                .fill(Color.gray.opacity(0.8))
//                .frame(width: 20, height: 200)
//                .overlay(
//                    Text("Wall")
//                        .foregroundColor(.black)
//                        .rotationEffect(.degrees(-90))
//                        .font(.caption2)
//                )
//                .position(x: 360, y: 250)
//
//            // Bottom row: Entrance, Stairs, Washroom
//            HStack(spacing: 60) {
//                // Entrance
//                VStack {
//                    Image(systemName: "door.left.hand.open")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 40, height: 40)
//                        .foregroundColor(.red)
//                    Text("Entrance")
//                        .font(.caption)
//                }
//
//                // Stairs
//                VStack {
//                    Image(systemName: "stairs")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 40, height: 40)
//                        .foregroundColor(.orange)
//                    Text("Stairs")
//                        .font(.caption)
//                }
//
//                // Washroom
//                VStack {
//                    Image(systemName: "toilet") // iOS 17+, otherwise use custom asset
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 40, height: 40)
//                        .foregroundColor(.green)
//                    Text("Washroom")
//                        .font(.caption)
//                }
//            }
//            .position(x: 200, y: 450)
//        }
//    }
//}
//
//struct FloorPlanStaticView_Previews: PreviewProvider {
//    static var previews: some View {
//        FloorPlanStaticView()
//    }
//}
//
//import SwiftUI
//struct FloorPlanStaticView: View {
//    let tables: [Table]
//    var onSelect: (Table) -> Void
//
//    var body: some View {
//        ZStack {
//            Color.white.ignoresSafeArea()
//
//            // Stage (Top Center)
//            RoundedRectangle(cornerRadius: 8)
//                .fill(Color.purple.opacity(0.9))
//                .frame(width: 200, height: 60)
//                .overlay(Text("🎤 Stage").foregroundColor(.white).bold())
//                .position(x: 200, y: 80)
//
//            // Window (Left side vertical bar)
//            Rectangle()
//                .fill(Color.blue.opacity(0.6))
//                .frame(width: 35, height: 200)
//                .overlay(Text("🪟").font(.largeTitle))
//                .position(x: 40, y: 250)
//
//            // Wall (Right side vertical bar)
//            Rectangle()
//                .fill(Color.gray.opacity(0.8))
//                .frame(width: 20, height: 200)
//                .overlay(Text("Wall")
//                            .foregroundColor(.black)
//                            .rotationEffect(.degrees(-90))
//                            .font(.caption2))
//                .position(x: 360, y: 250)
//
//            // Tables (dynamic placement)
//            ForEach(tables) { table in
//                Circle()
//                    .fill(table.status == "Available" ? Color.yellow : Color.gray)
//                    .frame(width: 50, height: 50)
//                    .overlay(Text(table.name).font(.caption).foregroundColor(.black))
//                    .position(positionFor(table: table)) // custom function
//                    .onTapGesture {
//                        if table.status == "Available" {
//                            onSelect(table)
//                        }
//                    }
//            }
//
//            // Bottom row: Entrance, Stairs, Washroom
//            HStack(spacing: 60) {
//                VStack {
//                    Image(systemName: "door.left.hand.open")
//                        .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.red)
//                    Text("Entrance").font(.caption)
//                }
//                VStack {
//                    Image(systemName: "stairs")
//                        .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.orange)
//                    Text("Stairs").font(.caption)
//                }
//                VStack {
//                    Image(systemName: "toilet") // requires iOS 17+
//                        .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.green)
//                    Text("Washroom").font(.caption)
//                }
//            }
//            .position(x: 200, y: 450)
//        }
//    }
//
//    // MARK: - Place tables based on location
//    private func positionFor(table: Table) -> CGPoint {
//        switch table.location.lowercased() {
//        case "stage": return CGPoint(x: 200, y: 160)
//        case "window": return CGPoint(x: 80, y: 250)
//        case "wall": return CGPoint(x: 320, y: 250)
//        default: return CGPoint(x: 200, y: 300)
//        }
//    }
//}
//
//
//import SwiftUI
//
//struct FloorPlanStaticView: View {
//    let tables: [Table]
//    var onSelect: (Table) -> Void
//
//    var body: some View {
//        ZStack {
//            Color.white.ignoresSafeArea()
//
//            // Stage (Top Center)
//            RoundedRectangle(cornerRadius: 8)
//                .fill(Color.purple.opacity(0.9))
//                .frame(width: 200, height: 60)
//                .overlay(Text("🎤 Stage").foregroundColor(.white).bold())
//                .position(x: 200, y: 80)
//
//            // Window (Left side vertical bar)
//            Rectangle()
//                .fill(Color.blue.opacity(0.6))
//                .frame(width: 35, height: 200)
//                .overlay(Text("🪟").font(.largeTitle))
//                .position(x: 40, y: 250)
//
//            // Wall (Right side vertical bar)
//            Rectangle()
//                .fill(Color.gray.opacity(0.8))
//                .frame(width: 20, height: 200)
//                .overlay(
//                    Text("Wall")
//                        .foregroundColor(.black)
//                        .rotationEffect(.degrees(-90))
//                        .font(.caption2)
//                )
//                .position(x: 360, y: 250)
//
//            // Tables (dynamic placement with spacing by location)
//            ForEach(Array(tables.enumerated()), id: \.element.id) { index, table in
//                Circle()
//                    .fill(table.status == "Available" ? Color.yellow : Color.gray)
//                    .frame(width: 50, height: 50)
//                    .overlay(Text(table.name).font(.caption).foregroundColor(.black))
//                    .position(positionFor(table: table, index: index))
//                    .onTapGesture {
//                        if table.status == "Available" {
//                            onSelect(table)
//                        }
//                    }
//            }
//
//            // Bottom row: Entrance, Stairs, Washroom
//            HStack(spacing: 60) {
//                VStack {
//                    Image(systemName: "door.left.hand.open")
//                        .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.red)
//                    Text("Entrance").font(.caption)
//                }
//                VStack {
//                    Image(systemName: "stairs")
//                        .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.orange)
//                    Text("Stairs").font(.caption)
//                }
//                VStack {
//                    Image(systemName: "toilet") // iOS 17+
//                        .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.green)
//                    Text("Washroom").font(.caption)
//                }
//            }
//            .position(x: 200, y: 450)
//        }
//    }
//
//    // MARK: - Place tables with spacing
//    private func positionFor(table: Table, index: Int) -> CGPoint {
//        // group tables by location
//        let locationTables = tables.filter { $0.location.lowercased() == table.location.lowercased() }
//        guard let idx = locationTables.firstIndex(where: { $0.id == table.id }) else {
//            return CGPoint(x: 200, y: 300)
//        }
//
//        switch table.location.lowercased() {
//        case "stage":
//            return CGPoint(x: 120 + CGFloat(idx) * 80, y: 160)
//
//        case "window":
//            return CGPoint(x: 80, y: 180 + CGFloat(idx) * 70)
//
//        case "wall":
//            return CGPoint(x: 320, y: 180 + CGFloat(idx) * 70)
//
//        default:
//            return CGPoint(x: 200 + CGFloat(idx) * 70, y: 300)
//        }
//    }
//}
//
//import SwiftUI
//
//struct FloorPlanStaticView: View {
//    let tables: [Table]
//    var onSelect: (Table) -> Void
//
//    // table size + spacing
//    private let tableSize: CGFloat = 50
//    private let spacing: CGFloat = 20
//
//    var body: some View {
//        ZStack {
//            Color.white.ignoresSafeArea()
//
//            // Stage (Top Center)
//            RoundedRectangle(cornerRadius: 8)
//                .fill(Color.purple.opacity(0.9))
//                .frame(width: 200, height: 60)
//                .overlay(Text("🎤 Stage").foregroundColor(.white).bold())
//                .position(x: 200, y: 80)
//                .padding(20)
//
//            // Window (Left side vertical bar)
//            Rectangle()
//                .fill(Color.blue.opacity(0.6))
//                .frame(width: 35, height: 200)
//                .overlay(Text("🪟").font(.largeTitle))
//                .position(x: 40, y: 250)
//
//
//            // Wall (Right side vertical bar)
//            Rectangle()
//                .fill(Color.gray.opacity(0.8))
//                .frame(width: 20, height: 200)
//                .overlay(
//                    Text("Wall")
//                        .foregroundColor(.black)
//                        .rotationEffect(.degrees(-90))
//                        .font(.caption2)
//                )
//                .position(x: 360, y: 250)
//
//            // Tables (dynamic placement with adaptive spacing)
//            ForEach(tables) { table in
//                Circle()
//                    .fill(table.status == "Available" ? Color.yellow : Color.gray)
//                    .frame(width: tableSize, height: tableSize)
//                    .overlay(Text(table.name).font(.caption).foregroundColor(.black))
//                    .position(positionFor(table: table))
//                    .onTapGesture {
//                        if table.status == "Available" {
//                            onSelect(table)
//                        }
//                    }
//            }
//
//            // Bottom row: Entrance, Stairs, Washroom
//            HStack(spacing: 60) {
//                VStack {
//                    Image(systemName: "door.left.hand.open")
//                        .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.red)
//                    Text("Entrance").font(.caption)
//                }
//                VStack {
//                    Image(systemName: "stairs")
//                        .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.orange)
//                    Text("Stairs").font(.caption)
//                }
//                VStack {
//                    Image(systemName: "toilet") // iOS 17+
//                        .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.green)
//                    Text("Washroom").font(.caption)
//                }
//            }
//            .position(x: 200, y: 450)
//        }
//    }
//
//    // MARK: - Place tables with grid layout per location
//    private func positionFor(table: Table) -> CGPoint {
//        let locationTables = tables.filter { $0.location.lowercased() == table.location.lowercased() }
//        guard let idx = locationTables.firstIndex(where: { $0.id == table.id }) else {
//            return CGPoint(x: 200, y: 300)
//        }
//
//        let columns = 3  // max per row before wrapping
//        let row = idx / columns
//        let col = idx % columns
//
//        switch table.location.lowercased() {
//        case "stage":
//            let startX: CGFloat = 100
//            let startY: CGFloat = 160
//            return CGPoint(
//                x: startX + CGFloat(col) * (tableSize + spacing),
//                y: startY + CGFloat(row) * (tableSize + spacing)
//            )
//
//        case "window":
//            let startX: CGFloat = 80
//            let startY: CGFloat = 160
//            return CGPoint(
//                x: startX,
//                y: startY + CGFloat(idx) * (tableSize + spacing)
//            )
//
//        case "wall":
//            let startX: CGFloat = 320
//            let startY: CGFloat = 160
//            return CGPoint(
//                x: startX,
//                y: startY + CGFloat(idx) * (tableSize + spacing)
//            )
//
//        default:
//            let startX: CGFloat = 150
//            let startY: CGFloat = 300
//            return CGPoint(
//                x: startX + CGFloat(col) * (tableSize + spacing),
//                y: startY + CGFloat(row) * (tableSize + spacing)
//            )
//        }
//    }
//}

//
//import SwiftUI
//
//struct FloorPlanStaticView: View {
//    let tables: [Table]
//    var onSelect: (Table) -> Void
//
//    var body: some View {
//        ScrollView { // scrollable floor plan
//            ZStack {
//                Color.white.ignoresSafeArea()
//
//                VStack(spacing: 30) {
//                    // 🎤 Stage
//                    RoundedRectangle(cornerRadius: 8)
//                        .fill(Color.purple.opacity(0.9))
//                        .frame(width: 200, height: 60)
//                        .overlay(Text("🎤 Stage").foregroundColor(.white).bold())
//
//                    HStack(alignment: .top, spacing: 40) {
//                        // 🪟 Window side (Left)
//                        VStack(spacing: 16) {
//                            Text("🪟 Window").font(.caption).bold().foregroundColor(.blue)
//                            ForEach(tables.filter { $0.location.lowercased() == "window" }) { table in
//                                tableCircle(table)
//                            }
//                        }
//                        .frame(maxWidth: 80)
//
//                        // 🍽️ Center tables (grid)
//                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
//                                  spacing: 20) {
//                            ForEach(tables.filter {
//                                !["stage", "window", "wall"].contains($0.location.lowercased())
//                            }) { table in
//                                tableCircle(table)
//                            }
//                        }
//                        .frame(maxWidth: 160)
//
//                        // 🧱 Wall side (Right)
//                        VStack(spacing: 16) {
//                            Text("🧱 Wall").font(.caption).bold().foregroundColor(.gray)
//                            ForEach(tables.filter { $0.location.lowercased() == "wall" }) { table in
//                                tableCircle(table)
//                            }
//                        }
//                        .frame(maxWidth: 80)
//                    }
//
//                    // 🚪 Entrance, Stairs, Washroom
//                    HStack(spacing: 40) {
//                        VStack {
//                            Image(systemName: "door.left.hand.open")
//                                .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.red)
//                            Text("Entrance").font(.caption)
//                        }
//                        VStack {
//                            Image(systemName: "stairs")
//                                .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.orange)
//                            Text("Stairs").font(.caption)
//                        }
//                        VStack {
//                            Image(systemName: "toilet")
//                                .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.green)
//                            Text("Washroom").font(.caption)
//                        }
//                    }
//                    .padding(.top, 30)
//                }
//                .padding()
//            }
//        }
//    }
//
//    // MARK: - Table Circle
//    private func tableCircle(_ table: Table) -> some View {
//        Circle()
//            .fill(table.status == "Available" ? Color.yellow : Color.gray)
//            .frame(width: 50, height: 50)
//            .overlay(Text(table.name).font(.caption).foregroundColor(.black))
//            .onTapGesture {
//                if table.status == "Available" {
//                    onSelect(table)
//                }
//            }
//    }
//}
//import SwiftUI
//
//struct FloorPlanStaticView: View {
//    let tables: [Table]
//    var onSelect: (Table) -> Void
//
//    var body: some View {
//        ScrollView {
//            ZStack {
//                Color.white.ignoresSafeArea()
//
//                VStack(spacing: 30) {
//                    // 🎤 Stage (Top)
//                    RoundedRectangle(cornerRadius: 8)
//                        .fill(Color.purple.opacity(0.9))
//                        .frame(width: 200, height: 60)
//                        .overlay(Text("🎤 Stage").foregroundColor(.white).bold())
//
//                    // Stage ke neeche wale tables
//                    VStack(spacing: 16) {
//                        Text("Tables near Stage")
//                            .font(.caption).bold().foregroundColor(.purple)
//                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
//                                  spacing: 20) {
//                            ForEach(tables.filter { $0.location.lowercased() == "stage" }) { table in
//                                tableCircle(table)
//                            }
//                        }
//                    }
//
//                    HStack(alignment: .top, spacing: 40) {
//                        // 🪟 Window side
//                        VStack(spacing: 16) {
//                            Text("🪟 Window")
//                                .font(.caption).bold().foregroundColor(.blue)
//                            ForEach(tables.filter { $0.location.lowercased() == "window" }) { table in
//                                tableCircle(table)
//                            }
//                        }
//                        .frame(maxWidth: 80)
//
//                        // 🍽️ Center tables (all others except stage/window/wall)
//                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
//                                  spacing: 20) {
//                            ForEach(tables.filter {
//                                !["stage", "window", "wall"].contains($0.location.lowercased())
//                            }) { table in
//                                tableCircle(table)
//                            }
//                        }
//                        .frame(maxWidth: 160)
//
//                        // 🧱 Wall side
//                        VStack(spacing: 16) {
//                            Text("🧱 Wall")
//                                .font(.caption).bold().foregroundColor(.gray)
//                            ForEach(tables.filter { $0.location.lowercased() == "wall" }) { table in
//                                tableCircle(table)
//                            }
//                        }
//                        .frame(maxWidth: 80)
//                    }
//
//                    // 🚪 Bottom section
//                    HStack(spacing: 40) {
//                        VStack {
//                            Image(systemName: "door.left.hand.open")
//                                .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.red)
//                            Text("Entrance").font(.caption)
//                        }
//                        VStack {
//                            Image(systemName: "stairs")
//                                .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.orange)
//                            Text("Stairs").font(.caption)
//                        }
//                        VStack {
//                            Image(systemName: "toilet")
//                                .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.green)
//                            Text("Washroom").font(.caption)
//                        }
//                    }
//                    .padding(.top, 30)
//                }
//                .padding()
//            }
//        }
//    }
//
//    // MARK: - Table Circle
//    private func tableCircle(_ table: Table) -> some View {
//        Circle()
//            .fill(table.status == "Available" ? Color.yellow : Color.gray)
//            .frame(width: 50, height: 50)
//            .overlay(Text(table.name).font(.caption).foregroundColor(.black))
//            .onTapGesture {
//                if table.status == "Available" {
//                    onSelect(table)
//                }
//            }
//    }
//}
//
//import SwiftUI
//
//struct FloorPlanStaticView: View {
//    let tables: [Table]
//    var onSelect: (Table) -> Void
//
//    var body: some View {
//        ScrollView {
//            ZStack {
//                Color.white.ignoresSafeArea()
//
//                VStack(spacing: 40) {
//                    // 🎤 Stage
//                    RoundedRectangle(cornerRadius: 8)
//                        .fill(Color.purple.opacity(0.9))
//                        .frame(width: 200, height: 60)
//                        .overlay(Text("🎤 Stage").foregroundColor(.white).bold())
//
//                    // 👉 Stage Tables Section
//                    if !tables.filter({ $0.location.lowercased() == "stage" }).isEmpty {
//                        VStack(spacing: 20) {
//                            Text("🎭 Stage Side Tables")
//                                .font(.headline)
//                                .foregroundColor(.purple)
//                            HStack(spacing: 20) {
//                                ForEach(tables.filter { $0.location.lowercased() == "stage" }) { table in
//                                    TableCapacityView(table: table)
//                                        .onTapGesture { onSelect(table) }
//                                }
//                            }
//                        }
//                    }
//
//                    HStack(alignment: .top, spacing: 40) {
//                        // 🪟 Window Side
//                        if !tables.filter({ $0.location.lowercased() == "window" }).isEmpty {
//                            VStack(spacing: 20) {
//                                Text("🪟 Window Side")
//                                    .font(.headline)
//                                    .foregroundColor(.blue)
//
//                                ScrollView(.vertical, showsIndicators: false) {
//                                    VStack(spacing: 20) {
//                                        ForEach(tables.filter { $0.location.lowercased() == "window" }) { table in
//                                            TableCapacityView(table: table)
//                                                .onTapGesture { onSelect(table) }
//                                        }
//                                    }
//                                    .frame(maxWidth: .infinity) // tables center aligned in column
//                                }
//                            }
//                            .frame(width: 140) // fixed column width
//                        }
//
//                        Spacer(minLength: 50) // center gap between Window & Wall
//
//                        // 🧱 Wall Side
//                        if !tables.filter({ $0.location.lowercased() == "wall" }).isEmpty {
//                            VStack(spacing: 20) {
//                                Text("🧱 Wall Side")
//                                    .font(.headline)
//                                    .foregroundColor(.gray)
//
//                                ScrollView(.vertical, showsIndicators: false) {
//                                    VStack(spacing: 20) {
//                                        ForEach(tables.filter { $0.location.lowercased() == "wall" }) { table in
//                                            TableCapacityView(table: table)
//                                                .onTapGesture { onSelect(table) }
//                                        }
//                                    }
//                                    .frame(maxWidth: .infinity)
//                                }
//                            }
//                            .frame(width: 140)
//                        }
//                    }
//                    .padding(.horizontal, 20)
//
//                    // 🚪 Bottom row
//                    HStack(spacing: 50) {
//                        VStack {
//                            Image(systemName: "door.left.hand.open")
//                                .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.red)
//                            Text("Entrance").font(.caption)
//                        }
//                        VStack {
//                            Image(systemName: "stairs")
//                                .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.orange)
//                            Text("Stairs").font(.caption)
//                        }
//                        VStack {
//                            Image(systemName: "toilet")
//                                .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.green)
//                            Text("Washroom").font(.caption)
//                        }
//                    }
//                    .padding(.top, 20)
//                }
//                .padding()
//            }
//        }
//    }
//}
//
//// Reusable table view with capacity representation
//struct TableCapacityView: View {
//    let table: Table
//
//    var body: some View {
//        VStack {
//            if table.capacity == 2 {
//                HStack {
//                    Text("🪑")
//                    Rectangle()
//                        .fill(Color.green.opacity(0.7))
//                        .frame(width: 40, height: 20)
//                    Text("🪑")
//                }
//            } else if table.capacity == 4 {
//                VStack {
//                    Text("🪑")
//                    HStack {
//                        Text("🪑")
//                        Rectangle()
//                            .fill(Color.blue.opacity(0.7))
//                            .frame(width: 60, height: 30)
//                        Text("🪑")
//                    }
//                    Text("🪑")
//                }
//            } else if table.capacity == 8 {
//                VStack(spacing: 2) {
//                    HStack {
//                        ForEach(0..<4, id: \.self) { _ in Text("🪑") }
//                    }
//                    Rectangle()
//                        .fill(Color.orange.opacity(0.7))
//                        .frame(width: 140, height: 30)
//                    HStack {
//                        ForEach(0..<4, id: \.self) { _ in Text("🪑") }
//                    }
//                }
//            }
//        }
//        .padding(4)
//        .background(RoundedRectangle(cornerRadius: 6).stroke(Color.gray))
//    }
//}
//
import SwiftUI

struct FloorPlanStaticView: View {
    let tables: [Table]
    var onSelect: (Table) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                
                // 🎤 Stage
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.purple.opacity(0.9))
                    .frame(width: 200, height: 60)
                    .overlay(Text("🎤 Stage").foregroundColor(.white).bold())
                
                // 🎭 Stage Side Tables
                if !tables.filter({ $0.location.lowercased() == "stage" }).isEmpty {
                    VStack(spacing: 20) {
                        Text("🎭 Stage Side Tables")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 30) {
                                ForEach(tables.filter { $0.location.lowercased() == "stage" }) { table in
                                    TableCapacityView(table: table)
                                        .onTapGesture { onSelect(table) }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // 🪟 Window + 🧱 Wall Side Layout
                HStack(alignment: .top, spacing: 50) {
                    
                    // 🪟 Window Side
                    if !tables.filter({ $0.location.lowercased() == "window" }).isEmpty {
                        VStack(spacing: 20) {
                            Text("🪟 Window Side")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            VStack(spacing: 25) {
                                ForEach(tables.filter { $0.location.lowercased() == "window" }) { table in
                                    TableCapacityView(table: table)
                                        .onTapGesture { onSelect(table) }
                                }
                            }
                        }
                        .frame(width: 140)
                    }
                    
                    Spacer(minLength: 50)
                    
                    // 🧱 Wall Side
                    if !tables.filter({ $0.location.lowercased() == "wall" }).isEmpty {
                        VStack(spacing: 20) {
                            Text("🧱 Wall Side")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            VStack(spacing: 25) {
                                ForEach(tables.filter { $0.location.lowercased() == "wall" }) { table in
                                    TableCapacityView(table: table)
                                        .onTapGesture { onSelect(table) }
                                }
                            }
                        }
                        .frame(width: 140)
                    }
                }
                .padding(.horizontal, 20)
                
                // 🚪 Bottom row
                HStack(spacing: 60) {
                    VStack {
                        Image(systemName: "door.left.hand.open")
                            .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.red)
                        Text("Entrance").font(.caption)
                    }
                    VStack {
                        Image(systemName: "stairs")
                            .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.orange)
                        Text("Stairs").font(.caption)
                    }
                    VStack {
                        Image(systemName: "toilet")
                            .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.green)
                        Text("Washroom").font(.caption)
                    }
                }
                .padding(.top, 20)
            }
            .padding()
        }
    }
}

// MARK: - Reusable Table Capacity View
struct TableCapacityView: View {
    let table: Table
    
    var body: some View {
        VStack(spacing: 6) {
            if table.capacity == 2 {
                HStack(spacing: 4) {
                    Text("🪑")
                    Rectangle()
                        .fill(Color.orange.opacity(0.7))
                        .frame(width: 40, height: 20)
                    Text("🪑")
                }
            } else if table.capacity == 4 {
                VStack(spacing: 4) {
                    Text("🪑")
                    HStack(spacing: 4) {
                        Text("🪑")
                        Rectangle()
                            .fill(Color.orange.opacity(0.7))
                            .frame(width: 60, height: 30)
                        Text("🪑")
                    }
                    Text("🪑")
                }
            } else if table.capacity == 8 {
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        ForEach(0..<4, id: \.self) { _ in Text("🪑") }
                    }
                    Rectangle()
                        .fill(Color.orange.opacity(0.7))
                        .frame(width: 140, height: 30)
                    HStack(spacing: 4) {
                        ForEach(0..<4, id: \.self) { _ in Text("🪑") }
                    }
                }
            }
            
            Text("Cap: \(table.capacity)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(6)
        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
    }
}
