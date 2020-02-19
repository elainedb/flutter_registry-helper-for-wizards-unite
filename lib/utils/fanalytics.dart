import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class FAnalytics {
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  sendUserId(String userId) async {
    await analytics.setUserId(userId);
  }

  sendTab(String pageName) async {
    await analytics.setCurrentScreen(
      screenName: pageName,
    );
  }

  sendCurrentScreen(String screenName) async {
    await analytics.setCurrentScreen(
      screenName: screenName,
    );
  }

  sendLoginEvent(String type) async {
    await analytics.logEvent(
      name: 'click_login',
      parameters: <String, dynamic>{'value': type},
    );
  }

  sendPlusEvent() async {
    await analytics.logEvent(
      name: 'click_plus_one_fragment',
    );
  }

  sendScrollToEvent(int value) async {
    await analytics.logEvent(
      name: 'scroll_to',
      parameters: <String, dynamic>{'value': value},
    );
  }

  sendAnalyticsEvents(String dropdownValue) async {
    await analytics.logEvent(
      name: 'missing_foundables_dropdown_value',
      parameters: <String, dynamic>{'value': dropdownValue},
    );
  }

  sendClickChartEvent() async {
    await analytics.logEvent(
      name: 'click_chart',
    );
  }

  sendDismissFoundableOverlayEvent() async {
    await analytics.logEvent(
      name: 'click_dismiss_foundable',
    );
  }

  sendLogoutEvent() async {
    await analytics.logEvent(
      name: 'click_logout',
    );
  }

  sendSubmitPageEvent() async {
    await analytics.logEvent(
      name: 'submit_page',
    );
  }
}
