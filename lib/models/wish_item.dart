class WishItem {
  final String id;
  final String brand;       // e.g. FORME
  final String imageAsset;  // local asset
  final String title;       // product name
  final String subtitle;    // optional line under brand
  final double price;

  const WishItem({
    required this.id,
    required this.brand,
    required this.imageAsset,
    required this.title,
    this.subtitle = '',
    required this.price,
  });
}
