import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/course/course.dart';
import '../../../domain/repositories/course_repository.dart';
import '../screens/explore/widgets/filter_sheet.dart';

class ExploreController extends GetxController {
  // Repositories
  late final CourseRepository _courseRepository;

  // Search text controller
  final searchController = TextEditingController();

  // Observable to track search state
  final isSearching = false.obs;

  // Observable to hold the search query
  final searchQuery = ''.obs;

  // Observable to track view mode (list or grid)
  final isGridView = false.obs;

  // Courses data
  final courses = <Course>[].obs;
  final filteredCourses = <Course>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Filter state
  final selectedLevels = <String>[].obs;
  final selectedTopics = <String>[].obs;
  final selectedRating = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _courseRepository = Get.find<CourseRepository>();
    
    // Load all courses initially
    loadAllCourses();
    
    // Listen to changes in the search text field
    searchController.addListener(() {
      final query = searchController.text;
      searchQuery.value = query;

      // If the query is not empty, we are searching
      if (query.isNotEmpty) {
        isSearching.value = true;
        _applyFilters();
      } else {
        // If query is empty, show default view
        isSearching.value = false;
        _applyFilters();
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

  /// Load all courses
  Future<void> loadAllCourses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final data = await _courseRepository.getAllCourses();
      courses.value = data;
      _applyFilters();
      
      Logger.logInfo('Loaded ${data.length} courses for explore');
    } catch (e) {
      Logger.logError('Load courses error', error: e);
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Apply filters and search
  void _applyFilters() {
    var filtered = courses.toList();

    // Search filter
    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((course) {
        return course.title.toLowerCase().contains(query) ||
               course.description.toLowerCase().contains(query) ||
               course.category.toLowerCase().contains(query);
      }).toList();
    }

    // Level filter
    if (selectedLevels.isNotEmpty) {
      filtered = filtered.where((course) => 
        selectedLevels.contains(course.level)
      ).toList();
    }

    // Category filter
    if (selectedTopics.isNotEmpty) {
      filtered = filtered.where((course) => 
        selectedTopics.contains(course.category)
      ).toList();
    }

    filteredCourses.assignAll(filtered);
  }

  void applyFilters() {
    _applyFilters();
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

