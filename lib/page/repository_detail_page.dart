import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:gsy_github_app_flutter/src/apps/github-client/index.dart';

import '../common/common.dart';
import '../widget/widget.dart';
import '../page/page.dart';

/// 仓库详情
class RepositoryDetailPage extends StatefulWidget {
  final String userName;

  final String reposName;

  RepositoryDetailPage(this.userName, this.reposName);

  @override
  _RepositoryDetailPageState createState() => _RepositoryDetailPageState(userName, reposName);
}

class _RepositoryDetailPageState extends State<RepositoryDetailPage> {
  ReposHeaderViewModel reposHeaderViewModel = ReposHeaderViewModel();

  BottomStatusModel bottomStatusModel;

  final String userName;

  final String reposName;

  final TarWidgetControl tarBarControl = TarWidgetControl();

  final ReposDetailModel reposDetailModel = ReposDetailModel();

  final OptionControl titleOptionControl = OptionControl();

  GlobalKey<RepositoryDetailFileListPageState> fileListKey = GlobalKey<RepositoryDetailFileListPageState>();

  GlobalKey<ReposDetailInfoPageState> infoListKey = GlobalKey<ReposDetailInfoPageState>();

  GlobalKey<RepositoryDetailReadmePageState> readmeKey = GlobalKey<RepositoryDetailReadmePageState>();

  List<String> branchList = List();

  _RepositoryDetailPageState(this.userName, this.reposName);

  _getReposStatus() async {
    var result = await ReposDao.getRepositoryStatusDao(userName, reposName);
    String watchText = result.data["watch"] ? "UnWatch" : "Watch";
    String starText = result.data["star"] ? "UnStar" : "Star";
    IconData watchIcon = result.data["watch"] ? GSYICons.REPOS_ITEM_WATCHED : GSYICons.REPOS_ITEM_WATCH;
    IconData starIcon = result.data["star"] ? GSYICons.REPOS_ITEM_STARED : GSYICons.REPOS_ITEM_STAR;
    BottomStatusModel model =
        BottomStatusModel(watchText, starText, watchIcon, starIcon, result.data["watch"], result.data["star"]);
    setState(() {
      bottomStatusModel = model;
      tarBarControl.footerButton = _getBottomWidget();
    });
  }

  _getBranchList() async {
    var result = await ReposDao.getBranchesDao(userName, reposName);
    if (result != null && result.result) {
      setState(() {
        branchList = result.data;
      });
    }
  }

  _refresh() {
    this._getReposStatus();
  }

  _renderBottomItem(var text, var icon, var onPressed) {
    return FlatButton(
        onPressed: onPressed,
        child: GSYIConText(
          icon,
          text,
          GSYConstant.smallText,
          Color(GSYColors.primaryValue),
          15.0,
          padding: 5.0,
          mainAxisAlignment: MainAxisAlignment.center,
        ));
  }

  _getBottomWidget() {
    List<Widget> bottomWidget = (bottomStatusModel == null)
        ? []
        : <Widget>[
            _renderBottomItem(bottomStatusModel.starText, bottomStatusModel.starIcon, () {
              CommonUtils.showLoadingDialog(context);
              return ReposDao.doRepositoryStarDao(userName, reposName, bottomStatusModel.star).then((result) {
                _refresh();
                Navigator.pop(context);
              });
            }),
            _renderBottomItem(bottomStatusModel.watchText, bottomStatusModel.watchIcon, () {
              CommonUtils.showLoadingDialog(context);
              return ReposDao.doRepositoryWatchDao(userName, reposName, bottomStatusModel.watch).then((result) {
                _refresh();
                Navigator.pop(context);
              });
            }),
            _renderBottomItem("fork", GSYICons.REPOS_ITEM_FORK, () {
              CommonUtils.showLoadingDialog(context);
              return ReposDao.createForkDao(userName, reposName).then((result) {
                _refresh();
                Navigator.pop(context);
              });
            }),
          ];
    return bottomWidget;
  }

  ///无奈之举，只能pageView配合tabbar，通过control同步
  ///TabView 配合tabbar 在四个页面上问题太多
  _renderTabItem() {
    var itemList = [
      CommonUtils.getLocale(context).repos_tab_info,
      CommonUtils.getLocale(context).repos_tab_readme,
      CommonUtils.getLocale(context).repos_tab_issue,
      CommonUtils.getLocale(context).repos_tab_file,
    ];
    renderItem(String item, int i) {
      return Container(
          padding: EdgeInsets.all(0.0),
          child: Text(
            item,
            style: GSYConstant.smallTextWhite,
            maxLines: 1,
          ));
    }

    List<Widget> list = List();
    for (int i = 0; i < itemList.length; i++) {
      list.add(renderItem(itemList[i], i));
    }
    return list;
  }

  _getMoreOtherItem() {
    return [
      ///Release Page
      GSYOptionModel(
          CommonUtils.getLocale(context).repos_option_release, CommonUtils.getLocale(context).repos_option_release,
          (model) {
        String releaseUrl = "";
        String tagUrl = "";
        if (infoListKey == null || infoListKey.currentState == null) {
          releaseUrl = GSYConstant.app_default_share_url;
          tagUrl = GSYConstant.app_default_share_url;
        } else {
          releaseUrl = infoListKey.currentState.repository == null
              ? GSYConstant.app_default_share_url
              : infoListKey.currentState.repository.htmlUrl + "/releases";
          tagUrl = infoListKey.currentState.repository == null
              ? GSYConstant.app_default_share_url
              : infoListKey.currentState.repository.htmlUrl + "/tags";
        }
        NavigatorUtils.goReleasePage(context, userName, reposName, releaseUrl, tagUrl);
      }),

      ///Branch Page
      GSYOptionModel(
          CommonUtils.getLocale(context).repos_option_branch, CommonUtils.getLocale(context).repos_option_branch,
          (model) {
        if (branchList.length == 0) {
          return;
        }
        CommonUtils.showCommitOptionDialog(context, branchList, (value) {
          setState(() {
            reposDetailModel.setCurrentBranch(branchList[value]);
          });
          if (infoListKey.currentState != null && infoListKey.currentState.mounted) {
            infoListKey.currentState.showRefreshLoading();
          }
          if (fileListKey.currentState != null && fileListKey.currentState.mounted) {
            fileListKey.currentState.showRefreshLoading();
          }
          if (readmeKey.currentState != null && readmeKey.currentState.mounted) {
            readmeKey.currentState.refreshReadme();
          }
        });
      }),
    ];
  }

  @override
  void initState() {
    super.initState();
    _getBranchList();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = GSYCommonOptionWidget(titleOptionControl, otherList: _getMoreOtherItem());
    return ScopedModel<ReposDetailModel>(
      model: reposDetailModel,
      child: ScopedModelDescendant<ReposDetailModel>(
        builder: (context, child, model) {
          return GSYTabBarWidget(
            type: GSYTabBarWidget.TOP_TAB,
            tarWidgetControl: tarBarControl,
            tabItems: _renderTabItem(),
            tabViews: [
              ReposDetailInfoPage(userName, reposName, titleOptionControl, key: infoListKey),
              RepositoryDetailReadmePage(userName, reposName, key: readmeKey),
              RepositoryDetailIssuePage(userName, reposName),
              RepositoryDetailFileListPage(userName, reposName, key: fileListKey),
            ],
            backgroundColor: GSYColors.primarySwatch,
            indicatorColor: Color(GSYColors.white),
            title: GSYTitleBar(
              reposName,
              rightWidget: widget,
            ),
            onPageChanged: (index) {
              reposDetailModel.setCurrentIndex(index);
            },
          );
        },
      ),
    );
  }
}

class BottomStatusModel {
  final String watchText;
  final String starText;
  final IconData watchIcon;
  final IconData starIcon;
  final bool star;
  final bool watch;

  BottomStatusModel(this.watchText, this.starText, this.watchIcon, this.starIcon, this.watch, this.star);
}

class ReposDetailModel extends Model {
  int _currentIndex = 0;

  String _currentBranch = "master";

  String get currentBranch => _currentBranch;

  int get currentIndex => _currentIndex;

  static ReposDetailModel of(BuildContext context) => ScopedModel.of<ReposDetailModel>(context);

  void setCurrentBranch(String branch) {
    _currentBranch = branch;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
