import 'package:flutter/material.dart';

/**
 * title 控件
 * Created by guoshuyu
 * on 2018/7/24.
 */
class GSYTitleBar extends StatelessWidget {
  final String title;

  final IconData iconData;

  final VoidCallback onPressed;

  final bool needRightLocalIcon;

  final Widget rightWidget;

  GSYTitleBar(this.title, {this.iconData, this.onPressed, this.needRightLocalIcon = false, this.rightWidget});

  @override
  Widget build(BuildContext context) {
    Widget widget = rightWidget;
    if (rightWidget == null) {
      widget = (needRightLocalIcon)
          ? IconButton(
              icon: Icon(
                iconData,
                size: 19.0,
              ),
              onPressed: onPressed)
          : Container();
    }
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          widget
        ],
      ),
    );
  }
}
