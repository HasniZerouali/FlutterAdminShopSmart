import 'package:flutter/material.dart';
import 'package:shopsmart_admin/services/assets_manager.dart';
import 'package:shopsmart_admin/widgets/subtitle_text.dart';

class DashboardButtonsWidget extends StatelessWidget {
  const DashboardButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Image.asset(
            AssetsManager.book,
            height: 65,
            width: 65,
          ),
          const SizedBox(
            height: 15,
          ),
          const SubtitleTextWidget(
            label: "Subtitle",
            fontSize: 18,
          )
        ],
      ),
    );
  }
}
