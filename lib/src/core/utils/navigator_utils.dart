import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yqboots/src/apps/github-client/_constants/routes.dart';
import 'package:yqboots/src/apps/github-client/_shared/common_list_page.dart';
import 'package:yqboots/src/apps/github-client/_shared/issue/issue_detail_page.dart';
import 'package:yqboots/src/apps/github-client/_shared/login_page.dart';
import 'package:yqboots/src/apps/github-client/_shared/repo/code_detail_page.dart';
import 'package:yqboots/src/apps/github-client/_shared/repo/code_detail_page_web.dart';
import 'package:yqboots/src/apps/github-client/_shared/repo/push_detail_page.dart';
import 'package:yqboots/src/apps/github-client/_shared/repo/release_page.dart';
import 'package:yqboots/src/apps/github-client/_shared/repo/repository_detail_page.dart';
import 'package:yqboots/src/apps/github-client/_shared/search_page.dart';
import 'package:yqboots/src/apps/github-client/_shared/user/notify_page.dart';
import 'package:yqboots/src/apps/github-client/_shared/user/person_page.dart';
import 'package:yqboots/src/apps/github-client/_shared/user/user_profile_page.dart';
import 'package:yqboots/src/core/page/gsy_webview.dart';
import 'package:yqboots/src/core/page/photoview_page.dart';

/// 导航栏
class NavigatorUtils {
  ///替换
  static pushReplacementNamed(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  ///切换无参数页面
  static pushNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  /// 主页
  static goHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, GitHubClientRoutes.HOME);
  }

  ///登录页
  static goLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, LoginPage.sName);
  }

  ///个人中心
  static goPerson(BuildContext context, String userName) {
    NavigatorRouter(context, PersonPage(userName));
  }

  ///仓库详情
  static Future goReposDetail(BuildContext context, String userName, String reposName) {
    return NavigatorRouter(context, RepositoryDetailPage(userName, reposName));
  }

  ///仓库版本列表
  static Future goReleasePage(
      BuildContext context, String userName, String reposName, String releaseUrl, String tagUrl) {
    return NavigatorRouter(
        context,
        ReleasePage(
          userName,
          reposName,
          releaseUrl,
          tagUrl,
        ));
  }

  ///issue详情
  static Future goIssueDetail(BuildContext context, String userName, String reposName, String num,
      {bool needRightLocalIcon = false}) {
    return NavigatorRouter(
        context,
        IssueDetailPage(
          userName,
          reposName,
          num,
          needHomeIcon: needRightLocalIcon,
        ));
  }

  ///通用列表
  static gotoCommonList(BuildContext context, String title, String showType, String dataType,
      {String userName, String reposName}) {
    NavigatorRouter(
        context,
        CommonListPage(
          title,
          showType,
          dataType,
          userName: userName,
          reposName: reposName,
        ));
  }

  ///文件代码详情
  static gotoCodeDetailPage(BuildContext context,
      {String title, String userName, String reposName, String path, String data, String branch, String htmlUrl}) {
    NavigatorRouter(
        context,
        CodeDetailPage(
          title: title,
          userName: userName,
          reposName: reposName,
          path: path,
          data: data,
          branch: branch,
          htmlUrl: htmlUrl,
        ));
  }

  ///仓库详情通知
  static Future goNotifyPage(BuildContext context) {
    return NavigatorRouter(context, NotifyPage());
  }

  ///搜索
  static Future goSearchPage(BuildContext context) {
    return NavigatorRouter(context, SearchPage());
  }

  ///提交详情
  static Future goPushDetailPage(
      BuildContext context, String userName, String reposName, String sha, bool needHomeIcon) {
    return NavigatorRouter(
        context,
        PushDetailPage(
          sha,
          userName,
          reposName,
          needHomeIcon: needHomeIcon,
        ));
  }

  ///全屏Web页面
  static Future goGSYWebView(BuildContext context, String url, String title) {
    return NavigatorRouter(context, GSYWebView(url, title));
  }

  ///文件代码详情Web
  static gotoCodeDetailPageWeb(BuildContext context,
      {String title, String userName, String reposName, String path, String data, String branch, String htmlUrl}) {
    NavigatorRouter(
        context,
        CodeDetailPageWeb(
          title: title,
          userName: userName,
          reposName: reposName,
          path: path,
          data: data,
          branch: branch,
          htmlUrl: htmlUrl,
        ));
  }

  ///根据平台跳转文件代码详情Web
  static gotoCodeDetailPlatform(BuildContext context,
      {String title, String userName, String reposName, String path, String data, String branch, String htmlUrl}) {
    NavigatorUtils.gotoCodeDetailPageWeb(
      context,
      title: title,
      reposName: reposName,
      userName: userName,
      path: path,
      branch: branch,
    );
  }

  ///图片预览
  static gotoPhotoViewPage(BuildContext context, String url) {
    NavigatorRouter(context, PhotoViewPage(url));
  }

  ///用户配置
  static gotoUserProfileInfo(BuildContext context) {
    NavigatorRouter(context, UserProfileInfo());
  }

  static NavigatorRouter(BuildContext context, Widget widget) {
    return Navigator.push(context, CupertinoPageRoute(builder: (context) => widget));
  }
}
