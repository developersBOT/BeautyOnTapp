import 'package:flutter/material.dart';
import 'offer.dart';

class OfferCard extends StatelessWidget {
  final Offer offer;
  final double imageHeight;
  final VoidCallback? onTap;

  const OfferCard({
    super.key,
    required this.offer,
    required this.imageHeight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material( // needed for InkWell ripple & reliable taps
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap, // ← whole card also navigates
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 1), // black outline as figma
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(9),
                  topRight: Radius.circular(9),
                ),
                child: Image.asset(
                  offer.imageAsset,
                  height: imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // content
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offer.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      offer.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, height: 1.2),
                    ),
                    const SizedBox(height: 10),
                    // CTA button — also triggers the same onTap
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: onTap,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('SHOP NOW',
                                style: TextStyle(
                                    fontSize: 12.5, fontWeight: FontWeight.w700)),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          ],
                        ),
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
