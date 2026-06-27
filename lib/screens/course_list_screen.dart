// lib/screens/course_list_screen.dart
//
// UI LAYER. Reads state from CourseProvider and renders it.
// Added: a search bar (filter by title/description) and an "offline" banner
// that shows when the list was loaded from the local cache.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course_model.dart';
import '../providers/course_provider.dart';
import '../enums.dart';

class CourseListScreen extends StatefulWidget {
  @override
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // DELETE — optimistic update handled inside the provider.
  Future<void> _deleteCourse(Course course) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok = await context.read<CourseProvider>().deleteCourse(course);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Course deleted' : 'Delete failed'),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _goToAddCourse() async {
    await Navigator.pushNamed(context, '/course-form');
  }

  Future<void> _goToEditCourse(Course course) async {
    await Navigator.pushNamed(context, '/course-form', arguments: course);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => context.read<CourseProvider>().loadCourses(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddCourse,
        child: Icon(Icons.add),
        tooltip: 'Add Course',
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          final showSearch = provider.status == CourseStatus.success;
          return Column(
            children: [
              if (provider.isOffline) _offlineBanner(),
              if (showSearch) _searchField(),
              Expanded(child: _buildContent(provider)),
            ],
          );
        },
      ),
    );
  }

  // Amber banner shown when data came from the local cache (no internet).
  Widget _offlineBanner() {
    return Container(
      width: double.infinity,
      color: Colors.orange.shade100,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 18, color: Colors.orange.shade800),
          SizedBox(width: 8),
          Text('Offline — showing saved data',
              style: TextStyle(color: Colors.orange.shade900, fontSize: 13)),
        ],
      ),
    );
  }

  // Search bar to filter courses by title or description.
  Widget _searchField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search courses...',
          prefixIcon: Icon(Icons.search),
          isDense: true,
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildContent(CourseProvider provider) {
    if (provider.status == CourseStatus.loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (provider.status == CourseStatus.error) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 12),
              Text('Something went wrong', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text(provider.errorMessage, textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.loadCourses(),
                child: Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.courses.isEmpty) {
      return Center(child: Text('No courses found. Tap + to add one.'));
    }

    // Apply the search filter.
    final query = _searchQuery.trim().toLowerCase();
    final List<Course> courses = query.isEmpty
        ? provider.courses
        : provider.courses
            .where((c) =>
                c.title.toLowerCase().contains(query) ||
                c.body.toLowerCase().contains(query))
            .toList();

    if (courses.isEmpty) {
      return Center(child: Text('No courses match "$_searchQuery".'));
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Card(
            margin: EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(course.id.toString(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800)),
              ),
              title: Text(course.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(course.body, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _goToEditCourse(course),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCourse(course),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
