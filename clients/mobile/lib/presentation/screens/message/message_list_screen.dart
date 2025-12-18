import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/message_list_controller.dart';
import '../../routes/app_routes.dart';

class MessageListScreen extends GetView<MessageListController> {
  const MessageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppStrings.message,
          style: TextStyle(
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
            onPressed: () {}, // New message
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              controller: controller.searchController,
              style: TextStyle(
                color: isDarkMode ? AppColors.white : AppColors.black,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.search,
                hintStyle: TextStyle(
                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                ),
                filled: true,
                fillColor: isDarkMode ? AppColors.primaryDark : AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode
                        ? AppColors.border.withValues(alpha: 0.2)
                        : AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode
                        ? AppColors.border.withValues(alpha: 0.2)
                        : AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.onboardingContinue,
                    width: 2,
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: -0.1, end: 0, duration: 400.ms, delay: 100.ms),

          // --- Headers (Pinned/All) ---
          _buildSectionHeader(context, theme, isDarkMode, AppStrings.allMessage)
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 300.ms),

          // --- Conversation List ---
          Expanded(
            child: ListView.builder(
              itemCount: 7,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final conversations = _getConversations();
                final conversation = conversations[index];
                return _buildConversationTile(
                  context,
                  theme,
                  isDarkMode,
                  conversation['name']!,
                  conversation['message']!,
                  conversation['time']!,
                  conversation['unreadCount'],
                  index,
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: (400 + (index * 50)).ms)
                    .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: (400 + (index * 50)).ms);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String?>> _getConversations() {
    return [
      {
        'name': AppStrings.marielleWigington,
        'message': AppStrings.youSentAGift,
        'time': AppStrings.now,
        'unreadCount': '2',
      },
      {
        'name': AppStrings.tyraDhillon,
        'message': AppStrings.youSentAGift,
        'time': '12:50 PM',
        'unreadCount': '3',
      },
      {
        'name': AppStrings.marciSenter,
        'message': AppStrings.ridiculusNulla,
        'time': AppStrings.yesterday,
        'unreadCount': null,
      },
      {
        'name': AppStrings.rochelFoose,
        'message': AppStrings.purusEros,
        'time': 'Jan 15',
        'unreadCount': null,
      },
      {
        'name': AppStrings.rodolfoGoode,
        'message': AppStrings.youSentAGift,
        'time': 'Jan 10',
        'unreadCount': null,
      },
      {
        'name': AppStrings.charoletteHanlin,
        'message': AppStrings.charlotteMessage,
        'time': 'Dec 29, 2022',
        'unreadCount': '2',
      },
      {
        'name': AppStrings.titusKitamura,
        'message': AppStrings.youSentAGift,
        'time': 'Sep 15, 2022',
        'unreadCount': null,
      },
    ];
  }

  Widget _buildSectionHeader(BuildContext context, ThemeData theme, bool isDarkMode, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 18,
            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    ThemeData theme,
    bool isDarkMode,
    String name,
    String message,
    String time,
    String? unreadCount,
    int index,
  ) {
    return InkWell(
      onTap: () {
        Get.toNamed(
          AppRoutes.chatDetail,
          arguments: {'userName': name},
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDarkMode
                  ? AppColors.border.withValues(alpha: 0.1)
                  : AppColors.border.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.onboardingContinue.withValues(alpha: 0.2),
              child: Text(
                name[0],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onboardingContinue,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.white : AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                    fontSize: 12,
                  ),
                ),
                if (unreadCount != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.onboardingContinue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

