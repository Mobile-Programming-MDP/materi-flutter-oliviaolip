import 'package:flutter/widgets.dart';

/// A global [RouteObserver] used to detect when a route becomes visible again.
///
/// This is useful to refresh UI (e.g., favorites list) when returning from a
/// pushed route like a details page.
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
