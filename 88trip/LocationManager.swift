//
//  LocationManager.swift
//  88trip
//
//  Created by user on 2025/10/11.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // 10メートル移動したら更新
    }
    
    // 位置情報の使用許可をリクエスト
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // 位置情報の取得を開始
    func startUpdatingLocation() {
        isLoading = true
        locationManager.startUpdatingLocation()
    }
    
    // 位置情報の取得を停止
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        isLoading = false
    }
    
    // 現在地を1回だけ取得
    func requestCurrentLocation() {
        isLoading = true
        locationManager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    // 位置情報が更新されたとき
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        isLoading = false
        print("📍 位置情報取得成功: 緯度 \(location.coordinate.latitude), 経度 \(location.coordinate.longitude)")
    }
    
    // 位置情報の取得に失敗したとき
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        errorMessage = "位置情報の取得に失敗しました: \(error.localizedDescription)"
        print("❌ 位置情報取得エラー: \(error)")
    }
    
    // 位置情報の許可状態が変更されたとき
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .notDetermined:
            print("📍 位置情報: 未決定")
        case .restricted:
            print("📍 位置情報: 制限中")
            errorMessage = "位置情報の使用が制限されています"
        case .denied:
            print("📍 位置情報: 拒否")
            errorMessage = "位置情報の使用が拒否されています。設定から許可してください。"
        case .authorizedAlways, .authorizedWhenInUse:
            print("📍 位置情報: 許可済み")
            // 許可されたら自動的に位置情報を取得開始
            startUpdatingLocation()
        @unknown default:
            break
        }
    }
}


