import 'package:flutter/material.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../shared/models/proof_of_delivery.dart';
import '../../../../shared/widgets/authenticated_image.dart';

class TripPodDocuments extends StatelessWidget {
  const TripPodDocuments({
    super.key,
    required this.tripId,
    required this.pod,
    required this.strings,
  });

  final int tripId;
  final ProofOfDelivery pod;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.t('pod.saved_documents'), style: AppText.caption),
          const SizedBox(height: 12),
          if (!pod.hasDocuments)
            Text(strings.t('pod.no_documents'), style: AppText.bodyMuted)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var index = 0; index < pod.photoCount; index++)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: AuthenticatedImage(
                      path: ApiEndpoints.tripPodPhoto(tripId, index),
                      width: 108,
                      height: 108,
                    ),
                  ),
                if (pod.hasSignature)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: AuthenticatedImage(
                      path: ApiEndpoints.tripPodSignature(tripId),
                      width: 108,
                      height: 108,
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
