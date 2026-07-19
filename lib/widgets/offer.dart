class Offer {
  final String imageAsset; // asset path
  final String title;
  final String subtitle;
  final String cta; // button text

  const Offer({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    this.cta = 'SHOP NOW',
  });
}
