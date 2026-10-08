part of 'desktop_primary_landing_view.dart';

class StartupCardWidget extends StatelessWidget {
  final StartupRoundModel model;
  final void Function()? onTap;

  const StartupCardWidget({super.key, required this.model, this.onTap});

  @override
  Widget build(BuildContext context) {
    // logger.d(model.startup.cms.logo);
    return SizedBox(
      width: 361,
      height: 425,
      child: Clickable(
        // splashColor: Colors.transparent,
        // hoverColor: Colors.transparent,
        // highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: CustomCardWidget(
          color: context.theme.scaffoldBackgroundColor,
          radius: 14,
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: CacheImage(
                      url: model.startup.cms.banner,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Positioned(
                  //   bottom: 10,
                  //   right: 10,
                  //   child: Visibility(
                  //     visible: app.isIUserLogin,
                  //     child: CustomLikeButton(
                  //         isLike: model.startup.isLike,
                  //         id: model.startupId),
                  //   ),
                  // ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          LogoImage(
                            url: model.startup.cms.logo,
                            height: 43,
                            width: 43,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            model.startup.brandName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      const FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'Round size',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        model
                                            .startup
                                            .raisingRound
                                            .totalFundRequirement
                                            .toFormattedPrice,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          model
                                                      .startup
                                                      .raisingRound
                                                      .sharePrice >
                                                  0
                                              ? 'Share price'
                                              : 'Investors',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        model.startup.raisingRound.sharePrice >
                                                0
                                            ? model
                                                  .startup
                                                  .raisingRound
                                                  .sharePrice
                                                  .toFormattedPrice
                                            : '${model.startup.investorCount}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          model
                                                      .startup
                                                      .raisingRound
                                                      .minimumInvestment >
                                                  0
                                              ? 'Min ticket'
                                              : 'Valuation',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        model
                                                    .startup
                                                    .raisingRound
                                                    .minimumInvestment >
                                                0
                                            ? model
                                                  .startup
                                                  .raisingRound
                                                  .minimumInvestment
                                                  .toFormattedPrice
                                            : model
                                                  .startup
                                                  .raisingRound
                                                  .floor
                                                  .toFormattedPrice,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomCardWidget(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14),
                ),
                width: double.infinity,
                height: 40,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.smart_display, size: 17),
                    const SizedBox(width: 4),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          model.startup.sector.name,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SVGImage(AppAssets.indiaIc, height: 17, width: 17),
                    const SizedBox(width: 4),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          model.startup.city.name,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
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
