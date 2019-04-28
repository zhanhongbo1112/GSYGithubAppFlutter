import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:yqboots/common/dao/dao_result.dart';
import 'package:yqboots/common/net/api.dart';
import 'package:yqboots/src/apps/github-client/_constants/index.dart';
import 'package:yqboots/src/apps/github-client/_models/index.dart';
import 'package:yqboots/src/apps/github-client/_shared/index.dart';

/**
 * Issue相关
 * Created by guoshuyu
 * Date: 2018-07-19
 */

class IssueDao {
  /**
   * 获取仓库issue
   * @param page
   * @param userName
   * @param repository
   * @param state issue状态
   * @param sort 排序类型 created updated等
   * @param direction 正序或者倒序
   */
  static getRepositoryIssueDao(userName, repository, state, {sort, direction, page = 0, needDb = false}) async {
    String fullName = userName + "/" + repository;
    String dbState = state ?? "*";
    RepositoryIssueDbProvider provider = RepositoryIssueDbProvider();

    next() async {
      String url = GitHubClientApis.getReposIssue(userName, repository, state, sort, direction) +
          GitHubClientApis.getPageParams("&", page);
      var res = await httpManager.netFetch(
          url, null, {"Accept": 'application/vnd.github.html,application/vnd.github.VERSION.raw'}, null);
      if (res != null && res.result) {
        List<Issue> list = List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(null, false);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(Issue.fromJson(data[i]));
        }
        if (needDb) {
          provider.insert(fullName, dbState, json.encode(data));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<Issue> list = await provider.getData(fullName, dbState);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 搜索仓库issue
   * @param q 搜索关键字
   * @param name 用户名
   * @param reposName 仓库名
   * @param page
   * @param state 问题状态，all open closed
   */
  static searchRepositoryIssue(q, name, reposName, state, {page = 1}) async {
    String qu;
    if (state == null || state == 'all') {
      qu = q + "+repo%3A${name}%2F${reposName}";
    } else {
      qu = q + "+repo%3A${name}%2F${reposName}+state%3A${state}";
    }
    String url = GitHubClientApis.repositoryIssueSearch(qu) + GitHubClientApis.getPageParams("&", page);
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result) {
      List<Issue> list = List();
      var data = res.data["items"];
      if (data == null || data.length == 0) {
        return DataResult(null, false);
      }
      for (int i = 0; i < data.length; i++) {
        list.add(Issue.fromJson(data[i]));
      }
      return DataResult(list, true);
    } else {
      return DataResult(null, false);
    }
  }

  /**
   * issue的详请
   */
  static getIssueInfoDao(userName, repository, number, {needDb = true}) async {
    String fullName = userName + "/" + repository;

    IssueDetailDbProvider provider = IssueDetailDbProvider();

    next() async {
      String url = GitHubClientApis.getIssueInfo(userName, repository, number);
      //{"Accept": 'application/vnd.github.html,application/vnd.github.VERSION.raw'}
      var res = await httpManager.netFetch(url, null, {"Accept": 'application/vnd.github.VERSION.raw'}, null);
      if (res != null && res.result) {
        if (needDb) {
          provider.insert(fullName, number, json.encode(res.data));
        }
        return DataResult(Issue.fromJson(res.data), true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      Issue issue = await provider.getRepository(fullName, number);
      if (issue == null) {
        return await next();
      }
      DataResult dataResult = DataResult(issue, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * issue的详请列表
   */
  static getIssueCommentDao(userName, repository, number, {page: 0, needDb = false}) async {
    String fullName = userName + "/" + repository;
    IssueCommentDbProvider provider = IssueCommentDbProvider();

    next() async {
      String url =
          GitHubClientApis.getIssueComment(userName, repository, number) + GitHubClientApis.getPageParams("?", page);
      //{"Accept": 'application/vnd.github.html,application/vnd.github.VERSION.raw'}
      var res = await httpManager.netFetch(url, null, {"Accept": 'application/vnd.github.VERSION.raw'}, null);
      if (res != null && res.result) {
        List<Issue> list = List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(null, false);
        }
        if (needDb) {
          provider.insert(fullName, number, json.encode(res.data));
        }
        for (int i = 0; i < data.length; i++) {
          list.add(Issue.fromJson(data[i]));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<Issue> list = await provider.getData(fullName, number);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next());
      return dataResult;
    }
    return await next();
  }

  /**
   * 增加issue的回复
   */
  static addIssueCommentDao(userName, repository, number, comment) async {
    String url = GitHubClientApis.addIssueComment(userName, repository, number);
    var res = await httpManager.netFetch(
        url, {"body": comment}, {"Accept": 'application/vnd.github.VERSION.full+json'}, Options(method: 'POST'));
    if (res != null && res.result) {
      return DataResult(res.data, true);
    } else {
      return DataResult(null, false);
    }
  }

  /**
   * 编辑issue
   */
  static editIssueDao(userName, repository, number, issue) async {
    String url = GitHubClientApis.editIssue(userName, repository, number);
    var res = await httpManager.netFetch(
        url, issue, {"Accept": 'application/vnd.github.VERSION.full+json'}, Options(method: 'PATCH'));
    if (res != null && res.result) {
      return DataResult(res.data, true);
    } else {
      return DataResult(null, false);
    }
  }

  /**
   * 锁定issue
   */
  static lockIssueDao(userName, repository, number, locked) async {
    String url = GitHubClientApis.lockIssue(userName, repository, number);
    var res = await httpManager.netFetch(url, null, {"Accept": 'application/vnd.github.VERSION.full+json'},
        Options(method: locked ? "DELETE" : 'PUT', contentType: ContentType.text),
        noTip: true);
    if (res != null && res.result) {
      return DataResult(res.data, true);
    } else {
      return DataResult(null, false);
    }
  }

  /**
   * 创建issue
   */
  static createIssueDao(userName, repository, issue) async {
    String url = GitHubClientApis.createIssue(userName, repository);
    var res = await httpManager.netFetch(
        url, issue, {"Accept": 'application/vnd.github.VERSION.full+json'}, Options(method: 'POST'));
    if (res != null && res.result) {
      return DataResult(res.data, true);
    } else {
      return DataResult(null, false);
    }
  }

  /**
   * 编辑issue回复
   */
  static editCommentDao(userName, repository, number, commentId, comment) async {
    String url = GitHubClientApis.editComment(userName, repository, commentId);
    var res = await httpManager.netFetch(
        url, comment, {"Accept": 'application/vnd.github.VERSION.full+json'}, Options(method: 'PATCH'));
    if (res != null && res.result) {
      return DataResult(res.data, true);
    } else {
      return DataResult(null, false);
    }
  }

  /**
   * 删除issue回复
   */
  static deleteCommentDao(userName, repository, number, commentId) async {
    String url = GitHubClientApis.editComment(userName, repository, commentId);
    var res = await httpManager.netFetch(url, null, null, Options(method: 'DELETE'), noTip: true);
    if (res != null && res.result) {
      return DataResult(res.data, true);
    } else {
      return DataResult(null, false);
    }
  }
}
