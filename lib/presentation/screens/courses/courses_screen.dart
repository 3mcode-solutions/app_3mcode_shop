import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/data/repositories/course_repository.dart';
import 'package:app_3mcode_shop/presentation/blocs/course/course.dart';
import 'package:app_3mcode_shop/presentation/blocs/favorite/favorite.dart';
import 'package:app_3mcode_shop/presentation/screens/courses/course_details_screen.dart';
import 'package:app_3mcode_shop/presentation/widgets/course_card.dart';
import 'package:app_3mcode_shop/presentation/widgets/custom_app_bar.dart';
import 'package:app_3mcode_shop/presentation/widgets/custom_drawer.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final _scrollController = ScrollController();
  String? _selectedCategory;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load course categories
    context.read<CourseBloc>().add(const LoadCourseCategories());

    // Load initial courses
    context.read<CourseBloc>().add(const LoadCourses());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<CourseBloc>().state;
      if (state is CoursesLoaded && !state.hasReachedMax) {
        context.read<CourseBloc>().add(
          LoadCourses(
            page: state.page + 1,
            perPage: state.perPage,
            search: _searchQuery,
            category: _selectedCategory,
          ),
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'الكورسات',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is CourseInitial ||
              (state is CourseLoading &&
                  _searchQuery == null &&
                  _selectedCategory == null)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CourseError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'حدث خطأ: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CourseBloc>().add(
                        const LoadCourses(forceRefresh: true),
                      );
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is CoursesLoaded) {
            if (state.courses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'لا توجد كورسات متاحة',
                      style: TextStyle(fontSize: 18),
                    ),
                    if (_searchQuery != null || _selectedCategory != null) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = null;
                            _selectedCategory = null;
                          });
                          context.read<CourseBloc>().add(
                            const LoadCourses(forceRefresh: true),
                          );
                        },
                        child: const Text('إزالة الفلتر'),
                      ),
                    ],
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CourseBloc>().add(
                  LoadCourses(
                    forceRefresh: true,
                    search: _searchQuery,
                    category: _selectedCategory,
                  ),
                );
              },
              child: Column(
                children: [
                  // Filter chips
                  if (_searchQuery != null || _selectedCategory != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          if (_searchQuery != null)
                            Chip(
                              label: Text('بحث: $_searchQuery'),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                setState(() {
                                  _searchQuery = null;
                                });
                                context.read<CourseBloc>().add(
                                  LoadCourses(
                                    forceRefresh: true,
                                    category: _selectedCategory,
                                  ),
                                );
                              },
                            ),
                          if (_selectedCategory != null)
                            Chip(
                              label: Text('تصنيف: $_selectedCategory'),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                setState(() {
                                  _selectedCategory = null;
                                });
                                context.read<CourseBloc>().add(
                                  LoadCourses(
                                    forceRefresh: true,
                                    search: _searchQuery,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),

                  // Courses grid
                  Expanded(
                    child: Column(
                      children: [
                        // Debug info - عرض معلومات التصحيح
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'عدد الكورسات: ${state.courses.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        // Course list - قائمة الكورسات
                        Expanded(
                          child: GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount:
                                state.hasReachedMax
                                    ? state.courses.length
                                    : state.courses.length + 1,
                            itemBuilder: (context, index) {
                              if (index >= state.courses.length) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final course = state.courses[index];

                              // طباعة تصحيح لمعرفة الكورسات المعروضة
                              debugPrint(
                                '🎓 Displaying course: ${course.id} - ${course.title}',
                              );

                              return BlocBuilder<FavoriteBloc, FavoriteState>(
                                builder: (context, favoriteState) {
                                  final isFavorite =
                                      favoriteState is FavoriteLoaded &&
                                      favoriteState.items.any(
                                        (item) => item.id == course.id,
                                      );

                                  return CourseCard(
                                    course: course,
                                    isFavorite: isFavorite,
                                    onToggleFavorite: () {
                                      if (isFavorite) {
                                        context.read<FavoriteBloc>().add(
                                          RemoveFromFavorites(course.id),
                                        );
                                      } else {
                                        context.read<FavoriteBloc>().add(
                                          AddToFavorites(course),
                                        );
                                      }
                                    },
                                    onTap: () {
                                      // طباعة تصحيح عند النقر على كورس
                                      debugPrint(
                                        '👆 Tapped on course: ${course.id} - ${course.title}',
                                      );

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => CourseDetailsScreen(
                                                courseId: course.id,
                                              ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String searchText = _searchQuery ?? '';

        return AlertDialog(
          title: const Text('بحث عن كورس'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'أدخل اسم الكورس',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              searchText = value;
            },
            controller: TextEditingController(text: _searchQuery),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = searchText.isNotEmpty ? searchText : null;
                });
                context.read<CourseBloc>().add(
                  LoadCourses(
                    forceRefresh: true,
                    search: _searchQuery,
                    category: _selectedCategory,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('بحث'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<CourseBloc, CourseState>(
          builder: (context, state) {
            if (state is CourseCategoriesLoaded) {
              final categories = state.categories;
              String? selectedCategory = _selectedCategory;

              return AlertDialog(
                title: const Text('تصفية حسب التصنيف'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected =
                          selectedCategory == category['id'].toString();

                      return ListTile(
                        title: Text(category['name']),
                        trailing:
                            isSelected
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                        onTap: () {
                          selectedCategory = category['id'].toString();
                          Navigator.pop(context);
                          setState(() {
                            _selectedCategory = selectedCategory;
                          });
                          context.read<CourseBloc>().add(
                            LoadCourses(
                              forceRefresh: true,
                              search: _searchQuery,
                              category: _selectedCategory,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('إلغاء'),
                  ),
                  if (_selectedCategory != null)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedCategory = null;
                        });
                        context.read<CourseBloc>().add(
                          LoadCourses(forceRefresh: true, search: _searchQuery),
                        );
                      },
                      child: const Text('إزالة الفلتر'),
                    ),
                ],
              );
            }

            return const AlertDialog(
              title: Text('تصفية حسب التصنيف'),
              content: Center(child: CircularProgressIndicator()),
            );
          },
        );
      },
    );
  }
}
