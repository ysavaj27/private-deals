import 'package:private_deals/src/shared/app_exports.dart';

class SellerProfileWidget extends StatelessWidget {
  final SharePriceSellerModel seller;
  final String label;

  const SellerProfileWidget(
      {super.key, required this.seller, this.label = 'Seller'});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: seller.logo.isNotEmpty
                ? LogoImage(
                    url: seller.logo,
                    height: 40,
                    width: 40,
                    fit: BoxFit.contain)
                : Container(
                    height: 40,
                    width: 40,
                    color: context.theme.primaryColor.withValues(alpha: 0.08),
                    child: const Icon(Icons.business_outlined, size: 22),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 3),
                Text(
                    seller.companyName.isNotEmpty
                        ? seller.companyName
                        : 'Seller',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      );
}
