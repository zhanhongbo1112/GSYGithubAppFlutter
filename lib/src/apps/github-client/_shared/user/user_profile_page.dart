import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gsy_github_app_flutter/src/apps/github-client/index.dart';
import 'package:redux/redux.dart';

import '../../../../../common/common.dart';
import '../../../../../widget/widget.dart';

/// 用户信息中心
class UserProfileInfo extends StatefulWidget {
  UserProfileInfo();

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfileInfo> {
  _renderItem(IconData leftIcon, String title, String value, VoidCallback onPressed) {
    return GSYCardItem(
      child: RawMaterialButton(
        onPressed: onPressed,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.all(15.0),
        constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
        child: Row(
          children: <Widget>[
            Icon(leftIcon),
            Container(
              width: 10.0,
            ),
            Text(title, style: GSYConstant.normalSubText),
            Container(
              width: 10.0,
            ),
            Expanded(child: Text(value, style: GSYConstant.normalText)),
            Container(
              width: 10.0,
            ),
            Icon(GSYICons.REPOS_ITEM_NEXT, size: 12.0),
          ],
        ),
      ),
    );
  }

  static const String user_profile_name = "名字";
  static const String user_profile_email = "邮箱";
  static const String user_profile_link = "链接";
  static const String user_profile_org = "公司";
  static const String user_profile_location = "位置";
  static const String user_profile_info = "简介";

  _showEditDialog(String title, String value, String key, Store store) {
    String content = value ?? "";
    CommonUtils.showEditDialog(context, title, (title) {}, (res) {
      content = res;
    }, () {
      if (content == null || content.length == 0) {
        return;
      }
      CommonUtils.showLoadingDialog(context);

      UserDao.updateUserDao({key: content}, store).then((res) {
        Navigator.of(context).pop();
        if (res != null && res.result) {
          Navigator.of(context).pop();
        }
      });
    }, titleController: TextEditingController(), valueController: TextEditingController(text: value), needTitle: false);
  }

  List<Widget> _renderList(User userInfo, Store store) {
    return [
      _renderItem(Icons.info, CommonUtils.getLocale(context).user_profile_name, userInfo.name ?? "---", () {
        _showEditDialog(CommonUtils.getLocale(context).user_profile_name, userInfo.name, "name", store);
      }),
      _renderItem(Icons.email, CommonUtils.getLocale(context).user_profile_email, userInfo.email ?? "---", () {
        _showEditDialog(CommonUtils.getLocale(context).user_profile_email, userInfo.email, "email", store);
      }),
      _renderItem(Icons.link, CommonUtils.getLocale(context).user_profile_link, userInfo.blog ?? "---", () {
        _showEditDialog(CommonUtils.getLocale(context).user_profile_link, userInfo.blog, "blog", store);
      }),
      _renderItem(Icons.group, CommonUtils.getLocale(context).user_profile_org, userInfo.company ?? "---", () {
        _showEditDialog(CommonUtils.getLocale(context).user_profile_org, userInfo.company, "company", store);
      }),
      _renderItem(Icons.location_on, CommonUtils.getLocale(context).user_profile_location, userInfo.location ?? "---",
          () {
        _showEditDialog(CommonUtils.getLocale(context).user_profile_location, userInfo.location, "location", store);
      }),
      _renderItem(Icons.message, CommonUtils.getLocale(context).user_profile_info, userInfo.bio ?? "---", () {
        _showEditDialog(CommonUtils.getLocale(context).user_profile_info, userInfo.bio, "bio", store);
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GSYState>(builder: (context, store) {
      return Scaffold(
        appBar: AppBar(
          title: Hero(
            tag: "home_user_info",
            child: Material(
              color: Colors.transparent,
              child: Text(
                CommonUtils.getLocale(context).home_user_info,
                style: GSYConstant.normalTextWhite,
              ),
            ),
          ),
        ),
        body: Container(
          color: Color(GSYColors.white),
          child: SingleChildScrollView(
            child: Column(
              children: _renderList(store.state.userInfo, store),
            ),
          ),
        ),
      );
    });
  }
}
