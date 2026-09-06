class Promo {
  final String imageAsset;
  final String title;
  final String subtitle;
  final String cta;

  // NEW:
  final String? apiUrl;
  final String? brand;

  const Promo({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    required this.cta,
    this.apiUrl,
    this.brand,
  });
}
