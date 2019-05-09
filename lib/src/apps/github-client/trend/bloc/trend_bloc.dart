import 'package:yqboots/src/apps/github-client/_daos/repos_dao.dart';
import 'package:yqboots/src/core/bloc/base/base_bloc.dart';

/**
 * Created by guoshuyu
 * on 2019/3/23.
 */
class TrendBloc extends BlocListBase {
  requestRefresh(selectTime, selectType) async {
    pageReset();
    var res = await ReposDao.getTrendDao(since: selectTime.value, languageType: selectType.value);
    changeLoadMoreStatus(getLoadMoreStatus(res));
    refreshData(res);
    await doNext(res);
    return res;
  }
}
