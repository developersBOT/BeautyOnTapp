class Product {
  final String id;
  final String title;
  final String subtitle;
  final String imageAsset; // for local/demo assets
  final String imageUrl;   // for API images
  final double price;
  final double rating;   // 0–5
  final int reviews;     // count

  const Product({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.imageAsset = '',
    this.imageUrl = '',
    required this.price,
    this.rating = 4.8,
    this.reviews = 95,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // ✅ Extract price from first variant
    double parsedPrice = 0.0;
    final variants = json['variants'] as List?;
    if (variants != null && variants.isNotEmpty) {
      final priceStr = variants[0]['price']?.toString();
      parsedPrice = double.tryParse(priceStr ?? '') ?? 0.0;
    }

    // ✅ Extract first image
    String parsedImageUrl = '';
    final images = json['images'] as List?;
    if (images != null && images.isNotEmpty) {
      parsedImageUrl = images[0]['src']?.toString() ?? '';
    }

    return Product(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      subtitle: json['vendor'] ?? '',
      imageUrl: parsedImageUrl,
      price: parsedPrice,
      rating: 4.8, // Set default rating or use the one from the API if available
      reviews: 0, // You can extract reviews if available in the API response
    );
  }

  // `toJson` method to convert Product object to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageAsset': imageAsset,
      'imageUrl': imageUrl,
      'price': price,
      'rating': rating,
      'reviews': reviews,
    };
  }
}
