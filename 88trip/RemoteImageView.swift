//
//  RemoteImageView.swift
//  88trip
//
//  Created by GPT-5 Codex on 2025/11/09.
//

import SwiftUI

final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func insert(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

final class ImageRepository {
    static let shared = ImageRepository()
    private var loaders: [String: ImageLoader] = [:]
    private let queue = DispatchQueue(label: "RemoteImageView.ImageRepository.queue", attributes: .concurrent)
    
    func loader(for urlString: String) -> ImageLoader {
        queue.sync {
            if let loader = loaders[urlString] {
                return loader
            }
            let loader = ImageLoader(urlString: urlString)
            queue.async(flags: .barrier) {
                self.loaders[urlString] = loader
            }
            return loader
        }
    }
}
//MARK: - imageloaderクラス　インスタンス化
final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    @Published var hasError = false
    
    private let originalUrlString: String?
    private var task: Task<Void, Never>? //taskはUI表示中に裏で処理してくれる
    
    init(urlString: String?) {
        self.originalUrlString = urlString
    }
    
    func load() {
        guard !isLoading else { return }
        
        guard
            let originalUrlString,
            !originalUrlString.isEmpty,
            let encoded = originalUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: encoded)
        else {
            hasError = true
            return
        }
        
        if let cached = ImageCache.shared.image(forKey: encoded) {
            image = cached
            return
        }
        
        isLoading = true
        hasError = false
        
        task = Task(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else { return }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let uiImage = UIImage(data: data) else {
                    throw URLError(.cannotDecodeContentData)
                }
                ImageCache.shared.insert(uiImage, forKey: encoded)
                
                self.image = uiImage
                self.isLoading = false
            } catch {
                self.hasError = true
                self.isLoading = false
            }
        }
    }
}

struct RemoteImageView<Placeholder: View>: View {
    @ObservedObject private var loader: ImageLoader
    private let minHeight: CGFloat
    private let maxWidth: CGFloat
    private let contentMode: ContentMode
    private let placeholder: () -> Placeholder
    
    init(
        imageUrlString: String?,
        minHeight: CGFloat,
        maxWidth: CGFloat = .infinity,
        contentMode: ContentMode = .fill,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        if let imageUrlString, !imageUrlString.isEmpty {
            _loader = ObservedObject(wrappedValue: ImageRepository.shared.loader(for: imageUrlString))
        } else {
            _loader = ObservedObject(wrappedValue: ImageLoader(urlString: nil))
        }
        self.minHeight = minHeight
        self.maxWidth = maxWidth
        self.contentMode = contentMode
        self.placeholder = placeholder
    }
    
    var body: some View {
        ZStack {
            placeholder()
            
            if let image = loader.image {
                let remoteImage = Image(uiImage: image)
                    .resizable()
                
                if contentMode == .fill {
                    remoteImage
                        .scaledToFill()
                        .frame(maxWidth: maxWidth, minHeight: minHeight, maxHeight: minHeight)
                        .clipped()
                } else {
                    remoteImage
                        .scaledToFit()
                        .frame(maxWidth: maxWidth, minHeight: minHeight, maxHeight: minHeight)
                }
            } else if loader.isLoading {
                ProgressView()
            } else if loader.hasError {
                // プレースホルダーのみ表示
                EmptyView()
            }
        }
        .frame(maxWidth: maxWidth, minHeight: minHeight, maxHeight: minHeight)
        .clipped()
        .onAppear {
            loader.load()
        }
    }
}


