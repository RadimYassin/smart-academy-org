import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/chat_detail_controller.dart';

class ChatDetailScreen extends GetView<ChatDetailController> {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String userName = (Get.arguments as Map)['userName'] ?? 'Chat';

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.onboardingContinue.withValues(alpha: 0.2),
              child: Text(
                userName[0],
                style: TextStyle(
                  color: AppColors.onboardingContinue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.white : AppColors.black,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.offline,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Chat List ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              reverse: true, // To show latest messages at the bottom
              children: [
                _buildMessageBubble(context, theme, isDarkMode, '😍😍😍❤️‍🔥😍', isSent: true)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 100.ms)
                    .scale(delay: 100.ms),
                _buildAttachmentBubble(context, theme, isDarkMode, AppStrings.lessonAttachment, AppStrings.halfMB)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 200.ms)
                    .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: 200.ms),
                _buildAudioBubble(context, theme, isDarkMode, AppStrings.audioDuration)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 300.ms)
                    .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: 300.ms),
                _buildMessageBubble(context, theme, isDarkMode, AppStrings.felisMorbi, isSent: true)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 400.ms)
                    .scale(delay: 400.ms),
                _buildMessageBubble(context, theme, isDarkMode, AppStrings.helloMarisson)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 500.ms)
                    .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: 500.ms),
                _buildDateChip(context, theme, isDarkMode, 'Jan 22, 2023')
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 600.ms),
              ],
            ),
          ),

          // --- Bottom Input Bar ---
          _buildBottomInputBar(context, theme, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildDateChip(BuildContext context, ThemeData theme, bool isDarkMode, String date) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.primaryDark : AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          date,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ThemeData theme, bool isDarkMode, String text, {bool isSent = false}) {
    final align = isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isSent
        ? AppColors.onboardingContinue
        : (isDarkMode ? AppColors.primaryDark : AppColors.white);
    final textColor = isSent ? AppColors.white : (isDarkMode ? AppColors.white : AppColors.black);

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isSent ? const Radius.circular(16) : const Radius.circular(4),
              bottomRight: isSent ? const Radius.circular(4) : const Radius.circular(16),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: isSent ? 0 : 8, right: isSent ? 8 : 0),
          child: Text(
            isSent ? '09:00 AM' : '08:32 AM',
            style: TextStyle(
              fontSize: 10,
              color: isDarkMode ? AppColors.greyDark : AppColors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioBubble(BuildContext context, ThemeData theme, bool isDarkMode, String duration) {
    // This is a "received" bubble
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.all(12.0),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_arrow,
                color: isDarkMode ? AppColors.white : AppColors.black,
              ),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.primary : AppColors.greyLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    AppStrings.audioWaveform,
                    style: TextStyle(
                      fontSize: 8,
                      color: isDarkMode ? AppColors.black : AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                duration,
                style: TextStyle(
                  color: isDarkMode ? AppColors.white : AppColors.black,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            '09:00 AM',
            style: TextStyle(
              fontSize: 10,
              color: isDarkMode ? AppColors.greyDark : AppColors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentBubble(BuildContext context, ThemeData theme, bool isDarkMode, String fileName, String size) {
    // This is a "received" bubble
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.all(12.0),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: TextStyle(
                        color: isDarkMode ? AppColors.white : AppColors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      size,
                      style: TextStyle(
                        color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            '08:32 AM',
            style: TextStyle(
              fontSize: 10,
              color: isDarkMode ? AppColors.greyDark : AppColors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInputBar(BuildContext context, ThemeData theme, bool isDarkMode) {
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
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.sentiment_satisfied_alt_outlined,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: controller.messageController,
              style: TextStyle(
                color: isDarkMode ? AppColors.white : AppColors.black,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.writeMessage,
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
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
            onPressed: () {}, // Attach
          ),
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
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 700.ms)
        .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 700.ms);
  }
}

