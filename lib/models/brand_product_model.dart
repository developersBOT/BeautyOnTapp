class BrandProduct {
  final String id;
  final String title;
  final String vendor;
  final double price;
  final String image;
  final bool inStock;

  BrandProduct({
    required this.id,
    required this.title,
    required this.vendor,
    required this.price,
    required this.image,
    required this.inStock,
  });

  factory BrandProduct.fromJson(Map<String, dynamic> json) {
    final variants = (json['variants'] as List?) ?? [];
    final images = (json['images'] as List?) ?? [];

    return BrandProduct(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      vendor: json['vendor']?.toString() ?? '',
      price: variants.isNotEmpty
          ? double.tryParse(variants[0]['price']?.toString() ?? '0') ?? 0.0
          : 0.0,
      image: images.isNotEmpty
          ? (images[0]['src']?.toString() ?? "https://via.placeholder.com/150")
          : "https://via.placeholder.com/150",
      inStock: variants.isNotEmpty
          ? ((variants[0]['inventory_quantity'] ?? 0) as int) > 0
          : false,
    );
  }
}
