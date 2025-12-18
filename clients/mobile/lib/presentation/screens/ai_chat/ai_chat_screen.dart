import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/ai_chat_controller.dart';

class AiChatScreen extends GetView<AiChatController> {
  const AiChatScreen({super.key});

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
        crossAxisAlignment: CrossAxisAlignment.end,
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
            child: Container(
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
              child: Text(
                message.text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
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

  Widget _buildInputBar(BuildContext context, bool isDarkMode) {
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
          Expanded(
            child: TextField(
              controller: controller.messageController,
              style: TextStyle(
                color: isDarkMode ? AppColors.white : AppColors.black,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.typeMessage,
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
    );
  }
}

