import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:yqboots/widget/gsy_common_option_widget.dart';

/// webview版本
class GSYWebView extends StatelessWidget {
  final String url;
  final String title;
  final OptionControl optionControl = OptionControl();

  GSYWebView(this.url, this.title);

  _renderTitle() {
    if (url == null || url.length == 0) {
      return Text(title);
    }
    optionControl.url = url;
    return Row(children: [
      Expanded(child: Container()),
      GSYCommonOptionWidget(optionControl),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      withJavascript: true,
      url: url,
      scrollBar: true,
      withLocalUrl: true,
      appBar: AppBar(
        title: _renderTitle(),
      ),
    );
  }
}
