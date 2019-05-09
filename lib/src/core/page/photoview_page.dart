import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';

import 'package:yqboots/src/core/core.dart';
import 'package:yqboots/src/widgets/widgets.dart';

/// 图片预览
class PhotoViewPage extends StatelessWidget {
  final String url;

  PhotoViewPage(this.url);

  @override
  Widget build(BuildContext context) {
    OptionControl optionControl = OptionControl();
    optionControl.url = url;
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.file_download),
          onPressed: () {
            CommonUtils.saveImage(url).then((res) {
              if (res != null) {
                Fluttertoast.showToast(msg: res);
                if (Platform.isAndroid) {
                  const updateAlbum = const MethodChannel('com.shuyu.gsygithub.gsygithubflutter/UpdateAlbumPlugin');
                  updateAlbum.invokeMethod('updateAlbum', {'path': res, 'name': CommonUtils.splitFileNameByPath(res)});
                }
              }
            });
          },
        ),
        appBar: AppBar(
          title: GSYTitleBar("", rightWidget: GSYCommonOptionWidget(optionControl)),
        ),
        body: Container(
          color: Colors.black,
          child: PhotoView(
            imageProvider: NetworkImage(url ?? GSYICons.DEFAULT_REMOTE_PIC),
            loadingChild: Container(
              child: Stack(
                children: <Widget>[
                  Center(child: Image.asset(GSYICons.DEFAULT_IMAGE, height: 180.0, width: 180.0)),
                  Center(child: SpinKitFoldingCube(color: Colors.white30, size: 60.0)),
                ],
              ),
            ),
          ),
        ));
  }
}
