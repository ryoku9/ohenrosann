//
//  MapView.swift
//  88trip
//
//  Created by かめいりょう on 2025/09/27.
//

import SwiftUI
import MapKit
import CoreLocation
import SpriteKit

// MARK: - 現在位置アイコン
struct CustomUserDot: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.cyan, Color.blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 20, height: 20)
                .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 2)
                .overlay(alignment: .topLeading) {
                    Circle()
                        .fill(Color.white.opacity(0.7))
                        .frame(width: 6, height: 6)
                        .blur(radius: 1.2)
                        .offset(x: 2, y: 2)
                }
        }
    }
}

// MARK: - パーティクル
final class TapParticleScene: SKScene {
    private func regularPolygonPath(sides: Int, radius: CGFloat) -> CGPath {
        let path = UIBezierPath()
        guard sides >= 3 else { return path.cgPath }
        let step = 2 * CGFloat.pi / CGFloat(sides)
        for i in 0..<sides {
            let angle = step * CGFloat(i) - .pi / 2
            let point = CGPoint(x: radius * cos(angle), y: radius * sin(angle))
            (i == 0) ? path.move(to: point) : path.addLine(to: point)
        }
        path.close()
        return path.cgPath
    }
    
    private lazy var particleTexture: SKTexture = {
        let polygon = SKShapeNode(path: regularPolygonPath(sides: 6, radius: 6))
        polygon.fillColor = .white
        polygon.strokeColor = .clear
        let view = SKView()
        return view.texture(from: polygon) ?? SKTexture()
    }()
    
    func emit(at point: CGPoint) {
        let count = 5
        for _ in 0..<count {
            let emitter = SKEmitterNode()
            emitter.particleTexture = particleTexture
            emitter.particleBirthRate = 1
            emitter.numParticlesToEmit = 1
            emitter.particleLifetime = 0.2
            emitter.particleLifetimeRange = 0.2
            emitter.particlePosition = point
            emitter.particleSpeed = 160
            emitter.particleSpeedRange = 4
            emitter.emissionAngle = CGFloat.random(in: 0..<(2 * .pi))
            emitter.emissionAngleRange = .pi / 48
            emitter.particleAlpha = 0.95
            emitter.particleAlphaSpeed = -1.2
            emitter.particleScale = 0.3
            emitter.particleScaleRange = 0.01
            emitter.particleScaleSpeed = -1.5
            emitter.particleColor = SKColor.white.withAlphaComponent(0.9)
            emitter.particleColorBlendFactor = 1.0
            addChild(emitter)
            emitter.run(.sequence([.wait(forDuration: 1.2), .removeFromParent()]))
        }
    }
    
    func emitShootingStar(from point: CGPoint) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = particleTexture
        emitter.particlePosition = point
        emitter.particleBirthRate = 5000
        emitter.numParticlesToEmit = 220
        emitter.particleLifetime = 10
        emitter.particleLifetimeRange = 0
        emitter.emissionAngle = .pi / 2.5
        emitter.emissionAngleRange = .pi / 66
        emitter.particleSpeed = 160
        emitter.particleSpeedRange = 100
        emitter.xAcceleration = 50
        emitter.yAcceleration = 140
        emitter.particleAlpha = 0.95
        emitter.particleAlphaSpeed = -0.8
        emitter.particleScale = 0.2
        emitter.particleScaleRange = 0.1
        emitter.particleScaleSpeed = -0.01
        emitter.particleColor = .white
        emitter.particleColorBlendFactor = 1.0
        addChild(emitter)
        emitter.run(.sequence([.wait(forDuration: 4.0), .removeFromParent()]))
    }
}

// MARK: - 寺院情報カード
private struct TempleCard: View {
    let temple: Temple
    let onClose: () -> Void
    let onAcquire: (CGPoint) -> Void
    @State private var acquireButtonFrame: CGRect = .zero
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            HStack {
                Spacer()
                Text(temple.name)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                Spacer()
            }
            .padding(.top, 80)
            
            Spacer()
            
            Text(temple.description?.isEmpty == false ? temple.description! : "このお寺への訪問を記録しますか？")
                .font(.callout)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 20)
            
            Spacer()
            
            HStack {
                Spacer()
                Button(action: {
                    let center = CGPoint(x: acquireButtonFrame.midX, y: acquireButtonFrame.midY)
                    onAcquire(center)
                    onClose()
                }) {
                    Text("記録")
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white, in: Capsule())
                        .overlay(Capsule().stroke(Color.green, lineWidth: 0.5))
                        .foregroundStyle(.green)
                }
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear { acquireButtonFrame = geo.frame(in: .global) }
                            .onChange(of: geo.frame(in: .global)) { _, newValue in
                                acquireButtonFrame = newValue
                            }
                    }
                )
                Spacer()
            }
            .padding(.bottom, 80)
        }
        .frame(width: UIScreen.main.bounds.width * 0.85,
               height: UIScreen.main.bounds.height * 0.65)
        .background(Color(.systemBackground).opacity(0.98), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.black.opacity(0.08), lineWidth: 1))
        .shadow(radius: 10, y: 4)
    }
}

// MARK: - マップビュー本体
struct MapView: View {
    @StateObject private var templeService = TempleService()
    @StateObject private var locationManager = LocationManager()
    
    @State private var particleScene = TapParticleScene()
    @State private var particleCanvasSize: CGSize = .zero
    @State private var backpackButtonFrame: CGRect = .zero
    
    @State private var centerCoordinate = CLLocationCoordinate2D(latitude: 34.3500, longitude: 134.0465)
    @State private var distance: CLLocationDistance = 2000
    @State private var pitch: CGFloat = 45
    @State private var heading: CLLocationDirection = 0
    @State private var position: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 34.159665, longitude: 134.502531),
            distance: 2000,
            heading: 0,
            pitch: 45
        )
    )
    
    @State private var displayedTemples: [Temple] = []
    @State private var selectedDestinationId: UUID?
    @State private var selectedTemple: Temple?
    @State private var showTempleCard = false
    
    private let interactionRadius: CLLocationDistance = 300
    
    var body: some View {
        MapReader { _ in
            Map(position: $position, interactionModes: [.zoom, .pan, .rotate]) {
                if let location = locationManager.location {
                    Annotation("", coordinate: location.coordinate) {
                        CustomUserDot()
                    }
                }
                
                ForEach(displayedTemples) { temple in
                    if let coordinate = temple.coordinate {
                        MapCircle(center: coordinate, radius: interactionRadius)
                            .foregroundStyle(Color.blue.opacity(0.15))
                            .mapOverlayLevel(level: .aboveRoads)
                            .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                        
                        Annotation(temple.name, coordinate: coordinate) {
                            let isWithin = userIsWithinInteractionRange(of: coordinate)
                            Button {
                                selectedTemple = temple
                                showTempleCard = true
                            } label: {
                                Image(systemName: isWithin ? "mappin.circle.fill" : "mappin.circle")
                                    .font(.title2)
                            }
                            .buttonStyle(.plain)
                            .disabled(!isWithin)
                            .opacity(isWithin ? 1.0 : 0.5)
                        }
                    }
                }
            }
            .simultaneousGesture(DragGesture(minimumDistance: 0).onEnded { value in
                let location = value.location
                let scenePoint = CGPoint(x: location.x, y: particleCanvasSize.height - location.y)
                particleScene.emit(at: scenePoint)
            })
            .allowsHitTesting(!showTempleCard)
            .overlay(alignment: .topLeading) {
                destinationButtons
            }
            .overlay(alignment: .topTrailing) {
                trailingButtons
            }
            .overlay(alignment: .top) {
                statusOverlay
            }
            .overlay(alignment: .center) {
                templeCardOverlay
            }
            .overlay {
                particleOverlay
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapScope($centerCoordinate)
            .onMapCameraChange { context in
                distance = context.camera.distance
                pitch = context.camera.pitch
                heading = context.camera.heading
                centerCoordinate = context.camera.centerCoordinate
            }
        }
        .task {
            await templeService.loadTemples()
        }
        .onReceive(templeService.$destinations) { destinations in
            guard !destinations.isEmpty else {
                displayedTemples = []
                selectedDestinationId = nil
                return
            }
            
            if let currentId = selectedDestinationId,
               let destination = destinations.first(where: { $0.id == currentId }) {
                updateDestination(destination, animated: false)
            } else if let first = destinations.first {
                updateDestination(first, animated: false)
            }
        }
    }
    
    // MARK: - Destination Buttons
    private var destinationButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(templeService.destinations) { destination in
                    Button(destination.title) {
                        updateDestination(destination)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .tint(destination.id == selectedDestinationId ? Color.blue : Color.white)
                    .foregroundColor(destination.id == selectedDestinationId ? Color.white : Color.black.opacity(0.7))
                    .overlay(
                        Capsule()
                            .stroke(Color.blue, lineWidth: destination.id == selectedDestinationId ? 2 : 1)
                    )
                }
                .font(.title3)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(.clear)
        .clipShape(Capsule())
        .padding(.top, 60)
    }
    
    // MARK: - Trailing Buttons
    private var trailingButtons: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Button(action: { focusCurrentLocation() }) {
                Image(systemName: "location.fill")
                    .font(.title3)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .accessibilityLabel("現在地に移動")
            .disabled(locationManager.location == nil)
            
            Button {
                // TODO: 済リストを開く処理
            } label: {
                Image(systemName: "note.text")
                    .font(.title3)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { backpackButtonFrame = geo.frame(in: .global) }
                        .onChange(of: geo.frame(in: .global)) { _, newValue in
                            backpackButtonFrame = newValue
                        }
                }
            )
            .accessibilityLabel("お寺巡り済み一覧")
        }
        .padding(.trailing, 16)
        .padding(.top, 80)
    }
    
    // MARK: - Status Overlay
    private var statusOverlay: some View {
        Group {
            if templeService.isLoading {
                ProgressView("お寺情報を読み込み中…")
                    .font(.footnote)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.thinMaterial, in: Capsule())
            } else if let error = templeService.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.8), in: Capsule())
            }
        }
        .padding(.top, 16)
    }
    
    // MARK: - Temple Card Overlay
    private var templeCardOverlay: some View {
        Group {
            if showTempleCard,
               let temple = selectedTemple {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {}
                    
                    TempleCard(
                        temple: temple,
                        onClose: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showTempleCard = false
                            }
                        },
                        onAcquire: { globalPoint in
                            let scenePoint = CGPoint(x: globalPoint.x, y: particleCanvasSize.height - globalPoint.y)
                            particleScene.emitShootingStar(from: scenePoint)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                let backpackCenter = CGPoint(x: backpackButtonFrame.midX, y: backpackButtonFrame.midY)
                                let backpackScenePoint = CGPoint(x: backpackCenter.x, y: particleCanvasSize.height - backpackCenter.y)
                                particleScene.emit(at: backpackScenePoint)
                            }
                        }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
                }
                .transition(.opacity)
            }
        }
    }
    
    // MARK: - Particle Overlay
    private var particleOverlay: some View {
        GeometryReader { geo in
            SpriteView(scene: particleScene, options: [.allowsTransparency])
                .ignoresSafeArea()
                .onAppear {
                    particleScene.scaleMode = .resizeFill
                    particleScene.backgroundColor = .clear
                    particleScene.size = geo.size
                    particleCanvasSize = geo.size
                }
                .onChange(of: geo.size) { _, newSize in
                    particleScene.size = newSize
                    particleCanvasSize = newSize
                }
        }
        .allowsHitTesting(false)
        .zIndex(20)
    }
    
    // MARK: - Helpers
    private func focusCurrentLocation() {
        guard let location = locationManager.location else { return }
        withAnimation(.easeInOut(duration: 0.4)) {
            position = .camera(
                MapCamera(
                    centerCoordinate: location.coordinate,
                    distance: 1500,
                    heading: heading,
                    pitch: pitch
                )
            )
            centerCoordinate = location.coordinate
        }
    }
    
    private func userIsWithinInteractionRange(of coordinate: CLLocationCoordinate2D) -> Bool {
        guard let location = locationManager.location else { return false }
        let templeLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location.distance(from: templeLocation) <= interactionRadius
    }
    
    private func updateDestination(_ destination: TempleDestination, animated: Bool = true) {
        let updateBlock = {
            position = .camera(
                MapCamera(
                    centerCoordinate: destination.center,
                    distance: destination.distance,
                    heading: heading,
                    pitch: pitch
                )
            )
            centerCoordinate = destination.center
            distance = destination.distance
            displayedTemples = destination.temples
            selectedDestinationId = destination.id
            selectedTemple = nil
            showTempleCard = false
        }
        
        if animated {
            withAnimation(.easeInOut(duration: 0.5)) {
                updateBlock()
            }
        } else {
            updateBlock()
        }
    }
}

private extension Temple {
    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

#Preview {
    MapView()
}

