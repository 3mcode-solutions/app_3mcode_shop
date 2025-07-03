import 'package:flutter/material.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/data/services/portfolio_service.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  int? _selectedCategoryId;
  List<ProjectCategory> _categories = [];
  List<ProjectItem> _projects = [];
  bool _loading = true;
  bool _loadingProjects = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCategoriesAndProjects();
  }

  Future<void> _fetchCategoriesAndProjects() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final categories = await PortfolioService.fetchCategories();
      setState(() {
        _categories = [ProjectCategory(id: 0, name: 'الكل'), ...categories];
        _selectedCategoryId = 0;
      });
      await _fetchProjects();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _fetchProjects() async {
    setState(() {
      _loadingProjects = true;
      _error = null;
    });
    try {
      final projects = await PortfolioService.fetchProjects(
        categoryId: _selectedCategoryId != 0 ? _selectedCategoryId : null,
      );
      setState(() {
        _projects = projects;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loadingProjects = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('portfolio')),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    // Category Filter
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = category.id == _selectedCategoryId;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category.name),
                              selected: isSelected,
                              onSelected: (selected) async {
                                setState(() {
                                  _selectedCategoryId = category.id;
                                });
                                await _fetchProjects();
                              },
                              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                              checkmarkColor: Theme.of(context).primaryColor,
                            ),
                          );
                        },
                      ),
                    ),
                    // Projects Grid
                    Expanded(
                      child: _loadingProjects
                          ? const Center(child: CircularProgressIndicator())
                          : _projects.isEmpty
                              ? Center(child: Text('لا توجد مشاريع'))
                              : RefreshIndicator(
                                  onRefresh: () async {
                                    await _fetchCategoriesAndProjects();
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('تم تحديث معرض الأعمال!')),
                                      );
                                    }
                                  },
                                  child: GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.75,
                                    ),
                                    itemCount: _projects.length,
                                    itemBuilder: (context, index) {
                                      final project = _projects[index];
                                      return _buildProjectCard(context, project);
                                    },
                                  ),
                                ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectItem project) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          _showProjectDetails(context, project);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: project.imageUrl != null
                      ? Image.network(
                          project.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.image,
                                size: 48,
                                color: Colors.grey[500],
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image,
                            size: 48,
                            color: Colors.grey[500],
                          ),
                        ),
                ),
              ),
            ),
            // Project Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (project.description != null)
                      Text(
                        _stripHtml(project.description!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProjectDetails(BuildContext context, ProjectItem project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Image
                    if (project.imageUrl != null)
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            project.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.image,
                                  size: 48,
                                  color: Colors.grey[500],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Project Title
                    Text(
                      project.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Project Description
                    if (project.description != null)
                      Text(
                        _stripHtml(project.description!),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stripHtml(String htmlString) {
    final exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }
} 