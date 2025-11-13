//
//  TempleService.swift
//  88trip
//
//  Created by GPT-5 Codex on 2025/11/09.
//

import Foundation
import CoreLocation

struct TempleDestinationConfig {
    let category: String
    let title: String
    let center: CLLocationCoordinate2D
    let distance: CLLocationDistance
}

struct TempleDestination: Identifiable {
    let id = UUID()
    let category: String
    let title: String
    let center: CLLocationCoordinate2D
    let distance: CLLocationDistance
    let temples: [Temple]
}

@MainActor
final class TempleService: ObservableObject {
    @Published var temples: [Temple] = []
    @Published var destinations: [TempleDestination] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseManager.shared.client
    
    private let destinationConfigs: [TempleDestinationConfig] = [
        TempleDestinationConfig(
            category: "shikoku",
            title: "四国88箇所",
            center: CLLocationCoordinate2D(latitude: 33.8417, longitude: 133.5500),
            distance: 1_250_000
        ),
        TempleDestinationConfig(
            category: "kyoto",
            title: "京都",
            center: CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681),
            distance: 1_250_000
        ),
        TempleDestinationConfig(
            category: "shodoshima",
            title: "小豆島",
            center: CLLocationCoordinate2D(latitude: 34.4830, longitude: 134.2830),
            distance: 300_000
        )
    ]
    
    func loadTemples() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetched: [Temple] = try await supabase
                .from("temples")
                .select()
                .order("name")
                .execute()
                .value
            
            temples = fetched
            destinations = buildDestinations(from: fetched)
        } catch {
            errorMessage = "お寺情報の取得に失敗しました: \(error.localizedDescription)"
            temples = []
            destinations = []
        }
        
        isLoading = false
    }
    
    private func buildDestinations(from temples: [Temple]) -> [TempleDestination] {
        guard !temples.isEmpty else { return [] }
        
        let grouped = Dictionary(grouping: temples) { temple in
            (temple.category?.lowercased() ?? "その他")
        }
        
        var result: [TempleDestination] = []
        
        for config in destinationConfigs {
            guard let group = grouped[config.category], !group.isEmpty else { continue }
            result.append(
                TempleDestination(
                    category: config.category,
                    title: config.title,
                    center: config.center,
                    distance: config.distance,
                    temples: group
                )
            )
        }
        
        for (category, group) in grouped {
            guard !destinationConfigs.contains(where: { $0.category == category }) else { continue }
            guard let center = centroidCoordinate(for: group) else { continue }
            
            let title = categoryTitle(for: category)
            result.append(
                TempleDestination(
                    category: category,
                    title: title,
                    center: center,
                    distance: defaultDistance(for: group),
                    temples: group
                )
            )
        }
        
        return result.sorted { $0.title < $1.title }
    }
    
    private func centroidCoordinate(for temples: [Temple]) -> CLLocationCoordinate2D? {
        let coordinates = temples.compactMap { temple -> CLLocationCoordinate2D? in
            guard let lat = temple.latitude, let lon = temple.longitude else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        
        guard !coordinates.isEmpty else { return nil }
        
        let avgLat = coordinates.map(\.latitude).reduce(0.0, +) / Double(coordinates.count)
        let avgLon = coordinates.map(\.longitude).reduce(0.0, +) / Double(coordinates.count)
        
        return CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon)
    }
    
    private func defaultDistance(for temples: [Temple]) -> CLLocationDistance {
        // 対象の範囲が広いほど距離を大きくする簡易ロジック
        let coordinates = temples.compactMap { temple -> CLLocation? in
            guard let lat = temple.latitude, let lon = temple.longitude else { return nil }
            return CLLocation(latitude: lat, longitude: lon)
        }
        
        guard coordinates.count >= 2 else {
            return 300_000
        }
        
        var maxDistance: CLLocationDistance = 0
        for i in 0..<coordinates.count {
            for j in i+1..<coordinates.count {
                maxDistance = max(maxDistance, coordinates[i].distance(from: coordinates[j]))
            }
        }
        
        return max(300_000, min(maxDistance * 1.5, 1_500_000))
    }
    
    private func categoryTitle(for category: String) -> String {
        switch category {
        case "shikoku":
            return "四国88箇所"
        case "kyoto":
            return "京都"
        case "shodoshima":
            return "小豆島"
        default:
            return category.capitalized
        }
    }
}


