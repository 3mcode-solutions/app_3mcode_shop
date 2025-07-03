import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/data/models/course_model.dart';
import 'package:app_3mcode_shop/presentation/blocs/course/course.dart';
import 'package:app_3mcode_shop/presentation/blocs/favorite/favorite.dart';
import 'package:app_3mcode_shop/presentation/screens/courses/lesson_screen.dart';
import 'package:app_3mcode_shop/presentation/widgets/course_reviews_section.dart';
import 'package:app_3mcode_shop/presentation/widgets/lesson_item.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _initialTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _initialTabIndex,
    );

    // طباعة تصحيح لمعرفة معرف الكورس المطلوب
    debugPrint('🔍 Loading course details for ID: ${widget.courseId}');

    // Load course details
    context.read<CourseBloc>().add(
      LoadCourseById(widget.courseId, forceRefresh: true),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is CourseLoading) {
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
                        LoadCourseById(widget.courseId, forceRefresh: true),
                      );
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is CourseLoaded) {
            final course = state.course;
            final lessons = state.lessons;

            // طباعة تصحيح لمعرفة تفاصيل الكورس
            debugPrint('📚 Course details loaded:');
            debugPrint('📚 ID: ${course.id}');
            debugPrint('📚 Title: ${course.title}');
            debugPrint('📚 Lessons count: ${lessons.length}');
            debugPrint('📚 Is enrolled: ${course.isEnrolled}');
            debugPrint('📚 Progress: ${course.progress}%');

            return BlocBuilder<FavoriteBloc, FavoriteState>(
              builder: (context, favoriteState) {
                final isFavorite =
                    favoriteState is FavoriteLoaded &&
                    favoriteState.items.any((item) => item.id == course.id);

                return NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight: 200,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Course image
                              course.image.startsWith('http')
                                  ? CachedNetworkImage(
                                    imageUrl: course.image,
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                    errorWidget:
                                        (context, url, error) => Image.asset(
                                          'assets/images/placeholder.png',
                                          fit: BoxFit.cover,
                                        ),
                                  )
                                  : Image.asset(
                                    'assets/images/placeholder.png',
                                    fit: BoxFit.cover,
                                  ),
                              // Gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withAlpha(179),
                                    ],
                                  ),
                                ),
                              ),
                              // Course title
                              Positioned(
                                bottom: 16,
                                left: 16,
                                right: 16,
                                child: Text(
                                  course.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          // Favorite button
                          IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white,
                            ),
                            onPressed: () {
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
                          ),
                          // Share button
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.white),
                            onPressed: () {
                              context.read<CourseBloc>().add(
                                ShareCourse(
                                  courseId: course.id,
                                  courseTitle: course.title,
                                  courseUrl:
                                      'https://shop.3mcode-solutions.com/courses/${course.id}',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Course stats
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Rating
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            course.rating.toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${course.ratingCount} تقييم',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Students
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.people,
                                            color: Colors.blue,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            course.totalStudents.toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Text(
                                        'طالب',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Lessons
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.video_library,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            course.totalLessons.toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Text(
                                        'درس',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Level
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.bar_chart,
                                            color: Colors.orange,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            course.level,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Text(
                                        'المستوى',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Instructor info
                              Row(
                                children: [
                                  // Instructor avatar
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage:
                                        course.instructor.avatar.isNotEmpty
                                            ? NetworkImage(
                                              course.instructor.avatar,
                                            )
                                            : null,
                                    child:
                                        course.instructor.avatar.isEmpty
                                            ? const Icon(Icons.person)
                                            : null,
                                  ),
                                  const SizedBox(width: 12),
                                  // Instructor details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course.instructor.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (course
                                            .instructor
                                            .designation
                                            .isNotEmpty)
                                          Text(
                                            course.instructor.designation,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Price and enroll button
                              Row(
                                children: [
                                  // Price
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'السعر',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          course.isFree
                                              ? 'مجاني'
                                              : '\$${course.price}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                course.isFree
                                                    ? Colors.green
                                                    : AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Enroll button
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed:
                                          course.isEnrolled
                                              ? null
                                              : () {
                                                context.read<CourseBloc>().add(
                                                  EnrollCourse(course.id),
                                                );
                                              },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        backgroundColor:
                                            course.isEnrolled
                                                ? Colors.grey
                                                : AppColors.primary,
                                      ),
                                      child: Text(
                                        course.isEnrolled
                                            ? 'مسجل بالفعل'
                                            : 'التسجيل الآن',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Progress bar for enrolled courses
                              if (course.isEnrolled && course.progress > 0) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Text(
                                      'التقدم: ${course.progress}%',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${(lessons.where((lesson) => lesson.isCompleted).length)} / ${lessons.length} دروس مكتملة',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: course.progress / 100,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            controller: _tabController,
                            labelColor: AppColors.primary,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: AppColors.primary,
                            tabs: const [
                              Tab(text: 'نظرة عامة'),
                              Tab(text: 'المحتوى'),
                              Tab(text: 'التقييمات'),
                            ],
                          ),
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      // Overview tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'وصف الكورس',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Html(
                              data: course.description,
                              style: {
                                'body': Style(
                                  fontSize: FontSize(16),
                                  lineHeight: LineHeight(1.5),
                                ),
                              },
                            ),
                          ],
                        ),
                      ),

                      // Content tab
                      Column(
                        children: [
                          // Debug info - عرض معلومات التصحيح
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'عدد الدروس: ${lessons.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),

                          // Lessons list - قائمة الدروس
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              itemCount: lessons.length,
                              itemBuilder: (context, index) {
                                final lesson = lessons[index];
                                final isLocked =
                                    !course.isEnrolled && !lesson.isPreviewable;

                                // طباعة تصحيح لمعرفة الدروس المعروضة
                                debugPrint(
                                  '📖 Lesson ${index + 1}: ${lesson.title}',
                                );

                                return LessonItem(
                                  lesson: lesson,
                                  isLocked: isLocked,
                                  onTap: () {
                                    // طباعة تصحيح عند النقر على درس
                                    debugPrint(
                                      '👆 Tapped on lesson: ${lesson.id} - ${lesson.title}',
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => LessonScreen(
                                              courseId: course.id,
                                              lessonId: lesson.id,
                                            ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      // Reviews tab
                      CourseReviewsSection(courseId: course.id),
                    ],
                  ),
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
