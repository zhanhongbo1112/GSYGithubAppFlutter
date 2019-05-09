import 'package:yqboots/src/apps/github-client/_daos/event_dao.dart';
import 'package:yqboots/src/core/bloc/base/base_bloc.dart';

/// 动态BLoC
class EventBloc extends BlocListBase {
  requestRefresh(String userName) async {
    pageReset();
    var res = await EventDao.getEventReceived(userName, page: page, needDb: true);
    changeLoadMoreStatus(getLoadMoreStatus(res));
    refreshData(res);
    await doNext(res);
    return res;
  }

  requestLoadMore(String userName) async {
    pageUp();
    var res = await EventDao.getEventReceived(userName, page: page);
    changeLoadMoreStatus(getLoadMoreStatus(res));
    loadMoreData(res);
    return res;
  }
}
