import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../app_button.dart';
import '../section_card.dart';
import '../section_title.dart';

// Owner-only pipeline card showing incoming requests and sent invitations.
class CandidatePipelineCard extends StatelessWidget {
  const CandidatePipelineCard({
    super.key,
    required this.incomingRequests,
    required this.sentInvitations,
    required this.onReview,
  });

  final int incomingRequests;
  final int sentInvitations;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Candidate Pipeline'),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  title: 'Incoming requests',
                  value: incomingRequests,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricBox(
                  title: 'Sent invitations',
                  value: sentInvitations,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Review applicants',
            outlined: true,
            onPressed: onReview,
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({required this.title, required this.value});

  final String title;
  final int value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value', style: AppStyles.h2(context)),
          Text(title, style: AppStyles.body12Secondary(context)),
        ],
      ),
    );
  }
}
