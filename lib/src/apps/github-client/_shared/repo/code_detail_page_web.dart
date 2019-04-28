import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:gsy_github_app_flutter/src/apps/github-client/index.dart';

import '../../../../../common/common.dart';
import '../../../../../widget/widget.dart';

/// 文件代码详情
class CodeDetailPageWeb extends StatefulWidget {
  final String userName;

  final String reposName;

  final String path;

  final String data;

  final String title;

  final String branch;

  final String htmlUrl;

  CodeDetailPageWeb({this.title, this.userName, this.reposName, this.path, this.data, this.branch, this.htmlUrl});

  @override
  _CodeDetailPageState createState() =>
      _CodeDetailPageState(this.title, this.userName, this.reposName, this.path, this.data, this.branch, this.htmlUrl);
}

class _CodeDetailPageState extends State<CodeDetailPageWeb> {
  final String userName;

  final String reposName;

  final String path;

  final String branch;

  final String htmlUrl;

  String data;

  final String title;

  _CodeDetailPageState(this.title, this.userName, this.reposName, this.path, this.data, this.branch, this.htmlUrl);

  @override
  void initState() {
    super.initState();
    if (data == null) {
      ReposDao.getReposFileDirDao(userName, reposName, path: path, branch: branch, text: true, isHtml: true)
          .then((res) {
        if (res != null && res.result) {
          String data2 = HtmlUtils.resolveHtmlFile(res, "java");
          String url =
              Uri.dataFromString(data2, mimeType: 'text/html', encoding: Encoding.getByName("utf-8")).toString();
          setState(() {
            this.data = url;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return Scaffold(
        appBar: AppBar(
          title: GSYTitleBar(title),
        ),
        body: Center(
          child: Container(
            width: 200.0,
            height: 200.0,
            padding: EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SpinKitDoubleBounce(color: Theme.of(context).primaryColor),
                Container(width: 10.0),
                Container(child: Text(CommonUtils.getLocale(context).loading_text, style: GSYConstant.middleText)),
              ],
            ),
          ),
        ),
      );
    }

    if (Config.USE_NATIVE_WEBVIEW && Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: WebView(
          initialUrl: data,
          javaScriptMode: JavaScriptMode.unrestricted,
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: WebView(
        initialUrl: data,
        javaScriptMode: JavaScriptMode.unrestricted,
      ),
    );
  }
}
