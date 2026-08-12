import SwiftUI

struct ExclusiveView: View {
  @EnvironmentObject private var appModel: AppModel

  static let verifiedCollections = [
    ThemeProductRail(
      eyebrow: "EXCLUSIVE ONLY AT BEAUTYONTAPP",
      heading: "Pastry Skincare",
      collectionHandle: "pastry-skincare",
      linkLabel: "SHOW MORE",
      productCount: 8
    ),
    ThemeProductRail(
      eyebrow: "",
      heading: "Mzuri Skin",
      collectionHandle: "mzuri-skin",
      linkLabel: "SHOW MORE",
      productCount: 8
    ),
    ThemeProductRail(
      eyebrow: "",
      heading: "B’AiR Skincare",
      collectionHandle: "bair-skincare",
      linkLabel: "SHOW MORE",
      productCount: 8
    ),
    ThemeProductRail(
      eyebrow: "",
      heading: "Formè",
      collectionHandle: "forme",
      linkLabel: "SHOW MORE",
      productCount: 8
    ),
    ThemeProductRail(
      eyebrow: "",
      heading: "HÓM",
      collectionHandle: "hom",
      linkLabel: "SHOW MORE",
      productCount: 8
    ),
  ]

  var body: some View {
    ScrollView {
      LazyVStack(
        alignment: .leading,
        spacing: ThemeTokens.sectionSpacing,
        pinnedViews: [.sectionHeaders]
      ) {
        StoreHeader(
          appModel: appModel,
          presentation: .primary
        )

        Section {
          ForEach(Self.verifiedCollections, id: \.collectionHandle) { collection in
            ProductRailView(specification: collection)
          }

          ThemeBenefitsFooter()
      } header: {
          StoreHeader(
            appModel: appModel,
            presentation: .tabs
          )
          .zIndex(1)
        }
      }
    }
    .accessibilityIdentifier("exclusive-screen")
    .background(ThemeTokens.canvas)
    .nativeSoftTopScrollEdgeEffect()
    .navigationBarHidden(true)
  }
}

private struct ThemeBenefitsFooter: View {
  @EnvironmentObject private var appModel: AppModel

  private struct Benefit: Identifiable {
    let title: String
    let subtitle: String
    let symbol: String
    let destination: Destination

    var id: String { title }

    enum Destination {
      case none
      case skincare
      case stores
    }
  }

  private let benefits = [
    Benefit(
      title: "Convenient",
      subtitle: "Easy payments, returns, and exchanges.",
      symbol: "creditcard",
      destination: .none
    ),
    Benefit(
      title: "Fast Delivery",
      subtitle: "Delivery options shown at checkout.",
      symbol: "truck.box",
      destination: .none
    ),
    Benefit(
      title: "Wide Variety",
      subtitle: "1,400+ beauty products to shop on one platform.",
      symbol: "square.grid.2x2",
      destination: .skincare
    ),
    Benefit(
      title: "Find a BeautyOnTApp",
      subtitle: "Choose Your Store",
      symbol: "mappin",
      destination: .stores
    ),
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(benefits) { benefit in
        row(for: benefit)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.vertical, 10)
    .background(Color.black)
    .accessibilityIdentifier("exclusive-benefits-footer")
  }

  @ViewBuilder
  private func row(for benefit: Benefit) -> some View {
    if case .none = benefit.destination {
      benefitLabel(benefit)
    } else {
      Button {
        open(benefit.destination)
      } label: {
        benefitLabel(benefit)
      }
      .buttonStyle(.plain)
    }
  }

  private func benefitLabel(_ benefit: Benefit) -> some View {
    HStack(spacing: 10) {
      Image(systemName: benefit.symbol)
        .font(.system(size: 19, weight: .regular))
        .foregroundStyle(Color.white)
        .frame(width: 38, height: 38)
        .background(Color.white.opacity(0.08))
        .overlay {
          RoundedRectangle(cornerRadius: 11, style: .continuous)
            .stroke(Color.white.opacity(0.18), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

      VStack(alignment: .leading, spacing: 2) {
        Text(benefit.title)
          .themeScaledFont(size: 14, weight: .bold)
          .foregroundStyle(Color.white)

        Text(benefit.subtitle)
          .themeScaledFont(size: 12, weight: .regular)
          .foregroundStyle(Color.white.opacity(0.8))
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
    .padding(.horizontal, 20)
    .contentShape(Rectangle())
    .accessibilityElement(children: .combine)
  }

  private func open(_ destination: Benefit.Destination) {
    switch destination {
    case .none:
      break
    case .skincare:
      appModel.showCollection(title: "Skincare", handle: "skincare")
    case .stores:
      appModel.selectDock(.stores)
    }
  }
}
