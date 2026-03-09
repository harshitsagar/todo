import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/task_tile.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _databaseService = DatabaseService();

  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedFilter = 0; // 0: All, 1: Active, 2: Completed

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tasks = await _databaseService.getTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Task> get _filteredTasks {
    switch (_selectedFilter) {
      case 1:
        return _tasks.where((task) => !task.isCompleted).toList();
      case 2:
        return _tasks.where((task) => task.isCompleted).toList();
      default:
        return _tasks;
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addTask() async {
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        await _databaseService.addTask(result);
        await _loadTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task added successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editTask(Task task) async {
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTaskScreen(task: task),
      ),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        await _databaseService.updateTask(result);
        await _loadTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleTask(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    try {
      await _databaseService.updateTask(updatedTask);
      setState(() {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteTask(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Task',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "${task.title}"?',
          style: GoogleFonts.poppins(),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text('Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _databaseService.deleteTask(task.id);
        await _loadTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Tasks',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 20.sp),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip('All', 0),
                _buildFilterChip('Active', 1),
                _buildFilterChip('Completed', 2),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
          ),
        )
            : _errorMessage != null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60.sp,
                color: Colors.red.shade400,
              ),
              SizedBox(height: 16.h),
              Text(
                _errorMessage!,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: _loadTasks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text('Try Again', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        )
            : _filteredTasks.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_outlined,
                size: 80.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 16.h),
              Text(
                _selectedFilter == 0
                    ? 'No tasks yet'
                    : _selectedFilter == 1
                    ? 'No active tasks'
                    : 'No completed tasks',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _selectedFilter == 0
                    ? 'Tap the + button to add a task'
                    : 'Try changing the filter',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: _filteredTasks.length,
          itemBuilder: (context, index) {
            final task = _filteredTasks[index];
            return TaskTile(
              task: task,
              onToggle: () => _toggleTask(task),
              onEdit: () => _editTask(task),
              onDelete: () => _deleteTask(task),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: Colors.blue.shade400,
        child: Icon(Icons.add, size: 24.sp),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: _selectedFilter == index ? Colors.white : Colors.grey.shade700,
        ),
      ),
      selected: _selectedFilter == index,
      onSelected: (_) {
        setState(() {
          _selectedFilter = index;
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.blue.shade400,
      checkmarkColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: _selectedFilter == index
              ? Colors.blue.shade400
              : Colors.grey.shade300,
        ),
      ),
    );
  }
}