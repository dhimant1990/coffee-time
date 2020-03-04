import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_logger.dart';
import '../../../../di_container.dart';
import '../../../../domain/entities/cafe.dart';
import '../../../core/blocs/cafe_list/bloc.dart';
import '../../../shared/shared_widgets.dart';
import '../../detail/bloc/detail_bloc.dart';
import '../../detail/bloc/detail_bloc_event.dart' as detail_events;
import '../../detail/screen.dart';
import 'no_data.dart';

//todo add to current loaded state filter entity
class CafeList extends StatefulWidget {
  final List<Cafe> cafes;
  final String nextPageToken;

  const CafeList({
    Key key,
    @required this.cafes,
    this.nextPageToken,
  }) : super(key: key);

  @override
  _CafeListState createState() => _CafeListState();
}

class _CafeListState extends State<CafeList> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    getLogger('CafeList').i('rebuild');
    if (widget.cafes.length == 0) return NoData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text('Cafes total: ${widget.cafes.length}'),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () {
              context.bloc<CafeListBloc>().add(Refresh());
              return Future.value();
            },
            child: NotificationListener(
              onNotification: _handleScrollNotification,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.nextPageToken != null
                    ? widget.cafes.length + 1
                    : widget.cafes.length,
                itemBuilder: (_, index) {
                  if (index < widget.cafes.length) {
                    return CafeTile(
                      cafe: widget.cafes[index],
                      onFavoriteTap: () {
                        context.bloc<CafeListBloc>().add(ToggleFavorite(
                            cafeId: widget.cafes[index].placeId));
                      },
                      onTap: () => _onTileTap(context, widget.cafes[index]),
                    );
                  } else {
                    return CircularLoader();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        _scrollController.position.extentAfter == 0) {
      context
          .bloc<CafeListBloc>()
          .add(LoadNext(pageToken: widget.nextPageToken));
    }

    return false;
  }

  void _onTileTap(BuildContext context, Cafe cafe) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => BlocProvider<DetailBloc>(
          create: (_) => sl.get<DetailBloc>(
            param1: cafe,
          )..add(detail_events.Load()),
          child: DetailScreen(),
        ),
      ),
    );
  }
}