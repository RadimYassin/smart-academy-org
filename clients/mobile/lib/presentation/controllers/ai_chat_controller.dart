import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/repositories/ai_chat_repository.dart';
import '../../../data/models/ai_chat/ai_chat_response.dart';
import '../../../shared/services/audio_recording_service.dart';
import '../../../shared/services/speech_to_text_service.dart';

class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<SourceDocument>? sources;
  final String? audioUrl;
  final String? transcription;
  final String? imageUrl;

  Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.sources,
    this.audioUrl,
    this.transcription,
    this.imageUrl,
  });
}

class AiChatController extends GetxController {
  late final AiChatRepository _aiChatRepository;
  late final AudioRecordingService _audioRecordingService;
  late final SpeechToTextService _speechToTextService;
  late final FlutterTts _flutterTts;
  
  final messageController = TextEditingController();
  final messages = <Message>[].obs;
  final isTyping = false.obs;
  final errorMessage = ''.obs;
  
  // Typing effect state
  final typingMessageId = Rxn<String>();
  final displayedContent = RxMap<String, String>({});
  Timer? _typingTimer;
  
  // Audio recording state
  final isRecording = false.obs;
  final recordingTime = 0.obs;
  Timer? _recordingTimer;
  String? _currentRecordingPath;
  
  // Speech to text state
  final isTranscribing = false.obs;
  final transcriptionText = ''.obs;
  
  // Text to speech state
  final isSpeaking = false.obs;
  final speakingMessageId = Rxn<String>();
  
  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _aiChatRepository = Get.find<AiChatRepository>();
    _audioRecordingService = AudioRecordingService();
    _speechToTextService = SpeechToTextService();
    _flutterTts = FlutterTts();
    
    // Initialize speech to text
    _speechToTextService.initialize();
    
    // Initialize text to speech
    _initializeTts();
    
    // Add welcome message
    messages.add(Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: 'Hello! I\'m your AI learning assistant. How can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }
  
  /// Initialize text-to-speech
  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("fr-FR"); // French language
    await _flutterTts.setSpeechRate(0.5); // Normal speed
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setCompletionHandler(() {
      isSpeaking.value = false;
      speakingMessageId.value = null;
    });
    
    _flutterTts.setErrorHandler((msg) {
      Logger.logError('TTS error', error: msg);
      isSpeaking.value = false;
      speakingMessageId.value = null;
    });
  }
  
  /// Speak text
  Future<void> speakText(String text, String messageId) async {
    try {
      if (isSpeaking.value) {
        await _flutterTts.stop();
      }
      
      isSpeaking.value = true;
      speakingMessageId.value = messageId;
      
      await _flutterTts.speak(text);
      
      Logger.logInfo('Speaking text: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
    } catch (e) {
      Logger.logError('Error speaking text', error: e);
      isSpeaking.value = false;
      speakingMessageId.value = null;
    }
  }
  
  /// Stop speaking
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
      isSpeaking.value = false;
      speakingMessageId.value = null;
    } catch (e) {
      Logger.logError('Error stopping speech', error: e);
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    _typingTimer?.cancel();
    _recordingTimer?.cancel();
    _audioRecordingService.dispose();
    _speechToTextService.stop();
    super.onClose();
  }
  
  /// Start recording audio with real-time transcription
  Future<void> startRecording() async {
    try {
      // Initialize speech to text if not already done
      final speechAvailable = await _speechToTextService.isAvailable();
      if (!speechAvailable) {
        Logger.logWarning('Speech to text not available, will record without transcription');
      }
      
      final path = await _audioRecordingService.startRecording();
      if (path != null) {
        _currentRecordingPath = path;
        isRecording.value = true;
        recordingTime.value = 0;
        transcriptionText.value = '';
        
        // Start real-time transcription if available
        if (speechAvailable) {
          try {
            isTranscribing.value = true;
            await _speechToTextService.listen(
              onResult: (transcription) {
                // Update transcription in real-time
                if (transcription.isNotEmpty) {
                  transcriptionText.value = transcription;
                  messageController.text = transcription;
                  isTranscribing.value = true;
                  Logger.logInfo('Real-time transcription update: $transcription');
                }
              },
              onDone: () {
                isTranscribing.value = false;
                Logger.logInfo('Speech recognition completed');
              },
            );
          } catch (e) {
            Logger.logWarning('Could not start real-time transcription: $e');
            isTranscribing.value = false;
          }
        } else {
          isTranscribing.value = false;
        }
        
        // Start timer
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          recordingTime.value++;
        });
        
        Logger.logInfo('Recording started: $path');
      } else {
        Get.snackbar(
          'Error',
          'Failed to start recording',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          maxWidth: 400,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Logger.logError('Error starting recording', error: e);
      Get.snackbar(
        'Permission Required',
        'Microphone permission is required to record audio',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        maxWidth: 400,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  /// Stop recording and send audio
  Future<void> stopRecordingAndSend() async {
    try {
      if (!isRecording.value) return;
      
      _recordingTimer?.cancel();
      
      // Stop speech to text if listening
      await _speechToTextService.stop();
      
      // Get final transcription if available
      final finalTranscription = transcriptionText.value.trim();
      
      final path = await _audioRecordingService.stopRecording();
      isRecording.value = false;
      
      if (path != null && File(path).existsSync()) {
        final audioFile = File(path);
        
        // Use transcription from real-time speech-to-text or send audio for backend transcription
        String? transcription = finalTranscription.isNotEmpty ? finalTranscription : null;
        
        // Send audio message (with transcription if available)
        await _sendAudioMessage(audioFile, transcription: transcription);
      } else {
        Get.snackbar(
          'Error',
          'Recording file not found',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          maxWidth: 400,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Logger.logError('Error stopping recording', error: e);
      isRecording.value = false;
      isTranscribing.value = false;
      await _speechToTextService.stop();
      Get.snackbar(
        'Error',
        'Failed to stop recording: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        maxWidth: 400,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  /// Cancel current recording
  Future<void> cancelRecording() async {
    try {
      _recordingTimer?.cancel();
      await _speechToTextService.cancel();
      await _audioRecordingService.cancelRecording();
      isRecording.value = false;
      recordingTime.value = 0;
      transcriptionText.value = '';
      _currentRecordingPath = null;
    } catch (e) {
      Logger.logError('Error cancelling recording', error: e);
      isRecording.value = false;
    }
  }
  
  /// Send audio message
  Future<void> _sendAudioMessage(File audioFile, {String? transcription}) async {
    // Use transcription if available, otherwise use text field, otherwise null
    final question = transcription ?? messageController.text.trim();
    final userMessageId = DateTime.now().toString();
    
    // Add user message with audio indicator
    messages.add(Message(
      id: userMessageId,
      text: question.isNotEmpty ? question : '🎤 Audio message',
      isUser: true,
      timestamp: DateTime.now(),
      audioUrl: audioFile.path,
      transcription: transcription,
    ));
    
    messageController.clear();
    errorMessage.value = '';
    isTyping.value = true;
    
    try {
      // Process audio (send transcription if available)
      final response = await _aiChatRepository.processAudio(
        audioFile,
        question: question.isNotEmpty ? question : null,
      );
      
      // Extract response data
      final transcription = response['transcription'] as String?;
      final answer = response['answer'] as String? ?? '';
      final audioUrl = response['audio_url'] as String?;
      final sources = response['sources'] as List<dynamic>?;
      
      final assistantMessageId = (DateTime.now().millisecondsSinceEpoch + 1).toString();
      
      // Convert sources if available
      List<SourceDocument>? sourceDocuments;
      if (sources != null && sources.isNotEmpty) {
        sourceDocuments = sources.map((source) {
          final sourceMap = source as Map<String, dynamic>;
          return SourceDocument(
            content: sourceMap['content'] as String? ?? '',
            metadata: (sourceMap['metadata'] as Map<String, dynamic>?) ?? {},
            page: sourceMap['page'],
            sourceFile: sourceMap['source_file'] as String? ?? '',
          );
        }).toList();
      }
      
      // Add assistant message
      messages.add(Message(
        id: assistantMessageId,
        text: answer,
        isUser: false,
        timestamp: DateTime.now(),
        sources: sourceDocuments,
        audioUrl: audioUrl,
        transcription: transcription,
      ));
      
      // Start typing effect
      _startTypingEffect(assistantMessageId, answer);
      
      // Speak the AI's answer (not the transcription of the question)
      if (answer.isNotEmpty) {
        // Wait for typing effect to complete before speaking
        Future.delayed(const Duration(milliseconds: 2000), () {
          speakText(answer, assistantMessageId);
        });
      }
      
      Logger.logInfo('Audio processed successfully');
      
      // Clean up audio file
      try {
        if (audioFile.existsSync()) {
          await audioFile.delete();
        }
      } catch (e) {
        Logger.logWarning('Failed to delete audio file: $e');
      }
    } catch (e) {
      Logger.logError('Audio processing error', error: e);
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      
      final errorMessageId = (DateTime.now().millisecondsSinceEpoch + 1).toString();
      messages.add(Message(
        id: errorMessageId,
        text: 'I apologize, but I encountered an error processing your audio: ${errorMessage.value}. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      isTyping.value = false;
    }
  }
  
  String formatRecordingTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  void _startTypingEffect(String messageId, String fullText) {
    // Clear any existing timer
    _typingTimer?.cancel();
    
    // Set typing state
    typingMessageId.value = messageId;
    displayedContent[messageId] = '';
    
    // Start typing animation after a small delay
    Future.delayed(const Duration(milliseconds: 150), () {
      int currentIndex = 0;
      
      _typingTimer = Timer.periodic(const Duration(milliseconds: 15), (timer) {
        if (currentIndex < fullText.length) {
          currentIndex++;
          // Update displayed content (RxMap automatically triggers updates)
          displayedContent[messageId] = fullText.substring(0, currentIndex);
        } else {
          // Typing complete
          timer.cancel();
          typingMessageId.value = null;
          displayedContent[messageId] = fullText;
        }
      });
    });
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final userMessage = messageController.text.trim();
    final userMessageId = DateTime.now().toString();
    
    // Add user message
    messages.add(Message(
      id: userMessageId,
      text: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    messageController.clear();
    errorMessage.value = '';

    // Show typing indicator
    isTyping.value = true;

    try {
      // Call real AI API
      final aiResponse = await _aiChatRepository.askQuestion(userMessage);
      
      // Convert sources to Message format
      final sources = aiResponse.sources.map((source) => SourceDocument(
        content: source.content,
        metadata: source.metadata,
        page: source.page,
        sourceFile: source.sourceFile,
      )).toList();
      
      final assistantMessageId = (DateTime.now().millisecondsSinceEpoch + 1).toString();
      
      // Add message with full content first
      messages.add(Message(
        id: assistantMessageId,
        text: aiResponse.answer,
        isUser: false,
        timestamp: DateTime.now(),
        sources: sources.isNotEmpty ? sources : null,
      ));
      
      // Start typing effect
      _startTypingEffect(assistantMessageId, aiResponse.answer);
      
      // Speak the AI's answer after typing effect
      if (aiResponse.answer.isNotEmpty) {
        // Wait for typing effect to complete before speaking
        Future.delayed(const Duration(milliseconds: 2000), () {
          speakText(aiResponse.answer, assistantMessageId);
        });
      }
      
      Logger.logInfo('AI response received successfully (${aiResponse.numSources} sources)');
    } catch (e) {
      Logger.logError('AI chat error', error: e);
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      
      final errorMessageId = (DateTime.now().millisecondsSinceEpoch + 1).toString();
      
      // Show error message to user
      messages.add(Message(
        id: errorMessageId,
        text: 'I apologize, but I encountered an error: ${errorMessage.value}. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      isTyping.value = false;
    }
  }
  
  /// Pick image from camera or gallery
  Future<void> pickImage({bool fromCamera = false}) async {
    try {
      // Request permissions
      if (fromCamera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          Get.snackbar(
            'Permission Required',
            'Camera permission is required to take photos',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange.withOpacity(0.8),
            colorText: Colors.white,
            maxWidth: 400,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          );
          return;
        }
      } else {
        // For gallery, on Android 13+ use photos, otherwise storage
        PermissionStatus status;
        if (Platform.isAndroid) {
          // Check Android version
          final androidInfo = await Permission.photos.status;
          if (androidInfo.isDenied || androidInfo.isPermanentlyDenied) {
            // Try photos permission first (Android 13+)
            status = await Permission.photos.request();
            if (!status.isGranted) {
              // Fallback to storage for older Android
              status = await Permission.storage.request();
            }
          } else {
            status = androidInfo;
          }
        } else {
          // iOS
          status = await Permission.photos.request();
        }
        
        if (!status.isGranted) {
          Get.snackbar(
            'Permission Required',
            'Photo library permission is required to select images',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange.withOpacity(0.8),
            colorText: Colors.white,
            maxWidth: 400,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          );
          return;
        }
      }

      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        await _sendImageMessage(imageFile);
      }
    } catch (e) {
      Logger.logError('Error picking image', error: e);
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        maxWidth: 400,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Send image message
  Future<void> _sendImageMessage(File imageFile) async {
    // Use "explique" as default question if no question is provided
    final question = messageController.text.trim().isNotEmpty 
        ? messageController.text.trim() 
        : 'explique';
    final userMessageId = DateTime.now().toString();
    
    // Add user message with image indicator
    messages.add(Message(
      id: userMessageId,
      text: question,
      isUser: true,
      timestamp: DateTime.now(),
      imageUrl: imageFile.path,
    ));
    
    messageController.clear();
    errorMessage.value = '';
    isTyping.value = true;
    
    try {
      // Process image with "explique" question
      final response = await _aiChatRepository.processImage(
        imageFile,
        question: question,
      );
      
      // Extract response data
      final imageDescription = response['image_description'] as String? ?? '';
      final answer = response['answer'] as String? ?? '';
      final sources = response['sources'] as List<dynamic>?;
      
      final assistantMessageId = (DateTime.now().millisecondsSinceEpoch + 1).toString();
      
      // Convert sources if available
      List<SourceDocument>? sourceDocuments;
      if (sources != null && sources.isNotEmpty) {
        sourceDocuments = sources.map((source) {
          final sourceMap = source as Map<String, dynamic>;
          return SourceDocument(
            content: sourceMap['content'] as String? ?? '',
            metadata: (sourceMap['metadata'] as Map<String, dynamic>?) ?? {},
            page: sourceMap['page'],
            sourceFile: sourceMap['source_file'] as String? ?? '',
          );
        }).toList();
      }
      
      // Add assistant message
      messages.add(Message(
        id: assistantMessageId,
        text: answer,
        isUser: false,
        timestamp: DateTime.now(),
        sources: sourceDocuments,
      ));
      
      // Start typing effect
      _startTypingEffect(assistantMessageId, answer);
      
      // Speak the AI's answer after typing effect
      if (answer.isNotEmpty) {
        // Wait for typing effect to complete before speaking
        Future.delayed(const Duration(milliseconds: 2000), () {
          speakText(answer, assistantMessageId);
        });
      }
      
      Logger.logInfo('Image processed successfully');
      
      // Clean up image file
      try {
        if (imageFile.existsSync()) {
          await imageFile.delete();
        }
      } catch (e) {
        Logger.logWarning('Failed to delete image file: $e');
      }
    } catch (e) {
      Logger.logError('Image processing error', error: e);
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      
      final errorMessageId = (DateTime.now().millisecondsSinceEpoch + 1).toString();
      messages.add(Message(
        id: errorMessageId,
        text: 'I apologize, but I encountered an error processing your image: ${errorMessage.value}. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      isTyping.value = false;
    }
  }
  
  String getDisplayedContent(String messageId) {
    if (typingMessageId.value == messageId) {
      return displayedContent[messageId] ?? '';
    }
    final message = messages.firstWhereOrNull((m) => m.id == messageId);
    return message?.text ?? '';
  }
  
  bool isTypingMessage(String messageId) {
    return typingMessageId.value == messageId;
  }
}

