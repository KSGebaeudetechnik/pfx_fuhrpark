
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:pfx_fuhrpark/src/features/network_sync/sync_service.dart';

void initBackgroundFetch(SyncService syncService) {
  BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15, // Every 15 minutes
        stopOnTerminate: false,
        enableHeadless: true,
      ), (String taskId) async {
    debugPrint("[Background Fetch] Syncing...");
    // await syncService.syncTest();
    await syncService.sync();
    debugPrint("[Background Fetch] Data synced.");
    BackgroundFetch.finish(taskId);
  });
}


// void triggerBackgroundFetch(SyncService syncService) async {
//   debugPrint("[Background Fetch] Manually triggering sync...");
//   await syncService.sync();
//   debugPrint("[Background Fetch] Manual sync complete.");
// }

// void scheduleImmediateFetch() {
//   BackgroundFetch.scheduleTask(TaskConfig(
//     taskId: "com.transistorsoft.fetch",
//     delay: 5000, // 5 seconds delay for testing
//     periodic: false,
//     stopOnTerminate: false,
//     enableHeadless: true,
//   ));
// }