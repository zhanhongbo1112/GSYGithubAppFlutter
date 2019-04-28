import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gsy_github_app_flutter/src/apps/github-client/_shared/user/provider/user_followed_db_provider.dart';
import 'package:gsy_github_app_flutter/src/apps/github-client/_shared/user/provider/user_follower_db_provider.dart';
import 'package:gsy_github_app_flutter/src/apps/github-client/_shared/user/provider/userinfo_db_provider.dart';
import 'package:gsy_github_app_flutter/src/apps/github-client/_shared/user/provider/user_orgs_db_provider.dart';
import 'package:gsy_github_app_flutter/common/config/config.dart';
import 'package:gsy_github_app_flutter/common/config/ignoreConfig.dart';
import 'package:gsy_github_app_flutter/common/dao/dao_result.dart';
import 'package:gsy_github_app_flutter/common/local/local_storage.dart';
import 'package:gsy_github_app_flutter/src/apps/github-client/models/Notification.dart';
import 'package:gsy_github_app_flutter/src/apps/github-client/models/User.dart';
import 'package:gsy_github_app_flutter/src/apps/github-client/models/UserOrg.dart';
import 'package:gsy_github_app_flutter/src/apps/github-client/constants/apis.dart';
import 'package:gsy_github_app_flutter/common/net/api.dart';
import 'package:gsy_github_app_flutter/common/redux/user_redux.dart';
import 'package:gsy_github_app_flutter/common/utils/common_utils.dart';
import 'package:redux/redux.dart';

class UserDao {
  static login(userName, password, store) async {
    String type = userName + ":" + password;
    var bytes = utf8.encode(type);
    var base64Str = base64.encode(bytes);
    if (Config.DEBUG) {
      print("base64Str login " + base64Str);
    }
    await LocalStorage.save(Config.USER_NAME_KEY, userName);
    await LocalStorage.save(Config.USER_BASIC_CODE, base64Str);

    Map requestParams = {
      "scopes": ['user', 'repo', 'gist', 'notifications'],
      "note": "admin_script",
      "client_id": NetConfig.CLIENT_ID,
      "client_secret": NetConfig.CLIENT_SECRET
    };
    httpManager.clearAuthorization();

    var res = await httpManager.netFetch(GitHubClientApis.getAuthorization(), json.encode(requestParams), null, Options(method: "post"));
    var resultData = null;
    if (res != null && res.result) {
      await LocalStorage.save(Config.PW_KEY, password);
      var resultData = await getUserInfo(null);
      if (Config.DEBUG) {
        print("user result " + resultData.result.toString());
        print(resultData.data);
        print(res.data.toString());
      }
      store.dispatch(UpdateUserAction(resultData.data));
    }
    return DataResult(resultData, res.result);
  }

  ///初始化用户信息
  static initUserInfo(Store store) async {
    var token = await LocalStorage.get(Config.TOKEN_KEY);
    var res = await getUserInfoLocal();
    if (res != null && res.result && token != null) {
      store.dispatch(UpdateUserAction(res.data));
    }

    ///读取主题
    String themeIndex = await LocalStorage.get(Config.THEME_COLOR);
    if (themeIndex != null && themeIndex.length != 0) {
      CommonUtils.pushTheme(store, int.parse(themeIndex));
    }

    ///切换语言
    String localeIndex = await LocalStorage.get(Config.LOCALE);
    if (localeIndex != null && localeIndex.length != 0) {
      CommonUtils.changeLocale(store, int.parse(localeIndex));
    }

    return DataResult(res.data, (res.result && (token != null)));
  }

  ///获取本地登录用户信息
  static getUserInfoLocal() async {
    var userText = await LocalStorage.get(Config.USER_INFO);
    if (userText != null) {
      var userMap = json.decode(userText);
      User user = User.fromJson(userMap);
      return DataResult(user, true);
    } else {
      return DataResult(null, false);
    }
  }

  ///获取用户详细信息
  static getUserInfo(userName, {needDb = false}) async {
    UserInfoDbProvider provider = UserInfoDbProvider();
    next() async {
      var res;
      if (userName == null) {
        res = await httpManager.netFetch(GitHubClientApis.getMyUserInfo(), null, null, null);
      } else {
        res = await httpManager.netFetch(GitHubClientApis.getUserInfo(userName), null, null, null);
      }
      if (res != null && res.result) {
        String starred = "---";
        if (res.data["type"] != "Organization") {
          var countRes = await getUserStaredCountNet(res.data["login"]);
          if (countRes.result) {
            starred = countRes.data;
          }
        }
        User user = User.fromJson(res.data);
        user.starred = starred;
        if (userName == null) {
          LocalStorage.save(Config.USER_INFO, json.encode(user.toJson()));
        } else {
          if (needDb) {
            provider.insert(userName, json.encode(user.toJson()));
          }
        }
        return DataResult(user, true);
      } else {
        return DataResult(res.data, false);
      }
    }

    if (needDb) {
      User user = await provider.getUserInfo(userName);
      if (user == null) {
        return await next();
      }
      DataResult dataResult = DataResult(user, true, next: next());
      return dataResult;
    }
    return await next();
  }

  static clearAll(Store store) async {
    httpManager.clearAuthorization();
    LocalStorage.remove(Config.USER_INFO);
    store.dispatch(UpdateUserAction(User.empty()));
  }

  /**
   * 在header中提起stared count
   */
  static getUserStaredCountNet(userName) async {
    String url = GitHubClientApis.userStar(userName, null) + "&per_page=1";
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result && res.headers != null) {
      try {
        List<String> link = res.headers['link'];
        if (link != null) {
          int indexStart = link[0].lastIndexOf("page=") + 5;
          int indexEnd = link[0].lastIndexOf(">");
          if (indexStart >= 0 && indexEnd >= 0) {
            String count = link[0].substring(indexStart, indexEnd);
            return DataResult(count, true);
          }
        }
      } catch (e) {
        print(e);
      }
    }
    return DataResult(null, false);
  }

  /**
   * 获取用户粉丝列表
   */
  static getFollowerListDao(userName, page, {needDb = false}) async {
    UserFollowerDbProvider provider = UserFollowerDbProvider();

    next() async {
      String url = GitHubClientApis.getUserFollower(userName) + GitHubClientApis.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<User> list = List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(null, false);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(User.fromJson(data[i]));
        }
        if (needDb) {
          provider.insert(userName, json.encode(data));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<User> list = await provider.geData(userName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 获取用户关注列表
   */
  static getFollowedListDao(userName, page, {needDb = false}) async {
    UserFollowedDbProvider provider = UserFollowedDbProvider();
    next() async {
      String url = GitHubClientApis.getUserFollow(userName) + GitHubClientApis.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<User> list = List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(null, false);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(User.fromJson(data[i]));
        }
        if (needDb) {
          provider.insert(userName, json.encode(data));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<User> list = await provider.geData(userName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 获取用户相关通知
   */
  static getNotifyDao(bool all, bool participating, page) async {
    String tag = (!all && !participating) ? '?' : "&";
    String url = GitHubClientApis.getNotifation(all, participating) + GitHubClientApis.getPageParams(tag, page);
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result) {
      List<Notification> list = List();
      var data = res.data;
      if (data == null || data.length == 0) {
        return DataResult([], true);
      }
      for (int i = 0; i < data.length; i++) {
        list.add(Notification.fromJson(data[i]));
      }
      return DataResult(list, true);
    } else {
      return DataResult(null, false);
    }
  }

  /**
   * 设置单个通知已读
   */
  static setNotificationAsReadDao(id) async {
    String url = GitHubClientApis.setNotificationAsRead(id);
    var res = await httpManager.netFetch(url, null, null, Options(method: "PATCH"), noTip: true);
    return res;
  }

  /**
   * 设置所有通知已读
   */
  static setAllNotificationAsReadDao() async {
    String url = GitHubClientApis.setAllNotificationAsRead();
    var res = await httpManager.netFetch(url, null, null, Options(method: "PUT", contentType: ContentType.text));
    return DataResult(res.data, res.result);
  }

  /**
   * 检查用户关注状态
   */
  static checkFollowDao(name) async {
    String url = GitHubClientApis.doFollow(name);
    var res = await httpManager.netFetch(url, null, null, Options(contentType: ContentType.text), noTip: true);
    return DataResult(res.data, res.result);
  }

  /**
   * 关注用户
   */
  static doFollowDao(name, bool followed) async {
    String url = GitHubClientApis.doFollow(name);
    var res = await httpManager.netFetch(url, null, null, Options(method: !followed ? "PUT" : "DELETE"), noTip: true);
    return DataResult(res.data, res.result);
  }

  /**
   * 组织成员
   */
  static getMemberDao(userName, page) async {
    String url = GitHubClientApis.getMember(userName) + GitHubClientApis.getPageParams("?", page);
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result) {
      List<User> list = List();
      var data = res.data;
      if (data == null || data.length == 0) {
        return DataResult(null, false);
      }
      for (int i = 0; i < data.length; i++) {
        list.add(User.fromJson(data[i]));
      }
      return DataResult(list, true);
    } else {
      return DataResult(null, false);
    }
  }

  /**
   * 更新用户信息
   */
  static updateUserDao(params, Store store) async {
    String url = GitHubClientApis.getMyUserInfo();
    var res = await httpManager.netFetch(url, params, null, Options(method: "PATCH"));
    if (res != null && res.result) {
      var localResult = await getUserInfoLocal();
      User newUser = User.fromJson(res.data);
      newUser.starred = localResult.data.starred;
      await LocalStorage.save(Config.USER_INFO, json.encode(newUser.toJson()));
      store.dispatch(UpdateUserAction(newUser));
      return DataResult(newUser, true);
    }
    return DataResult(null, false);
  }

  /**
   * 获取用户组织
   */
  static getUserOrgsDao(userName, page, {needDb = false}) async {
    UserOrgsDbProvider provider = UserOrgsDbProvider();
    next() async {
      String url = GitHubClientApis.getUserOrgs(userName) + GitHubClientApis.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<UserOrg> list = List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(null, false);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(UserOrg.fromJson(data[i]));
        }
        if (needDb) {
          provider.insert(userName, json.encode(data));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<UserOrg> list = await provider.geData(userName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }
}
