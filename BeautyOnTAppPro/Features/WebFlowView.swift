import SwiftUI

struct WebFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var session: ProtectedWebSession
    let destination: WebDestination

    var body: some View {
        Group {
            if destination.isIsolatedBestie {
                isolatedBestie
            } else {
                protectedBrowser
            }
        }
        .onAppear {
            session.load(destination)
        }
    }

    private var protectedBrowser: some View {
        NavigationView {
            webContent
                .navigationTitle(destination.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if session.canGoBack {
                            Button {
                                session.goBack()
                            } label: {
                                Label("Back", systemImage: "chevron.backward")
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .font(.body.weight(.semibold))
                    }
                }
        }
        .navigationViewStyle(.stack)
    }

    private var isolatedBestie: some View {
        ZStack(alignment: .topTrailing) {
            webContent

            if session.isLoading {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .frame(width: 44, height: 44)
                }
                .tint(ThemeTokens.ink)
                .background(.thinMaterial, in: Circle())
                .padding(.top, 8)
                .padding(.trailing, 12)
                .accessibilityLabel("Close Ask Bestie")
            }

            accessibilityMarker(
                label: "Ask Bestie isolated web flow",
                identifier: "bestie-isolated-web-flow"
            )

            if session.hasReceivedReadySignal {
                accessibilityMarker(
                    label: "Ask Bestie ready",
                    identifier: "bestie-isolated-ready"
                )
            }
        }
    }

    private func accessibilityMarker(
        label: String,
        identifier: String
    ) -> some View {
        Text(label)
            .font(.system(size: 1))
            .foregroundStyle(.clear)
            .frame(width: 1, height: 1)
            .accessibilityLabel(label)
            .accessibilityIdentifier(identifier)
    }

    private var webContent: some View {
        ZStack {
            PersistentWebView(session: session)
                .ignoresSafeArea(edges: .bottom)

            if let error = session.lastError {
                failureShield(error)
            } else if session.isLoading {
                loadingShield
            }
        }
        .animation(ThemeTokens.controlSpring, value: session.isLoading)
        .animation(ThemeTokens.controlSpring, value: session.lastError)
    }

    private var loadingShield: some View {
        VStack(spacing: 14) {
            ProgressView()
                .controlSize(.large)
                .tint(ThemeTokens.ink)
            Text("Opening \(destination.title)…")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ThemeTokens.muted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ThemeTokens.canvas)
        .transition(.opacity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Opening \(destination.title)")
    }

    private func failureShield(_ error: String) -> some View {
        VStack(spacing: 18) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(ThemeTokens.ink)

            VStack(spacing: 8) {
                Text("\(destination.title) didn’t finish loading")
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                Text(error)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 10) {
                Button("Try Again") {
                    session.retry()
                }
                .buttonStyle(.borderedProminent)
                .tint(ThemeTokens.ink)
                .frame(maxWidth: .infinity)

                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .tint(ThemeTokens.ink)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(28)
        .frame(maxWidth: 380)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ThemeTokens.canvas)
        .transition(.opacity)
    }
}
