import 'dart:developer';

// import 'package:attendance/src/data/campus_attendance_system.dart';
import 'package:flutter/material.dart';

import 'auth.dart';
import 'routing.dart';
import 'screens/navigator.dart';

class CampusAttendanceManagementSystem extends StatefulWidget {
  const CampusAttendanceManagementSystem({super.key});

  @override
  State<CampusAttendanceManagementSystem> createState() =>
      _CampusAttendanceManagementSystemState();
}

class _CampusAttendanceManagementSystemState
    extends State<CampusAttendanceManagementSystem> {
  final _auth = SMSAuth();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final RouteState _routeState;
  late final SimpleRouterDelegate _routerDelegate;
  late final TemplateRouteParser _routeParser;

  @override
  void initState() {
    /// Configure the parser with all of the app's allowed path templates.
    _routeParser = TemplateRouteParser(
      allowedPaths: [
        '/signin',
        '/avinya_types/new',
        '/avinya_types/all',
        '/avinya_types/popular',
        '/avinya_type/:id',
        '/avinya_type/new',
        '/avinya_type/edit',
        '/activities/new',
        '/activities/all',
        '/activities/popular',
        '/activity/:id',
        '/activity/new',
        '/activity/edit',
        '/attendance_marker',
        '/avinya_types',
        '/#access_token',
      ],
      guard: _guard,
      initialRoute: '/avinya_types',
    );

    _routeState = RouteState(_routeParser);

    _routerDelegate = SimpleRouterDelegate(
      routeState: _routeState,
      navigatorKey: _navigatorKey,
      builder: (context) => SMSNavigator(
        navigatorKey: _navigatorKey,
      ),
    );

    // Listen for when the user logs out and display the signin screen.
    _auth.addListener(_handleAuthStateChanged);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => RouteStateScope(
        notifier: _routeState,
        child: SMSAuthScope(
          notifier: _auth,
          child: MaterialApp.router(
            routerDelegate: _routerDelegate,
            routeInformationParser: _routeParser,
            // Revert back to pre-Flutter-2.5 transition behavior:
            // https://github.com/flutter/flutter/issues/82053
            theme: ThemeData(
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
                  TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
                },
              ),
            ),
          ),
        ),
      );

  Future<ParsedRoute> _guard(ParsedRoute from) async {
    final signedIn = await _auth.getSignedIn();
    // String? jwt_sub = campusAttendanceSystemInstance.getJWTSub();

    final signInRoute = ParsedRoute('/signin', '/signin', {}, {});

    final avinyaTypesRoute =
        ParsedRoute('/avinya_types', '/avinya_types', {}, {});

    final activitiesRoute = ParsedRoute('/activities', '/activities', {}, {});

    final attendanceMarkerRoute =
        ParsedRoute('/attendance_marker', '/attendance_marker', {}, {});

    // // Go to /apply if the user is not signed in
    log("_guard signed in $signedIn");
    // log("_guard JWT sub ${jwt_sub}");
    log("_guard from ${from.toString()}\n");

    if (signedIn && from == avinyaTypesRoute) {
      return avinyaTypesRoute;
    } else if (signedIn && from == activitiesRoute) {
      return activitiesRoute;
    } else if (signedIn && from == attendanceMarkerRoute) {
      return attendanceMarkerRoute;
    }
    // Go to /application if the user is signed in and tries to go to /signin.
    else if (signedIn && from == signInRoute) {
      return ParsedRoute('/avinya_types', '/avinya_types', {}, {});
    }
    log("_guard signed in2 $signedIn");
    // else if (signedIn && jwt_sub != null) {
    //   return avinyaTypesRoute;
    // }
    return from;
  }

  void _handleAuthStateChanged() async {
    bool signedIn = await _auth.getSignedIn();
    log("_handleAuthStateChanged signed in $signedIn");
    if (!signedIn) {
      _routeState.go('/avinya_types');
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_handleAuthStateChanged);
    _routeState.dispose();
    _routerDelegate.dispose();
    super.dispose();
  }
}
