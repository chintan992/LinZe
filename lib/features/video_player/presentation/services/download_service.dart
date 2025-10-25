import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  static const String _downloadsDirName = 'LinzeDownloads';

  static Future<void> initialize() async {
    await FlutterDownloader.initialize(
      debug: true, // Enable or disable debug logs
    );
  }

  static Future<String?> getDownloadPath() async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final downloadDir = Directory('${directory.path}/$_downloadsDirName');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        return downloadDir.path;
      }
      return null;
    } on Exception catch (e) {
      debugPrint('Error getting download path: $e');
      return null;
    }
  }

  static Future<String?> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status == PermissionStatus.granted) {
        return await getDownloadPath();
      } else {
        debugPrint('Storage permission denied');
        return null;
      }
    } else if (Platform.isIOS) {
      // For iOS, we use application documents directory which doesn't require permission
      return await getDownloadPath();
    }
    return null;
  }

  static Future<String?> downloadVideo({
    required String url,
    required String animeTitle,
    required String episodeTitle,
    String? headers,
  }) async {
    try {
      final path = await requestStoragePermission();
      if (path == null) {
        debugPrint('Cannot download: No storage permission or path');
        return null;
      }

      // Create a filename based on anime and episode title
      String fileName = _sanitizeFileName('$animeTitle - $episodeTitle.mp4');

      // Start download
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        fileName: fileName,
        savedDir: path,
        headers: headers != null ? {'Authorization': headers} : {},
        showNotification: true,
        openFileFromNotification: false,
      );

      if (taskId != null) {
        return taskId;
      } else {
        debugPrint('Failed to start download');
        return null;
      }
    } on Exception catch (e) {
      debugPrint('Error starting download: $e');
      return null;
    }
  }

  static Future<void> cancelDownload(String taskId) async {
    await FlutterDownloader.cancel(taskId: taskId);
  }

  static Future<void> pauseDownload(String taskId) async {
    await FlutterDownloader.pause(taskId: taskId);
  }

  static Future<void> resumeDownload(String taskId) async {
    await FlutterDownloader.resume(taskId: taskId);
  }

  static Future<List<DownloadTask>> getDownloadTasks() async {
    final tasks = await FlutterDownloader.loadTasks();
    return tasks ?? [];
  }

  static Future<void> removeDownloadTask(
    String taskId, {
    bool shouldDeleteContent = true,
  }) async {
    await FlutterDownloader.remove(
      taskId: taskId,
      shouldDeleteContent: shouldDeleteContent,
    );
  }

  static String _sanitizeFileName(String fileName) {
    // Remove characters that are not allowed in file names
    return fileName
        .replaceAll(
          RegExp(r'[<>:"/\\|?*]'),
          '_',
        ) // Replace invalid characters with underscore
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        ) // Replace multiple spaces with single space
        .trim();
  }

  static Future<String> getDownloadProgress(String taskId) async {
    final tasks = await FlutterDownloader.loadTasks();
    final task = (tasks ?? []).firstWhere(
      (element) => element.taskId == taskId,
      orElse: () => DownloadTask(
        taskId: '',
        status: DownloadTaskStatus.undefined,
        progress: 0,
        url: '',
        filename: '',
        savedDir: '',
        timeCreated: DateTime.now().millisecondsSinceEpoch,
        allowCellular: false,
      ),
    );

    if (task.status == DownloadTaskStatus.complete) {
      return 'Complete';
    } else if (task.status == DownloadTaskStatus.running) {
      return '${task.progress}%';
    } else if (task.status == DownloadTaskStatus.paused) {
      return 'Paused';
    } else if (task.status == DownloadTaskStatus.failed) {
      return 'Failed';
    } else {
      return 'Pending';
    }
  }
}
