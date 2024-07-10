import 'package:flutter/material.dart';

class MySliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  MySliverAppBarDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 20.0;

  @override
  double get minExtent => 20.0;

  @override
  bool shouldRebuild(covariant MySliverAppBarDelegate oldDelegate) {
    return false;
  }
}
