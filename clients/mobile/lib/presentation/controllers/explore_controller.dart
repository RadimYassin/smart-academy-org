import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/explore/widgets/filter_sheet.dart';

class ExploreController extends GetxController {
  // Search text controller
  final searchController = TextEditingController();

  // Observable to track search state
  final isSearching = false.obs;

  // Observable to hold the search query
  final searchQuery = ''.obs;

  // Observable to track view mode (list or grid)
  final isGridView = false.obs;

  // Filter state
  final selectedLevels = <String>[].obs;
  final selectedTopics = <String>[].obs;
  final selectedRating = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to changes in the search text field
    searchController.addListener(() {
      final query = searchController.text;
      searchQuery.value = query;

      // If the query is not empty, we are searching
      if (query.isNotEmpty) {
        isSearching.value = true;
        // TODO: Call a use case to fetch search results
        // e.g., searchUseCase(query);
      } else {
        // If query is empty, show default view
        isSearching.value = false;
      }
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Called by the 'X' button in search mode
  void clearSearch() {
    searchController.clear();
  }

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  // Filter methods
  void toggleLevel(String level) {
    if (selectedLevels.contains(level)) {
      selectedLevels.remove(level);
    } else {
      selectedLevels.add(level);
    }
  }

  void toggleTopic(String topic) {
    if (selectedTopics.contains(topic)) {
      selectedTopics.remove(topic);
    } else {
      selectedTopics.add(topic);
    }
  }

  void setRating(int rating) {
    selectedRating.value = rating;
  }

  void applyFilters() {
    // TODO: Re-run the search with the new filters
    Get.back(); // Close the bottom sheet
  }

  void openFilterSheet() {
    Get.bottomSheet(
      const FilterSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

