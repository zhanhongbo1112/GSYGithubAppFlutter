import 'package:flutter/material.dart';

import '../common/common.dart';

/// Card Widget
class GSYCardItem extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final Color color;
  final RoundedRectangleBorder shape;
  final double elevation;

  GSYCardItem({@required this.child, this.margin, this.color, this.shape, this.elevation = 5.0});

  @override
  Widget build(BuildContext context) {
    EdgeInsets margin = this.margin;
    RoundedRectangleBorder shape = this.shape;
    Color color = this.color;
    margin ??= EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0, bottom: 10.0);
    shape ??= RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)));
    color ??= Color(GSYColors.cardWhite);
    return Card(elevation: elevation, shape: shape, color: color, margin: margin, child: child);
  }
}
