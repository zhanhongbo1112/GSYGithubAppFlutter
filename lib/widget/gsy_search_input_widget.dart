import 'package:flutter/material.dart';

import '../common/common.dart';

/// 搜索输入框
class GSYSearchInputWidget extends StatelessWidget {
  final ValueChanged<String> onChanged;

  final ValueChanged<String> onSubmitted;

  final VoidCallback onSubmitPressed;

  GSYSearchInputWidget(this.onChanged, this.onSubmitted, this.onSubmitPressed);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          color:  Color(GSYColors.white),
          border: Border.all(color: Theme.of(context).primaryColor, width: 0.3),
          boxShadow: [BoxShadow(color: Theme.of(context).primaryColorDark,  blurRadius: 4.0)]),
      padding: EdgeInsets.only(left: 20.0, top: 12.0, right: 20.0, bottom: 12.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: TextField(
                  autofocus: false,
                  decoration: InputDecoration.collapsed(
                    hintText: CommonUtils.getLocale(context).repos_issue_search,
                    hintStyle: GSYConstant.middleSubText,
                  ),
                  style: GSYConstant.middleText,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted)),
          RawMaterialButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.only(right: 5.0, left: 10.0),
              constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
              child: Icon(GSYICons.SEARCH, size: 15.0, color: Theme.of(context).primaryColorDark,),
              onPressed: onSubmitPressed)
        ],
      ),
    );
  }
}
