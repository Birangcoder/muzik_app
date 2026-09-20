import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muzik/core/theme/app_colors.dart';

// import '../../../../core/constants/routeNameConfig.dart';

class AppSearchBar extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const AppSearchBar({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          // context.pushNamed(AppRoute.searchPage);
        },
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.colors.surface2,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: context.colors.stroke,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: context.colors.text2),
              const SizedBox(width: 10),
              Text(
                "Search here...",
                style: TextStyle(color: context.colors.text, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
