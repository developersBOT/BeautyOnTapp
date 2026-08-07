import Foundation

struct ProductOptionGroup: Identifiable, Equatable {
  let name: String
  let values: [String]

  var id: String {
    name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  }
}

enum ProductOptionValueAvailability: Equatable {
  case available
  case soldOut
  case incompatible
}

struct ProductVariantSelection: Equatable {
  private(set) var variants: [StoreVariant]
  private(set) var selectedValues: [String: String]
  private(set) var selectedVariantID: String?

  init(
    variants: [StoreVariant],
    initialVariantID: String? = nil
  ) {
    self.variants = variants

    let initialVariant =
      variants.first(where: { $0.id == initialVariantID })
      ?? variants.first(where: \.availableForSale)
      ?? variants.first

    selectedVariantID = initialVariant?.id
    selectedValues = Self.optionValues(for: initialVariant)
  }

  var selectedVariant: StoreVariant? {
    guard let selectedVariantID else { return nil }
    return variants.first(where: { $0.id == selectedVariantID })
  }

  var optionGroups: [ProductOptionGroup] {
    var names: [String] = []
    var valuesByName: [String: [String]] = [:]
    var displayNameByKey: [String: String] = [:]

    for variant in variants {
      for option in variant.selectedOptions {
        let key = Self.normalized(option.name)
        guard !key.isEmpty else { continue }
        if displayNameByKey[key] == nil {
          names.append(key)
          displayNameByKey[key] = option.name
        }

        let existingValues = valuesByName[key] ?? []
        if !existingValues.contains(where: {
          Self.normalized($0) == Self.normalized(option.value)
        }) {
          valuesByName[key, default: []].append(option.value)
        }
      }
    }

    return names.compactMap { key in
      guard let name = displayNameByKey[key],
        let values = valuesByName[key],
        !values.isEmpty
      else {
        return nil
      }
      return ProductOptionGroup(name: name, values: values)
    }
  }

  var visibleOptionGroups: [ProductOptionGroup] {
    let groups = optionGroups
    guard groups.count == 1,
      let group = groups.first,
      group.values.count == 1,
      Self.normalized(group.name) == "title",
      Self.normalized(group.values[0]) == "default title"
    else {
      return groups
    }
    return []
  }

  func selectedValue(for optionName: String) -> String? {
    selectedValues[Self.normalized(optionName)]
  }

  func availability(
    of value: String,
    for optionName: String
  ) -> ProductOptionValueAvailability {
    var proposed = selectedValues
    proposed[Self.normalized(optionName)] = value

    let matching = variants.filter {
      Self.variant($0, matches: proposed)
    }
    guard !matching.isEmpty else {
      return .incompatible
    }
    return matching.contains(where: \.availableForSale)
      ? .available
      : .soldOut
  }

  mutating func select(
    _ value: String,
    for optionName: String
  ) {
    let optionKey = Self.normalized(optionName)
    var proposed = selectedValues
    proposed[optionKey] = value

    if let exact = variants.first(where: {
      Self.variant($0, matches: proposed)
    }) {
      apply(exact)
      return
    }

    let candidates = variants.filter { variant in
      Self.optionValues(for: variant)[optionKey]
        .map { Self.normalized($0) == Self.normalized(value) }
        ?? false
    }
    let bestCandidate = candidates.max { lhs, rhs in
      let lhsScore = matchScore(lhs, against: selectedValues)
      let rhsScore = matchScore(rhs, against: selectedValues)
      if lhsScore != rhsScore {
        return lhsScore < rhsScore
      }
      if lhs.availableForSale != rhs.availableForSale {
        return !lhs.availableForSale
      }
      return false
    }
    if let bestCandidate {
      apply(bestCandidate)
    }
  }

  mutating func replaceVariants(
    _ variants: [StoreVariant],
    preferredVariantID: String?
  ) {
    self = ProductVariantSelection(
      variants: variants,
      initialVariantID: preferredVariantID
    )
  }

  private mutating func apply(_ variant: StoreVariant) {
    selectedVariantID = variant.id
    selectedValues = Self.optionValues(for: variant)
  }

  private func matchScore(
    _ variant: StoreVariant,
    against values: [String: String]
  ) -> Int {
    let variantValues = Self.optionValues(for: variant)
    return values.reduce(into: 0) { score, pair in
      if variantValues[pair.key].map(Self.normalized)
        == Self.normalized(pair.value)
      {
        score += 1
      }
    }
  }

  private static func variant(
    _ variant: StoreVariant,
    matches values: [String: String]
  ) -> Bool {
    let variantValues = optionValues(for: variant)
    return values.allSatisfy { key, value in
      variantValues[key].map(normalized) == normalized(value)
    }
  }

  private static func optionValues(
    for variant: StoreVariant?
  ) -> [String: String] {
    guard let variant else { return [:] }
    return Dictionary(
      variant.selectedOptions.map {
        (normalized($0.name), $0.value)
      },
      uniquingKeysWith: { first, _ in first }
    )
  }

  private static func normalized(_ value: String) -> String {
    value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  }
}
