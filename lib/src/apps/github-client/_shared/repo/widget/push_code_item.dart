import 'package:flutter/material.dart';
import 'package:gsy_github_app_flutter/src/apps/github-client/index.dart';
import '../../../../../../common/common.dart';
import '../../../../../../widget/widget.dart';

/// 推送修改代码Item
class PushCodeItem extends StatelessWidget {
  final PushCodeItemViewModel pushCodeItemViewModel;
  final VoidCallback onPressed;

  PushCodeItem(this.pushCodeItemViewModel, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Container(
        ///修改文件路径
        margin: EdgeInsets.only(left: 10.0, top: 5.0, right: 10.0, bottom: 0.0),
        child: Text(
          pushCodeItemViewModel.path,
          style: GSYConstant.smallSubLightText,
        ),
      ),
      GSYCardItem(
        ///修改文件名
        margin: EdgeInsets.only(left: 10.0, top: 5.0, right: 10.0, bottom: 5.0),
        child: ListTile(
          title: Text(pushCodeItemViewModel.name, style: GSYConstant.smallSubText),
          leading: Icon(
            GSYICons.REPOS_ITEM_FILE,
            size: 15.0,
          ),
          onTap: () {
            onPressed();
          },
        ),
      ),
    ]);
  }
}

class PushCodeItemViewModel {
  String path;
  String name;
  String patch;

  String blob_url;

  PushCodeItemViewModel();

  PushCodeItemViewModel.fromMap(CommitFile map) {
    String filename = map.fileName;
    List<String> nameSplit = filename.split("/");
    name = nameSplit[nameSplit.length - 1];
    path = filename;
    patch = map.patch;
    blob_url = map.blobUrl;
  }
}
