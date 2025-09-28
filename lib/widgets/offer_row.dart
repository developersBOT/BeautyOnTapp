import 'package:flutter/material.dart';
import 'offer.dart';

class OfferRow extends StatelessWidget {
  final List<Offer> items;
  final void Function(int index)? onTap;

  const OfferRow({super.key, required this.items, this.onTap});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.04;
    const gap = 12.0;

    final cardW = (w - pad * 2 - gap) / 2;
    final imgH = cardW * 0.58; // matches figma proportions

    return SizedBox(
      height: imgH + 150,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: pad),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: gap),
        itemBuilder: (_, i) => _OfferCard(
          offer: items[i],
          width: cardW,
          imgH: imgH,
          onTap: onTap == null ? null : () => onTap!(i),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Offer offer;
  final double width;
  final double imgH;
  final VoidCallback? onTap;

  const _OfferCard({
    required this.offer,
    required this.width,
    required this.imgH,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            // ✅ light border (no black outline)
            border: Border.all(color: const Color(0xFFE2E2E2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: SizedBox(
                  height: imgH,
                  width: width,
                  child: Image.asset(offer.imageAsset, fit: BoxFit.cover),
                ),
              ),
              // content
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      offer.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: Colors.black87, height: 1.25),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          textStyle: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        child: Text(offer.cta),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
