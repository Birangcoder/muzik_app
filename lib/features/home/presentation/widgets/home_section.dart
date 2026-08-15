import 'package:flutter/material.dart';
import '../widgets/section_head.dart';

import '../../../../core/utils/responsive.dart';

class HomeSection<T> extends StatelessWidget {
  final String title;
  final double height;
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback? onSeeAll;
  final Widget? emptyWidget;

  const HomeSection({
    super.key,
    required this.title,
    required this.height,
    required this.items,
    required this.itemBuilder,
    this.onSeeAll,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead(title: title, onSeeAll: onSeeAll),
        if (items.isEmpty)
          SizedBox(child: emptyWidget)
        else
          SizedBox(
            height: height,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Colors.transparent, Colors.white],
                stops: [0.0, 0.06],
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: hPad),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, i) {
                  return itemBuilder(context, items[i], i);
                },
              ),
            ),
          ),
      ],
    );
  }
}
