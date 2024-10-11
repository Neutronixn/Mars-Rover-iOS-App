import SwiftUI

struct SafeAsyncImage<Content: View, Placeholder: View>: View {
    @State private var currentURL: URL?
    private let initialURL: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.initialURL = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
        self.placeholder = placeholder
        self._currentURL = State(initialValue: url)
    }

    var body: some View {
        AsyncImage(
            url: currentURL,
            scale: scale,
            transaction: transaction
        ) { phase in
            switch phase {
            case .empty:
                placeholder()
            case .success(let image):
                content(image)
            case .failure:
                failureView
            @unknown default:
                placeholder()
            }
        }
    }

    @ViewBuilder
    private var failureView: some View {
        if let httpsURL = convertToHTTPS(url: currentURL) {
            AsyncImage(url: httpsURL, scale: scale, transaction: transaction) { httpsPhase in
                switch httpsPhase {
                case .empty, .failure:
                    placeholder() // Return placeholder if there's no image or an error
                case .success(let image):
                    content(image) // Display the loaded image
                @unknown default:
                    placeholder() // Return placeholder for unknown cases
                }
            }
        } else {
            placeholder() // Return the placeholder if URL conversion fails
        }
    }

    // Helper function to convert "http" to "https"
    private func convertToHTTPS(url: URL?) -> URL? {
        guard let url = url, url.scheme == "http",
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.scheme = "https"
        return components.url
    }


}
