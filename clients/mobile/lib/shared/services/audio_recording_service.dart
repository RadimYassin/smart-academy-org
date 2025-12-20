import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/utils/logger.dart';

class AudioRecordingService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _currentRecordingPath;
  bool _isRecording = false;

  /// Check and request microphone permission
  Future<bool> checkPermission() async {
    try {
      final status = await Permission.microphone.status;
      if (status.isGranted) {
        return true;
      }
      
      if (status.isDenied) {
        final result = await Permission.microphone.request();
        return result.isGranted;
      }
      
      if (status.isPermanentlyDenied) {
        Logger.logWarning('Microphone permission permanently denied');
        return false;
      }
      
      return false;
    } catch (e) {
      Logger.logError('Error checking microphone permission', error: e);
      return false;
    }
  }

  /// Start recording audio
  Future<String?> startRecording() async {
    try {
      if (_isRecording) {
        Logger.logWarning('Recording already in progress');
        return null;
      }

      final hasPermission = await checkPermission();
      if (!hasPermission) {
        throw Exception('Microphone permission not granted');
      }

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${directory.path}/recording_$timestamp.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
      Logger.logInfo('Recording started: $_currentRecordingPath');
      return _currentRecordingPath;
    } catch (e) {
      Logger.logError('Error starting recording', error: e);
      _isRecording = false;
      _currentRecordingPath = null;
      rethrow;
    }
  }

  /// Stop recording and return the file path
  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) {
        Logger.logWarning('No recording in progress');
        return null;
      }

      final path = await _audioRecorder.stop();
      _isRecording = false;

      if (path != null && File(path).existsSync()) {
        Logger.logInfo('Recording stopped: $path');
        final result = _currentRecordingPath;
        _currentRecordingPath = null;
        return result;
      } else {
        Logger.logWarning('Recording file not found');
        _currentRecordingPath = null;
        return null;
      }
    } catch (e) {
      Logger.logError('Error stopping recording', error: e);
      _isRecording = false;
      _currentRecordingPath = null;
      rethrow;
    }
  }

  /// Cancel current recording
  Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _audioRecorder.stop();
        if (_currentRecordingPath != null && File(_currentRecordingPath!).existsSync()) {
          await File(_currentRecordingPath!).delete();
        }
      }
      _isRecording = false;
      _currentRecordingPath = null;
      Logger.logInfo('Recording cancelled');
    } catch (e) {
      Logger.logError('Error cancelling recording', error: e);
      _isRecording = false;
      _currentRecordingPath = null;
    }
  }

  /// Check if currently recording
  bool get isRecording => _isRecording;

  /// Dispose resources
  Future<void> dispose() async {
    try {
      if (_isRecording) {
        await cancelRecording();
      }
      await _audioRecorder.dispose();
    } catch (e) {
      Logger.logError('Error disposing audio recorder', error: e);
    }
  }
}

