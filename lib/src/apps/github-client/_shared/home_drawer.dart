import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:yqboots/src/apps/github-client/_daos/index.dart';
import 'package:yqboots/src/apps/github-client/index.dart';

import 'package:yqboots/src/core/core.dart';

import 'package:yqboots/src/widgets/gsy_flex_button.dart';
import 'package:package_info/package_info.dart';
import 'package:redux/redux.dart';

/**
 * 主页drawer
 * Created by guoshuyu
 * Date: 2018-07-18
 */
class HomeDrawer extends StatelessWidget {
  showAboutDialog(BuildContext context, String versionName) {
    versionName ??= "Null";
    showDialog(
        context: context,
        builder: (BuildContext context) => AboutDialog(
              applicationName: CommonUtils.getLocale(context).app_name,
              applicationVersion: CommonUtils.getLocale(context).app_version + ": " + versionName,
              applicationIcon: Image(image: AssetImage(GSYICons.DEFAULT_USER_ICON), width: 50.0, height: 50.0),
              applicationLegalese: "http://github.com/CarGuo",
            ));
  }

  showThemeDialog(BuildContext context, Store store) {
    List<String> list = [
      CommonUtils.getLocale(context).home_theme_default,
      CommonUtils.getLocale(context).home_theme_1,
      CommonUtils.getLocale(context).home_theme_2,
      CommonUtils.getLocale(context).home_theme_3,
      CommonUtils.getLocale(context).home_theme_4,
      CommonUtils.getLocale(context).home_theme_5,
      CommonUtils.getLocale(context).home_theme_6,
    ];
    CommonUtils.showCommitOptionDialog(context, list, (index) {
      CommonUtils.pushTheme(store, index);
      LocalStorage.save(Config.THEME_COLOR, index.toString());
    }, colorList: CommonUtils.getThemeListColor());
  }

  showLanguageDialog(BuildContext context, Store store) {
    List<String> list = [
      CommonUtils.getLocale(context).home_language_default,
      CommonUtils.getLocale(context).home_language_zh,
      CommonUtils.getLocale(context).home_language_en,
    ];
    CommonUtils.showCommitOptionDialog(context, list, (index) {
      CommonUtils.changeLocale(store, index);
      LocalStorage.save(Config.LOCALE, index.toString());
    }, height: 150.0);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: StoreBuilder<GSYState>(
        builder: (context, store) {
          User user = store.state.userInfo;
          return Drawer(
            ///侧边栏按钮Drawer
            child: Container(
              ///默认背景
              color: store.state.themeData.primaryColor,
              child: SingleChildScrollView(
                ///item 背景
                child: Container(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                  child: Material(
                    color: Color(GSYColors.white),
                    child: Column(
                      children: <Widget>[
                        UserAccountsDrawerHeader(
                          //Material内置控件
                          accountName: Text(
                            user.login ?? "---",
                            style: GSYConstant.largeTextWhite,
                          ),
                          accountEmail: Text(
                            user.email ?? user.name ?? "---",
                            style: GSYConstant.normalTextLight,
                          ),
                          //用户名
                          //用户邮箱
                          currentAccountPicture: GestureDetector(
                            //用户头像
                            onTap: () {},
                            child: CircleAvatar(
                              //圆形图标控件
                              backgroundImage: NetworkImage(user.avatar_url ?? GSYICons.DEFAULT_REMOTE_PIC),
                            ),
                          ),
                          decoration: BoxDecoration(
                            //用一个BoxDecoration装饰器提供背景图片
                            color: store.state.themeData.primaryColor,
                          ),
                        ),
                        ListTile(
                            title: Text(
                              CommonUtils.getLocale(context).home_reply,
                              style: GSYConstant.normalText,
                            ),
                            onTap: () {
                              String content = "";
                              CommonUtils.showEditDialog(context, CommonUtils.getLocale(context).home_reply, (title) {},
                                  (res) {
                                content = res;
                              }, () {
                                if (content == null || content.length == 0) {
                                  return;
                                }
                                CommonUtils.showLoadingDialog(context);
                                IssueDao.createIssueDao("CarGuo", "GSYGithubAppFlutter", {
                                  "title": CommonUtils.getLocale(context).home_reply,
                                  "body": content
                                }).then((result) {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                });
                              },
                                  titleController: TextEditingController(),
                                  valueController: TextEditingController(),
                                  needTitle: false);
                            }),
                        ListTile(
                            title: Text(
                              CommonUtils.getLocale(context).home_history,
                              style: GSYConstant.normalText,
                            ),
                            onTap: () {
                              NavigatorUtils.gotoCommonList(
                                  context, CommonUtils.getLocale(context).home_history, "repository", "history",
                                  userName: "", reposName: "");
                            }),
                        ListTile(
                            title: Hero(
                                tag: "home_user_info",
                                child: Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      CommonUtils.getLocale(context).home_user_info,
                                      style: GSYConstant.normalTextBold,
                                    ))),
                            onTap: () {
                              NavigatorUtils.gotoUserProfileInfo(context);
                            }),
                        ListTile(
                            title: Text(
                              CommonUtils.getLocale(context).home_change_theme,
                              style: GSYConstant.normalText,
                            ),
                            onTap: () {
                              showThemeDialog(context, store);
                            }),
                        ListTile(
                            title: Text(
                              CommonUtils.getLocale(context).home_change_language,
                              style: GSYConstant.normalText,
                            ),
                            onTap: () {
                              showLanguageDialog(context, store);
                            }),
                        ListTile(
                            title: Text(
                              CommonUtils.getLocale(context).home_check_update,
                              style: GSYConstant.normalText,
                            ),
                            onTap: () {
                              ReposDao.getNewsVersion(context, true);
                            }),
                        ListTile(
                            title: Text(
                              GSYLocalizations.of(context).currentLocalized.home_about,
                              style: GSYConstant.normalText,
                            ),
                            onTap: () {
                              PackageInfo.fromPlatform().then((value) {
                                print(value);
                                showAboutDialog(context, value.version);
                              });
                            }),
                        ListTile(
                            title: GSYFlexButton(
                              text: CommonUtils.getLocale(context).Login_out,
                              color: Colors.redAccent,
                              textColor: Color(GSYColors.textWhite),
                              onPress: () {
                                UserDao.clearAll(store);
                                SqlManager.close();
                                NavigatorUtils.goLogin(context);
                              },
                            ),
                            onTap: () {}),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
