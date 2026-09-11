import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/review_service.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/routes.dart';
import 'package:tax_code_flutter/services/in_app_review_service.dart';
import 'package:tax_code_flutter/widgets/contacts_list.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_fab.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_header.dart';
import 'package:tax_code_flutter/widgets/responsive_layout.dart';

final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _onAddContact(BuildContext context) async {
    final homeController = context.read<HomePageController>();
    final newContact =
        await Navigator.pushNamed(context, Routes.form) as Contact?;

    if (newContact != null) {
      homeController.saveContact(newContact);

      if (!context.mounted) return;
      final reviewService = context.read<ReviewService>();
      await reviewService.incrementSuccessfulCalculations();

      if (!context.mounted) return;
      final inAppReviewService = context.read<InAppReviewService>();
      await inAppReviewService.maybeRequestReview();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardHeader(
        onProfileTap: () => Navigator.pushNamed(context, Routes.profile),
      ),
      body: ResponsiveLayout(
        maxWidth: 600.0,
        padding: EdgeInsets.zero,
        child: ContactsList(
          onAddContact: () => _onAddContact(context),
        ),
      ),
      floatingActionButton: DashboardFab(
        onPressed: () => _onAddContact(context),
      ),
    );
  }
}
