import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gsy_github_app_flutter/common/config/config.dart';
import 'package:gsy_github_app_flutter/common/dao/user_dao.dart';
import 'package:gsy_github_app_flutter/common/local/local_storage.dart';
import 'package:gsy_github_app_flutter/common/redux/gsy_state.dart';
import 'package:gsy_github_app_flutter/common/style/gsy_style.dart';
import 'package:gsy_github_app_flutter/common/utils/common_utils.dart';
import 'package:gsy_github_app_flutter/common/utils/navigator_utils.dart';
import 'package:gsy_github_app_flutter/widget/gsy_flex_button.dart';
import 'package:gsy_github_app_flutter/widget/gsy_input_widget.dart';

/**
 * 登录页
 * Created by guoshuyu
 * Date: 2018-07-16
 */
class LoginPage extends StatefulWidget {
  static final String sName = "login";

  @override
  State createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  var _userName = "";

  var _password = "";

  final TextEditingController userController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  _LoginPageState() : super();

  @override
  void initState() {
    super.initState();
    initParams();
  }

  initParams() async {
    _userName = await LocalStorage.get(Config.USER_NAME_KEY);
    _password = await LocalStorage.get(Config.PW_KEY);
    userController.value = TextEditingValue(text: _userName ?? "");
    pwController.value = TextEditingValue(text: _password ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GSYState>(builder: (context, store) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          body: Container(
            color: Theme.of(context).primaryColor,
            child: Center(
              //防止overFlow的现象
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    color: Color(GSYColors.cardWhite),
                    margin: const EdgeInsets.only(left:30.0, right: 30.0),
                    child: Padding(
                      padding: EdgeInsets.only(left: 30.0, top: 40.0, right: 30.0, bottom: 0.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Image(image: AssetImage(GSYICons.DEFAULT_USER_ICON), width: 90.0, height: 90.0),
                          Padding(padding: EdgeInsets.all(10.0)),
                          GSYInputWidget(
                            hintText: CommonUtils.getLocale(context).login_username_hint_text,
                            iconData: GSYICons.LOGIN_USER,
                            onChanged: (String value) {
                              _userName = value;
                            },
                            controller: userController,
                          ),
                          Padding(padding: EdgeInsets.all(10.0)),
                          GSYInputWidget(
                            hintText: CommonUtils.getLocale(context).login_password_hint_text,
                            iconData: GSYICons.LOGIN_PW,
                            obscureText: true,
                            onChanged: (String value) {
                              _password = value;
                            },
                            controller: pwController,
                          ),
                          Padding(padding: EdgeInsets.all(30.0)),
                          GSYFlexButton(
                            text: CommonUtils.getLocale(context).login_text,
                            color: Theme.of(context).primaryColor,
                            textColor: Color(GSYColors.textWhite),
                            onPress: () {
                              if (_userName == null || _userName.length == 0) {
                                return;
                              }
                              if (_password == null || _password.length == 0) {
                                return;
                              }
                              CommonUtils.showLoadingDialog(context);
                              UserDao.login(_userName.trim(), _password.trim(), store).then((res) {
                                Navigator.pop(context);
                                if (res != null && res.result) {
                                  Future.delayed(const Duration(seconds: 1), () {
                                    NavigatorUtils.goHome(context);
                                    return true;
                                  });
                                }
                              });
                            },
                          ),
                          Padding(padding: EdgeInsets.all(30.0)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
