import 'package:flutter/material.dart';
import '../data/static_data.dart';
import 'footer_section.dart';

/// Full-width black footer you can reuse on multiple pages.
/// Internally uses your existing FooterSection with the same data.
class BlackFooter extends StatelessWidget {
  const BlackFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return FooterSection(
      stats: footerStats,
      links: footerCols,
      email: contactEmail,
      address: contactAddress,
    );
  }
}
