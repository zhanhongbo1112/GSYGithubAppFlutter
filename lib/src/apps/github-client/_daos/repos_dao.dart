import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yqboots/src/apps/github-client/_shared/index.dart';
import 'package:package_info/package_info.dart';
import 'package:pub_semver/pub_semver.dart';

import 'package:yqboots/src/core/config/config.dart';
import 'package:yqboots/src/core/dao/dao_result.dart';
import 'package:yqboots/src/core/net/api.dart';
import 'package:yqboots/src/core/utils/common_utils.dart';
import 'package:yqboots/src/apps/github-client/index.dart';

/**
 * Created by guoshuyu
 * Date: 2018-07-16
 */

class ReposDao {
  /**
   * 趋势数据
   * @param page 分页，趋势数据其实没有分页
   * @param since 数据时长， 本日，本周，本月
   * @param languageType 语言
   */
  static getTrendDao({since = 'daily', languageType, page = 0, needDb = true}) async {
    TrendRepositoryDbProvider provider = TrendRepositoryDbProvider();
    String languageTypeDb = languageType ?? "*";

    next() async {
      String url = GitHubClientApis.trending(since, languageType);
      var res = await GitHubTrending().fetchTrending(url);
      if (res != null && res.result && res.data.length > 0) {
        List<TrendingRepoModel> list = List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(null, false);
        }
        if (needDb) {
          provider.insert(languageTypeDb, since, json.encode(data));
        }
        for (int i = 0; i < data.length; i++) {
          TrendingRepoModel model = data[i];
          list.add(model);
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<TrendingRepoModel> list = await provider.getData(languageTypeDb, since);
      if (list != null && list.length > 0) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next());
      return dataResult;
    }
  }

  /**
   * 仓库的详情数据
   */
  static getRepositoryDetailDao(userName, reposName, branch, {needDb = true}) async {
    String fullName = userName + "/" + reposName;
    RepositoryDetailDbProvider provider = RepositoryDetailDbProvider();

    next() async {
      String url = GitHubClientApis.getReposDetail(userName, reposName) + "?ref=" + branch;
      var res = await httpManager.netFetch(url, null, {"Accept": 'application/vnd.github.mercy-preview+json'}, null);
      if (res != null && res.result && res.data.length > 0) {
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(null, false);
        }
        Repository repository = Repository.fromJson(data);
        var issueResult = await ReposDao.getRepositoryIssueStatusDao(userName, reposName);
        if (issueResult != null && issueResult.result) {
          repository.allIssueCount = int.parse(issueResult.data);
        }
        if (needDb) {
          provider.insert(fullName, json.encode(repository.toJson()));
        }
        saveHistoryDao(fullName, DateTime.now(), json.encode(repository.toJson()));
        return DataResult(repository, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      Repository repository = await provider.getRepository(fullName);
      if (repository == null) {
        return await next();
      }
      DataResult dataResult = DataResult(repository, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 仓库活动事件
   */
  static getRepositoryEventDao(userName, reposName, {page = 0, branch = "master", needDb = false}) async {
    String fullName = userName + "/" + reposName;
    RepositoryEventDbProvider provider = RepositoryEventDbProvider();

    next() async {
      String url = GitHubClientApis.getReposEvent(userName, reposName) + GitHubClientApis.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<Event> list = List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(null, false);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(Event.fromJson(data[i]));
        }
        if (needDb) {
          provider.insert(fullName, json.encode(data));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<Event> list = await provider.getEvents(fullName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 获取用户对当前仓库的star、watcher状态
   */
  static getRepositoryStatusDao(userName, reposName) async {
    String urls = GitHubClientApis.resolveStarRepos(userName, reposName);
    String urlw = GitHubClientApis.resolveWatcherRepos(userName, reposName);
    var resS = await httpManager.netFetch(urls, null, null, Options(contentType: ContentType.text), noTip: true);
    var resW = await httpManager.netFetch(urlw, null, null, Options(contentType: ContentType.text), noTip: true);
    var data = {"star": resS.result, "watch": resW.result};
    return DataResult(data, true);
  }

  /**
   * 获取仓库的提交列表
   */
  static getReposCommitsDao(userName, reposName, {page = 0, branch = "master", needDb = false}) async {
    String fullName = userName + "/" + reposName;

    RepositoryCommitsDbProvider provider = RepositoryCommitsDbProvider();

    next() async {
      String url = GitHubClientApis.getReposCommits(userName, reposName) +
          GitHubClientApis.getPageParams("?", page) +
          "&sha=" +
          branch;
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<RepoCommit> list = List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(null, false);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(RepoCommit.fromJson(data[i]));
        }
        if (needDb) {
          provider.insert(fullName, branch, json.encode(data));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<RepoCommit> list = await provider.getData(fullName, branch);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /***
   * 获取仓库的文件列表
   */
  static getReposFileDirDao(userName, reposName, {path = '', branch, text = false, isHtml = false}) async {
    String url = GitHubClientApis.reposDataDir(userName, reposName, path, branch);
    var res = await httpManager.netFetch(
      url,
      null,
      //text ? {"Accept": 'application/vnd.github.VERSION.raw'} : {"Accept": 'application/vnd.github.html'},
      isHtml ? {"Accept": 'application/vnd.github.html'} : {"Accept": 'application/vnd.github.VERSION.raw'},
      Options(contentType: text ? ContentType.text : ContentType.json),
    );
    if (res != null && res.result) {
      if (text) {
        return DataResult(res.data, true);
      }
      List<FileModel> list = List();
      var data = res.data;
      if (data == null || data.length == 0) {
        return DataResult(null, false);
      }
      List<FileModel> dirs = [];
      List<FileModel> files = [];
      for (int i = 0; i < data.length; i++) {
        FileModel file = FileModel.fromJson(data[i]);
        if (file.type == 'file') {
          files.add(file);
        } else {
          dirs.add(file);
        }
      }
      list.addAll(dirs);
      list.addAll(files);
      return DataResult(list, true);
    } else {
      return DataResult(null, false);
    }
  }

  /**
   * star仓库
   */
  static Future<DataResult> doRepositoryStarDao(userName, reposName, star) async {
    String url = GitHubClientApis.resolveStarRepos(userName, reposName);
    var res = await httpManager.netFetch(
        url, null, null, Options(method: !star ? 'PUT' : 'DELETE', contentType: ContentType.text));
    return Future<DataResult>(() {
      return DataResult(null, res.result);
    });
  }

  /**
   * watcher仓库
   */
  static doRepositoryWatchDao(userName, reposName, watch) async {
    String url = GitHubClientApis.resolveWatcherRepos(userName, reposName);
    var res = await httpManager.netFetch(
        url, null, null, Options(method: !watch ? 'PUT' : 'DELETE', contentType: ContentType.text));
    return DataResult(null, res.result);
  }

  /**
   * 获取当前仓库所有订阅用户
   */
  static getRepositoryWatcherDao(userName, reposName, page, {needDb = false}) async {
    String fullName = userName + "/" + reposName;
    RepositoryWatcherDbProvider provider = RepositoryWatcherDbProvider();

    next() async {
      String url = GitHubClientApis.getReposWatcher(userName, reposName) + GitHubClientApis.getPageParams("?", page);
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
          provider.insert(fullName, json.encode(data));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<User> list = await provider.geData(fullName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 获取当前仓库所有star用户
   */
  static getRepositoryStarDao(userName, reposName, page, {needDb = false}) async {
    String fullName = userName + "/" + reposName;
    RepositoryStarDbProvider provider = RepositoryStarDbProvider();
    next() async {
      String url = GitHubClientApis.getReposStar(userName, reposName) + GitHubClientApis.getPageParams("?", page);
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
          provider.insert(fullName, json.encode(data));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<User> list = await provider.geData(fullName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 获取仓库的fork分支
   */
  static getRepositoryForksDao(userName, reposName, page, {needDb = false}) async {
    String fullName = userName + "/" + reposName;
    RepositoryForkDbProvider provider = RepositoryForkDbProvider();
    next() async {
      String url = GitHubClientApis.getReposForks(userName, reposName) + GitHubClientApis.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result && res.data.length > 0) {
        List<Repository> list = List();
        var dataList = res.data;
        if (dataList == null || dataList.length == 0) {
          return DataResult(null, false);
        }
        for (int i = 0; i < dataList.length; i++) {
          var data = dataList[i];
          list.add(Repository.fromJson(data));
        }
        if (needDb) {
          provider.insert(fullName, json.encode(dataList));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<Repository> list = await provider.geData(fullName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 获取用户所有star
   */
  static getStarRepositoryDao(userName, page, sort, {needDb = false}) async {
    UserStaredDbProvider provider = UserStaredDbProvider();
    next() async {
      String url = GitHubClientApis.userStar(userName, sort) + GitHubClientApis.getPageParams("&", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result && res.data.length > 0) {
        List<Repository> list = List();
        var dataList = res.data;
        if (dataList == null || dataList.length == 0) {
          return DataResult(null, false);
        }
        for (int i = 0; i < dataList.length; i++) {
          var data = dataList[i];
          list.add(Repository.fromJson(data));
        }
        if (needDb) {
          provider.insert(userName, json.encode(dataList));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<Repository> list = await provider.geData(userName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 用户的仓库
   */
  static getUserRepositoryDao(userName, page, sort, {needDb = false}) async {
    UserReposDbProvider provider = UserReposDbProvider();
    next() async {
      String url = GitHubClientApis.userRepos(userName, sort) + GitHubClientApis.getPageParams("&", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result && res.data.length > 0) {
        List<Repository> list = List();
        var dataList = res.data;
        if (dataList == null || dataList.length == 0) {
          return DataResult(null, false);
        }
        for (int i = 0; i < dataList.length; i++) {
          var data = dataList[i];
          list.add(Repository.fromJson(data));
        }
        if (needDb) {
          provider.insert(userName, json.encode(dataList));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<Repository> list = await provider.geData(userName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 创建仓库的fork分支
   */
  static createForkDao(userName, reposName) async {
    String url = GitHubClientApis.createFork(userName, reposName);
    var res = await httpManager.netFetch(url, null, null, Options(method: "POST", contentType: ContentType.text));
    return DataResult(null, res.result);
  }

  /**
   * 获取当前仓库所有分支
   */
  static getBranchesDao(userName, reposName) async {
    String url = GitHubClientApis.getbranches(userName, reposName);
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result && res.data.length > 0) {
      List<String> list = List();
      var dataList = res.data;
      if (dataList == null || dataList.length == 0) {
        return DataResult(null, false);
      }
      for (int i = 0; i < dataList.length; i++) {
        var data = dataList[i];
        list.add(data['name']);
      }
      return DataResult(list, true);
    } else {
      return DataResult(null, false);
    }
  }

  /**
   * 用户的前100仓库
   */
  static getUserRepository100StatusDao(userName) async {
    String url = GitHubClientApis.userRepos(userName, 'pushed') + "&page=1&per_page=100";
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result && res.data.length > 0) {
      int stared = 0;
      for (int i = 0; i < res.data.length; i++) {
        var data = res.data[i];
        stared += data["watchers_count"];
      }
      return DataResult(stared, true);
    }
    return DataResult(null, false);
  }

  /**
   * 详情的remde数据
   */
  static getRepositoryDetailReadmeDao(userName, reposName, branch, {needDb = true}) async {
    String fullName = userName + "/" + reposName;
    RepositoryDetailReadmeDbProvider provider = RepositoryDetailReadmeDbProvider();

    next() async {
      String url = GitHubClientApis.readmeFile(userName + '/' + reposName, branch);
      var res = await httpManager.netFetch(
          url, null, {"Accept": 'application/vnd.github.VERSION.raw'}, Options(contentType: ContentType.text));
      //var res = await httpManager.netFetch(url, null, {"Accept": 'application/vnd.github.html'}, Options(contentType: ContentType.text));
      if (res != null && res.result) {
        if (needDb) {
          provider.insert(fullName, branch, res.data);
        }
        return DataResult(res.data, true);
      }
      return DataResult(null, false);
    }

    if (needDb) {
      String readme = await provider.getRepositoryReadme(fullName, branch);
      if (readme == null) {
        return await next();
      }
      DataResult dataResult = DataResult(readme, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 搜索仓库
   * @param q 搜索关键字
   * @param sort 分类排序，beat match、most star等
   * @param order 倒序或者正序
   * @param type 搜索类型，人或者仓库 null \ 'user',
   * @param page
   * @param pageSize
   */
  static searchRepositoryDao(q, language, sort, order, type, page, pageSize) async {
    if (language != null) {
      q = q + "%2Blanguage%3A$language";
    }
    String url = GitHubClientApis.search(q, sort, order, type, page, pageSize);
    var res = await httpManager.netFetch(url, null, null, null);
    if (type == null) {
      if (res != null && res.result && res.data["items"] != null) {
        List<Repository> list = List();
        var dataList = res.data["items"];
        if (dataList == null || dataList.length == 0) {
          return DataResult(null, false);
        }
        for (int i = 0; i < dataList.length; i++) {
          var data = dataList[i];
          list.add(Repository.fromJson(data));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    } else {
      if (res != null && res.result && res.data["items"] != null) {
        List<User> list = List();
        var data = res.data["items"];
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
  }

  /**
   * 获取仓库的单个提交详情
   */
  static getReposCommitsInfoDao(userName, reposName, sha) async {
    String url = GitHubClientApis.getReposCommitsInfo(userName, reposName, sha);
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result) {
      PushCommit pushCommit = PushCommit.fromJson(res.data);
      return DataResult(pushCommit, true);
    } else {
      return DataResult(null, false);
    }
  }

  /**
   * 获取仓库的release列表
   */
  static getRepositoryReleaseDao(userName, reposName, page, {needHtml = true, release = true}) async {
    String url = release
        ? GitHubClientApis.getReposRelease(userName, reposName) + GitHubClientApis.getPageParams("?", page)
        : GitHubClientApis.getReposTag(userName, reposName) + GitHubClientApis.getPageParams("?", page);

    var res = await httpManager.netFetch(url, null,
        {"Accept": (needHtml ? 'application/vnd.github.html,application/vnd.github.VERSION.raw' : "")}, null);
    if (res != null && res.result && res.data.length > 0) {
      List<Release> list = List();
      var dataList = res.data;
      if (dataList == null || dataList.length == 0) {
        return DataResult(null, false);
      }
      for (int i = 0; i < dataList.length; i++) {
        var data = dataList[i];
        list.add(Release.fromJson(data));
      }
      return DataResult(list, true);
    } else {
      return DataResult(null, false);
    }
  }

  /**
   * 版本更新
   */
  static getNewsVersion(context, showTip) async {
    //ios不检查更新
    if (Platform.isIOS) {
      return;
    }
    var res = await getRepositoryReleaseDao("zhanhongbo1112", 'GSYGithubAppFlutter', 1, needHtml: false);
    if (res != null && res.result && res.data.length > 0) {
      Release release = res.data[0];
      String versionName = release.name;
      if (versionName != null) {
        if (Config.DEBUG) {
          print("versionName " + versionName);
        }

        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        var appVersion = packageInfo.version;

        if (Config.DEBUG) {
          print("appVersion " + appVersion);
        }
        Version versionNameNum = Version.parse(versionName);
        Version currentNum = Version.parse(appVersion);
        int result = versionNameNum.compareTo(currentNum);
        if (Config.DEBUG) {
          print("versionNameNum " + versionNameNum.toString() + " currentNum " + currentNum.toString());
        }
        if (Config.DEBUG) {
          print("newsHad " + result.toString());
        }
        if (result > 0) {
          CommonUtils.showUpdateDialog(context, release.name + ": " + release.body);
        } else {
          if (showTip) Fluttertoast.showToast(msg: CommonUtils.getLocale(context).app_not_new_version);
        }
      }
    }
  }

  /**
   * 获取issue总数
   */
  static getRepositoryIssueStatusDao(userName, repository) async {
    String url = GitHubClientApis.getReposIssue(userName, repository, null, null, null) + "&per_page=1";
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
   * 搜索话题
   */
  static searchTopicRepositoryDao(searchTopic, {page = 0}) async {
    String url = GitHubClientApis.searchTopic(searchTopic) + GitHubClientApis.getPageParams("&", page);
    var res = await httpManager.netFetch(url, null, null, null);
    var data = (res.data != null && res.data["items"] != null) ? res.data["items"] : res.data;
    if (res != null && res.result && data != null && data.length > 0) {
      List<Repository> list = List();
      var dataList = data;
      if (dataList == null || dataList.length == 0) {
        return DataResult(null, false);
      }
      for (int i = 0; i < dataList.length; i++) {
        var data = dataList[i];
        list.add(Repository.fromJson(data));
      }
      return DataResult(list, true);
    } else {
      return DataResult(null, false);
    }
  }

  /**
   * 获取阅读历史
   */
  static getHistoryDao(page) async {
    ReadHistoryDbProvider provider = ReadHistoryDbProvider();
    List<Repository> list = await provider.geData(page);
    if (list == null || list.length <= 0) {
      return DataResult(null, false);
    }
    return DataResult(list, true);
  }

  /**
   * 保存阅读历史
   */
  static saveHistoryDao(String fullName, DateTime dateTime, String data) {
    ReadHistoryDbProvider provider = ReadHistoryDbProvider();
    provider.insert(fullName, dateTime, data);
  }
}
