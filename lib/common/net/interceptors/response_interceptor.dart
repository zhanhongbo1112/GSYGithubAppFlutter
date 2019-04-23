import 'package:dio/dio.dart';
import 'package:gsy_github_app_flutter/common/net/code.dart';
import 'package:gsy_github_app_flutter/common/net/result_data.dart';

/**
 * Token拦截器
 * Created by guoshuyu
 * on 2019/3/23.
 */
class ResponseInterceptors extends InterceptorsWrapper {

  @override
  onResponse(Response response) {
    RequestOptions option = response.request;
    try {
      if (option.contentType != null && option.contentType.primaryType == "text") {
        return ResultData(response.data, true, Code.SUCCESS);
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ResultData(response.data, true, Code.SUCCESS, headers: response.headers);
      }
    } catch (e) {
      print(e.toString() + option.path);
      return ResultData(response.data, false, response.statusCode, headers: response.headers);
    }
  }
}