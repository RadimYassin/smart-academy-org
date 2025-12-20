import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/utils/logger.dart';

class SpeechToTextService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  /// Initialize speech to text
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          Logger.logInfo('Speech recognition status: $status');
        },
        onError: (error) {
          Logger.logError('Speech recognition error', error: error);
        },
      );
      
      _isInitialized = available;
      Logger.logInfo('Speech to text initialized: $available');
      return available;
    } catch (e) {
      Logger.logError('Error initializing speech to text', error: e);
      _isInitialized = false;
      return false;
    }
  }

  /// Check if speech recognition is available
  Future<bool> isAvailable() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _isInitialized && _speech.isAvailable;
  }

  /// Start listening and transcribe speech with real-time updates
  Future<void> listen({
    String localeId = 'fr_FR',
    required Function(String) onResult,
    Function()? onDone,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        throw Exception('Speech to text not available');
      }
    }

    if (_isListening) {
      Logger.logWarning('Already listening');
      return;
    }

    try {
      _isListening = true;
      
      final result = await _speech.listen(
        onResult: (result) {
          // Call callback with partial or final results
          if (result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
          }
          
          if (result.finalResult) {
            Logger.logInfo('Transcription completed: ${result.recognizedWords}');
            if (onDone != null) {
              onDone();
            }
          }
        },
        localeId: localeId,
        listenMode: stt.ListenMode.dictation, // Use dictation mode for continuous listening
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 30),
        cancelOnError: false,
        partialResults: true, // Enable partial results for real-time updates
      );
      
      if (!result) {
        Logger.logWarning('Failed to start listening');
        _isListening = false;
      }
    } catch (e) {
      Logger.logError('Error during speech recognition', error: e);
      _isListening = false;
      rethrow;
    }
  }

  /// Stop listening
  Future<void> stop() async {
    if (_isListening && _speech.isListening) {
      await _speech.stop();
      _isListening = false;
      Logger.logInfo('Speech recognition stopped');
    }
  }

  /// Cancel listening
  Future<void> cancel() async {
    if (_speech.isListening) {
      await _speech.cancel();
      _isListening = false;
      Logger.logInfo('Speech recognition cancelled');
    }
  }

  bool get isListening => _isListening;
}

