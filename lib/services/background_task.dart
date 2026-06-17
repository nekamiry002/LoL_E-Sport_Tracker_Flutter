import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'notification_scheduler.dart';
import 'notification_service.dart';

const _taskName = 'lol_match_check';

/// Called by Workmanager in the background (separate isolate).
@pragma('vm:entry-point')
void backgroundDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != _taskName) return true;

    await NotificationService.instance.init();

    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList('favorites') ?? [];
    final notifStart = prefs.getBool('notif_match_start') ?? true;
    final notifEnd = prefs.getBool('notif_match_end') ?? true;

    if (favList.isEmpty || (!notifStart && !notifEnd)) return true;

    await NotificationScheduler.instance.refresh(
      favCodes: Set<String>.from(favList),
      notifStart: notifStart,
      notifEnd: notifEnd,
    );

    return true;
  });
}

/// Registers the periodic background check (every 15 min).
Future<void> registerBackgroundTask() async {
  await Workmanager().initialize(backgroundDispatcher);
  await Workmanager().registerPeriodicTask(
    _taskName,
    _taskName,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}
