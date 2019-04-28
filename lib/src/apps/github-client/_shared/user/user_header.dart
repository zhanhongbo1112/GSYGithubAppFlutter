import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gsy_github_app_flutter/src/apps/github-client/index.dart';
import '../../../../../common/common.dart';
import '../../../../../widget/widget.dart';

/**
 * 用户详情头部
 * Created by guoshuyu
 * Date: 2018-07-17
 */
class UserHeaderItem extends StatelessWidget {
  final User userInfo;

  final String beStaredCount;

  final Color notifyColor;

  final Color themeColor;

  final VoidCallback refreshCallBack;

  final List<UserOrg> orgList;

  UserHeaderItem(this.userInfo, this.beStaredCount, this.themeColor,
      {this.notifyColor, this.refreshCallBack, this.orgList});

  ///底部状态栏
  _getBottomItem(String title, var value, onPressed) {
    String data = value == null ? "" : value.toString();
    TextStyle valueStyle =
        (value != null && value.toString().length > 6) ? GSYConstant.minText : GSYConstant.smallSubLightText;
    TextStyle titleStyle =
        (title != null && title.toString().length > 6) ? GSYConstant.minText : GSYConstant.smallSubLightText;
    return Expanded(
      child: Center(
          child: RawMaterialButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.only(top: 5.0),
              constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(text: title, style: titleStyle),
                    TextSpan(text: "\n", style: valueStyle),
                    TextSpan(text: data, style: valueStyle)
                  ],
                ),
              ),
              onPressed: onPressed)),
    );
  }

  ///通知ICon
  _getNotifyIcon(BuildContext context, Color color) {
    if (notifyColor == null) {
      return Container();
    }
    return RawMaterialButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.only(top: 0.0, right: 5.0, left: 5.0),
        constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
        child: ClipOval(
          child: Icon(
            GSYICons.USER_NOTIFY,
            color: color,
            size: 18.0,
          ),
        ),
        onPressed: () {
          NavigatorUtils.goNotifyPage(context).then((res) {
            refreshCallBack?.call();
          });
        });
  }

  ///用户组织
  _renderOrgs(BuildContext context, List<UserOrg> orgList) {
    if (orgList == null || orgList.length == 0) {
      return Container();
    }
    List<Widget> list = List();

    renderOrgsItem(UserOrg orgs) {
      return GSYUserIconWidget(
          padding: const EdgeInsets.only(right: 5.0, left: 5.0),
          width: 30.0,
          height: 30.0,
          image: orgs.avatarUrl ?? GSYICons.DEFAULT_REMOTE_PIC,
          onPressed: () {
            NavigatorUtils.goPerson(context, orgs.login);
          });
    }

    int length = orgList.length > 3 ? 3 : orgList.length;

    list.add(Text(CommonUtils.getLocale(context).user_orgs_title + ":", style: GSYConstant.smallSubLightText));

    for (int i = 0; i < length; i++) {
      list.add(renderOrgsItem(orgList[i]));
    }
    if (orgList.length > 3) {
      list.add(RawMaterialButton(
          onPressed: () {
            NavigatorUtils.gotoCommonList(
                context, userInfo.login + " " + CommonUtils.getLocale(context).user_orgs_title, "org", "user_orgs",
                userName: userInfo.login);
          },
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.only(right: 5.0, left: 5.0),
          constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
          child: Icon(
            Icons.more_horiz,
            color: Color(GSYColors.white),
            size: 18.0,
          )));
    }
    return Row(children: list);
  }

  _renderChart(context) {
    double height = 140.0;
    double width = 3 * MediaQuery.of(context).size.width / 2;
    if (userInfo.login != null && userInfo.type == "Organization") {
      return Container();
    }
    return (userInfo.login != null)
        ? Card(
            margin: EdgeInsets.only(top: 0.0, left: 10.0, right: 10.0, bottom: 10.0),
            color: Color(GSYColors.white),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                width: width,
                height: height,

                ///svg chart
                child: SvgPicture.network(
                  CommonUtils.getUserChartAddress(userInfo.login),
                  width: width,
                  height: height - 10,
                  allowDrawingOutsideViewBox: true,
                  placeholderBuilder: (BuildContext context) => Container(
                        height: height,
                        width: width,
                        child: Center(
                          child: SpinKitRipple(color: Theme.of(context).primaryColor),
                        ),
                      ),
                ),
              ),
            ),
          )
        : Container(
            height: height,
            child: Center(
              child: SpinKitRipple(color: Theme.of(context).primaryColor),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GSYCardItem(
            color: themeColor,
            margin: EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0))),
            child: Padding(
              padding: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0, bottom: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ///用户头像
                      RawMaterialButton(
                          onPressed: () {
                            if (userInfo.avatar_url != null) {
                              NavigatorUtils.gotoPhotoViewPage(context, userInfo.avatar_url);
                            }
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.all(0.0),
                          constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
                          child: ClipOval(
                            child: FadeInImage.assetNetwork(
                              placeholder: GSYICons.DEFAULT_USER_ICON,
                              //预览图
                              fit: BoxFit.fitWidth,
                              image: userInfo.avatar_url ?? GSYICons.DEFAULT_REMOTE_PIC,
                              width: 80.0,
                              height: 80.0,
                            ),
                          )),
                      Padding(padding: EdgeInsets.all(10.0)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                ///用户名
                                Text(userInfo.login ?? "", style: GSYConstant.largeTextWhiteBold),
                                _getNotifyIcon(context, notifyColor),
                              ],
                            ),
                            Text(userInfo.name == null ? "" : userInfo.name, style: GSYConstant.smallSubLightText),

                            ///用户组织
                            GSYIConText(
                              GSYICons.USER_ITEM_COMPANY,
                              userInfo.company ?? CommonUtils.getLocale(context).nothing_now,
                              GSYConstant.smallSubLightText,
                              Color(GSYColors.subLightTextColor),
                              10.0,
                              padding: 3.0,
                            ),

                            ///用户位置
                            GSYIConText(
                              GSYICons.USER_ITEM_LOCATION,
                              userInfo.location ?? CommonUtils.getLocale(context).nothing_now,
                              GSYConstant.smallSubLightText,
                              Color(GSYColors.subLightTextColor),
                              10.0,
                              padding: 3.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(

                      ///用户博客
                      child: RawMaterialButton(
                        onPressed: () {
                          if (userInfo.blog != null) {
                            CommonUtils.launchOutURL(userInfo.blog, context);
                          }
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.all(0.0),
                        constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
                        child: GSYIConText(
                          GSYICons.USER_ITEM_LINK,
                          userInfo.blog ?? CommonUtils.getLocale(context).nothing_now,
                          (userInfo.blog == null) ? GSYConstant.smallSubLightText : GSYConstant.smallActionLightText,
                          Color(GSYColors.subLightTextColor),
                          10.0,
                          padding: 3.0,
                          textWidth: MediaQuery.of(context).size.width - 50,
                        ),
                      ),
                      margin: EdgeInsets.only(top: 6.0, bottom: 2.0),
                      alignment: Alignment.topLeft),

                  ///组织
                  _renderOrgs(context, orgList),

                  ///用户描述
                  Container(
                      child: Text(
                        userInfo.bio == null
                            ? CommonUtils.getLocale(context).user_create_at +
                                CommonUtils.getDateStr(userInfo.created_at)
                            : userInfo.bio +
                                "\n" +
                                CommonUtils.getLocale(context).user_create_at +
                                CommonUtils.getDateStr(userInfo.created_at),
                        style: GSYConstant.smallSubLightText,
                      ),
                      margin: EdgeInsets.only(top: 6.0, bottom: 2.0),
                      alignment: Alignment.topLeft),
                  Padding(padding: EdgeInsets.only(bottom: 5.0)),
                  Divider(
                    color: Color(GSYColors.subLightTextColor),
                  ),

                  ///用户底部状态
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _getBottomItem(
                        GSYLocalizations.of(context).currentLocalized.user_tab_repos,
                        userInfo.public_repos,
                        () {
                          NavigatorUtils.gotoCommonList(context, userInfo.login, "repository", "user_repos",
                              userName: userInfo.login);
                        },
                      ),
                      Container(width: 0.3, height: 40.0, color: Color(GSYColors.subLightTextColor)),
                      _getBottomItem(
                        CommonUtils.getLocale(context).user_tab_fans,
                        userInfo.followers,
                        () {
                          NavigatorUtils.gotoCommonList(context, userInfo.login, "user", "follower",
                              userName: userInfo.login);
                        },
                      ),
                      Container(width: 0.3, height: 40.0, color: Color(GSYColors.subLightTextColor)),
                      _getBottomItem(
                        CommonUtils.getLocale(context).user_tab_focus,
                        userInfo.following,
                        () {
                          NavigatorUtils.gotoCommonList(context, userInfo.login, "user", "followed",
                              userName: userInfo.login);
                        },
                      ),
                      Container(width: 0.3, height: 40.0, color: Color(GSYColors.subLightTextColor)),
                      _getBottomItem(
                        CommonUtils.getLocale(context).user_tab_star,
                        userInfo.starred,
                        () {
                          NavigatorUtils.gotoCommonList(context, userInfo.login, "repository", "user_star",
                              userName: userInfo.login);
                        },
                      ),
                      Container(width: 0.3, height: 40.0, color: Color(GSYColors.subLightTextColor)),
                      _getBottomItem(
                        CommonUtils.getLocale(context).user_tab_honor,
                        beStaredCount,
                        () {},
                      ),
                    ],
                  ),
                ],
              ),
            )),
        Container(
            child: Text(
              (userInfo.type == "Organization")
                  ? CommonUtils.getLocale(context).user_dynamic_group
                  : CommonUtils.getLocale(context).user_dynamic_title,
              style: GSYConstant.normalTextBold,
              overflow: TextOverflow.ellipsis,
            ),
            margin: EdgeInsets.only(top: 15.0, bottom: 15.0, left: 12.0),
            alignment: Alignment.topLeft),
        _renderChart(context),
      ],
    );
  }
}
