import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/ai_chat_controller.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final Map<String, AudioPlayer> _audioPlayers = {};
  final Map<String, bool> _isPlaying = {};
  
  AiChatController get controller => Get.find<AiChatController>();
  
  @override
  void dispose() {
    // Dispose all audio players
    for (var player in _audioPlayers.values) {
      player.dispose();
    }
    _audioPlayers.clear();
    _isPlaying.clear();
    super.dispose();
  }
  
  Future<void> _toggleAudioPlayback(String messageId, String audioUrl) async {
    if (_isPlaying[messageId] == true) {
      // Stop playback
      final player = _audioPlayers[messageId];
      if (player != null) {
        await player.stop();
        setState(() {
          _isPlaying[messageId] = false;
        });
      }
    } else {
      // Stop all other players
      for (var entry in _audioPlayers.entries) {
        if (entry.key != messageId) {
          await entry.value.stop();
          setState(() {
            _isPlaying[entry.key] = false;
          });
        }
      }
      
      // Start playback
      AudioPlayer player;
      if (_audioPlayers.containsKey(messageId)) {
        player = _audioPlayers[messageId]!;
      } else {
        player = AudioPlayer();
        _audioPlayers[messageId] = player;
        
        player.onPlayerComplete.listen((_) {
          setState(() {
            _isPlaying[messageId] = false;
          });
        });
      }
      
      try {
        String filePath = audioUrl;
        
        if (audioUrl.startsWith('data:audio')) {
          // Base64 audio from API - save to temp file first
          final base64Data = audioUrl.split(',')[1];
          final bytes = base64Decode(base64Data);
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/audio_$messageId.mp3');
          await tempFile.writeAsBytes(bytes);
          filePath = tempFile.path;
        }
        
        // Play audio file
        await player.play(DeviceFileSource(filePath));
        
        setState(() {
          _isPlaying[messageId] = true;
        });
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to play audio: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.onboardingContinue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: AppColors.onboardingContinue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppStrings.aiAssistant,
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Chat Messages ---
          Expanded(
            child: Obx(() {
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16.0),
                itemCount: controller.messages.length + (controller.isTyping.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (controller.isTyping.value && index == 0) {
                    return _buildTypingIndicator(context, isDarkMode)
                        .animate()
                        .fadeIn(duration: 300.ms);
                  }

                  final messageIndex = controller.isTyping.value ? index - 1 : index;
                  final message = controller.messages[controller.messages.length - 1 - messageIndex];
                  
                  return _buildMessageBubble(context, message, isDarkMode, index)
                      .animate()
                      .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                      .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: (index * 50).ms);
                },
              );
            }),
          ),

          // --- Input Bar ---
          _buildInputBar(context, isDarkMode)
              .animate()
              .fadeIn(duration: 500.ms, delay: 300.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.primaryDark : AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: const Radius.circular(4),
                bottomRight: const Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                _buildTypingDot(0, isDarkMode),
                const SizedBox(width: 4),
                _buildTypingDot(1, isDarkMode),
                const SizedBox(width: 4),
                _buildTypingDot(2, isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index, bool isDarkMode) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.grey : AppColors.greyDark,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(delay: (index * 200).ms, duration: 600.ms, begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
        .then()
        .scale(delay: (index * 200).ms, duration: 600.ms, begin: const Offset(1.0, 1.0), end: const Offset(0.8, 0.8));
  }

  Widget _buildMessageBubble(BuildContext context, Message message, bool isDarkMode, int index) {
    final color = message.isUser
        ? AppColors.onboardingContinue
        : (isDarkMode ? AppColors.primaryDark : AppColors.white);
    final textColor = message.isUser
        ? AppColors.white
        : (isDarkMode ? AppColors.white : AppColors.black);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.onboardingContinue.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                color: AppColors.onboardingContinue,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: message.isUser ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                  ),
                  child: Obx(() {
                    final isTyping = controller.isTypingMessage(message.id);
                    final displayedText = isTyping 
                        ? controller.getDisplayedContent(message.id)
                        : message.text;
                    
                    final messageTextStyle = TextStyle(
                      color: textColor,
                      fontSize: 15,
                      height: 1.7,
                      letterSpacing: 0.1,
                      fontWeight: FontWeight.w400,
                    );
                    
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            displayedText,
                            style: messageTextStyle,
                            maxLines: null,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                        // Typing cursor
                        if (isTyping)
                          Container(
                            width: 2,
                            height: 16,
                            margin: const EdgeInsets.only(left: 2, top: 2),
                            decoration: BoxDecoration(
                              color: AppColors.onboardingContinue,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          )
                              .animate(onPlay: (animController) => animController.repeat())
                              .fadeIn(duration: 500.ms)
                              .then()
                              .fadeOut(duration: 500.ms),
                      ],
                    );
                  }),
                ),
                // Show image if available
                if (message.imageUrl != null) ...[
                  const SizedBox(height: 8),
                  _buildImagePreview(context, message.imageUrl!, isDarkMode),
                ],
                // Show audio if available
                if (message.audioUrl != null) ...[
                  const SizedBox(height: 8),
                  _buildAudioPlayer(context, message.id, message.audioUrl!, isDarkMode),
                ],
                // Show transcription if available
                if (message.transcription != null && message.transcription!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.primaryDark.withValues(alpha: 0.3)
                          : AppColors.grey.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.transcribe,
                          size: 12,
                          color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Transcription: ${message.transcription}',
                            style: TextStyle(
                              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Obx(() {
                          final isSpeaking = controller.isSpeaking.value && 
                                            controller.speakingMessageId.value == message.id;
                          return IconButton(
                            icon: Icon(
                              isSpeaking ? Icons.volume_up : Icons.volume_down,
                              size: 16,
                              color: AppColors.onboardingContinue,
                            ),
                            onPressed: () {
                              if (isSpeaking) {
                                controller.stopSpeaking();
                              } else {
                                controller.speakText(message.transcription!, message.id);
                              }
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: isSpeaking ? 'Stop reading' : 'Read transcription',
                          );
                        }),
                      ],
                    ),
                  ),
                ],
                // Show sources if available
                if (!message.isUser && message.sources != null && message.sources!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode 
                          ? AppColors.primaryDark.withValues(alpha: 0.5)
                          : AppColors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.onboardingContinue.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.source,
                              size: 14,
                              color: AppColors.onboardingContinue,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Sources (${message.sources!.length})',
                                style: TextStyle(
                                  color: AppColors.onboardingContinue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ...message.sources!.take(3).map((source) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.description,
                                  size: 12,
                                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    source.sourceFile.isNotEmpty 
                                        ? source.sourceFile 
                                        : 'Source ${message.sources!.indexOf(source) + 1}',
                                    style: TextStyle(
                                      color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (source.page != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      'p.${source.page}',
                                      style: TextStyle(
                                        color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                        if (message.sources!.length > 3)
                          Text(
                            '+ ${message.sources!.length - 3} more',
                            style: TextStyle(
                              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.onboardingContinue.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: AppColors.onboardingContinue,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildImagePreview(BuildContext context, String imagePath, bool isDarkMode) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
        maxHeight: 200,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.onboardingContinue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 100,
              color: isDarkMode ? AppColors.primaryDark : AppColors.grey.withValues(alpha: 0.1),
              child: Icon(
                Icons.broken_image,
                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAudioPlayer(BuildContext context, String messageId, String audioUrl, bool isDarkMode) {
    final isPlaying = _isPlaying[messageId] ?? false;
    
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.primaryDark.withValues(alpha: 0.5)
            : AppColors.onboardingContinue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.onboardingContinue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleAudioPlayback(messageId, audioUrl),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.onboardingContinue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audio message',
                  style: TextStyle(
                    color: isDarkMode ? AppColors.white : AppColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isPlaying)
                  Text(
                    'Playing...',
                    style: TextStyle(
                      color: AppColors.onboardingContinue,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, bool isDarkMode) {
    return Obx(() {
      final isRecording = controller.isRecording.value;
      final recordingTime = controller.recordingTime.value;
      
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.primary : AppColors.background,
          border: Border(
            top: BorderSide(
              color: isDarkMode
                  ? AppColors.border.withValues(alpha: 0.2)
                  : AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Recording indicator with transcription
            if (isRecording)
              Obx(() {
                final transcription = controller.transcriptionText.value;
                final isTranscribing = controller.isTranscribing.value;
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          )
                              .animate(onPlay: (controller) => controller.repeat())
                              .fadeIn(duration: 500.ms)
                              .then()
                              .fadeOut(duration: 500.ms),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Recording: ${controller.formatRecordingTime(recordingTime)}',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: controller.cancelRecording,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      if (isTranscribing || transcription.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.mic,
                              size: 14,
                              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                isTranscribing && transcription.isEmpty
                                    ? 'Listening...'
                                    : transcription.isNotEmpty
                                        ? transcription
                                        : 'Waiting for speech...',
                                style: TextStyle(
                                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }),
            
            // Input row
            Row(
              children: [
                // Image picker button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.onboardingContinue.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.image,
                      color: AppColors.onboardingContinue,
                      size: 20,
                    ),
                    onSelected: (value) {
                      if (value == 'camera') {
                        controller.pickImage(fromCamera: true);
                      } else if (value == 'gallery') {
                        controller.pickImage(fromCamera: false);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'camera',
                        child: Row(
                          children: [
                            Icon(Icons.camera_alt, size: 20),
                            SizedBox(width: 8),
                            Text('Take Photo'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'gallery',
                        child: Row(
                          children: [
                            Icon(Icons.photo_library, size: 20),
                            SizedBox(width: 8),
                            Text('Choose from Gallery'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Audio record button
                Obx(() => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: controller.isRecording.value
                        ? Colors.red
                        : AppColors.onboardingContinue.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      controller.isRecording.value ? Icons.stop : Icons.mic,
                      color: controller.isRecording.value
                          ? AppColors.white
                          : AppColors.onboardingContinue,
                      size: 20,
                    ),
                    onPressed: controller.isRecording.value
                        ? controller.stopRecordingAndSend
                        : controller.startRecording,
                  ),
                )),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    enabled: !isRecording,
                    style: TextStyle(
                      color: isDarkMode ? AppColors.white : AppColors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: isRecording
                          ? 'Recording...'
                          : AppStrings.typeMessage,
                      hintStyle: TextStyle(
                        color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                      ),
                      filled: true,
                      fillColor: isDarkMode ? AppColors.primaryDark : AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? AppColors.border.withValues(alpha: 0.2)
                              : AppColors.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? AppColors.border.withValues(alpha: 0.2)
                              : AppColors.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: AppColors.onboardingContinue,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.onboardingContinue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: AppColors.white, size: 20),
                    onPressed: controller.sendMessage,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

