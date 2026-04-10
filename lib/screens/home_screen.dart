import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/db_helper.dart';
import '../models/task.dart';
import '../models/resource_post.dart';
import '../services/api_service.dart';
import '../services/sync_service.dart';
import '../widgets/offline_banner.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task>         _tasks       = [];
  List<ResourcePost> _posts       = [];
  bool              _loadingPosts = false;
  String?           _postError;
  int               _currentTab  = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadPosts();
  }

  Future<void> _loadTasks() async {
    final tasks = await DBHelper.getAllTasks();
    if (mounted) setState(() => _tasks = tasks);
  }

  Future<void> _loadPosts() async {
    setState(() { _loadingPosts = true; _postError = null; });
    try {
      final posts = await ApiService.fetchPosts();
      if (mounted) setState(() => _posts = posts);
    } on Exception catch (e) {
      if (mounted) setState(() => _postError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingPosts = false);
    }
  }

  void _addTaskDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl  = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Draft Task'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
          TextField(controller: descCtrl,  decoration: const InputDecoration(labelText: 'Description')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await DBHelper.insertTask(Task(
                title: titleCtrl.text,
                description: descCtrl.text,
                createdAt: DateTime.now().toIso8601String(),
              ));
              if (mounted) Navigator.pop(context);
              _loadTasks();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _syncTasks() async {
    final msg = await SyncService.syncToFirestore();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      _loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STRM App'),
        actions: [
          IconButton(icon: const Icon(Icons.sync), onPressed: _syncTasks, tooltip: 'Sync to Cloud'),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: Column(children: [
        const OfflineBanner(),   // shows only when offline
        Expanded(child: [_buildTasksTab(), _buildResourcesTab()][_currentTab]),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.public),   label: 'Resources'),
        ],
      ),
      floatingActionButton: _currentTab == 0
        ? FloatingActionButton(onPressed: _addTaskDialog, child: const Icon(Icons.add))
        : null,
    );
  }

  Widget _buildTasksTab() {
    if (_tasks.isEmpty) return const Center(child: Text('No tasks yet. Tap + to add one.'));
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (_, i) {
        final t = _tasks[i];
        return ListTile(
          title: Text(t.title),
          subtitle: Text(t.description),
          trailing: Icon(
            t.isSynced ? Icons.cloud_done : Icons.cloud_upload,
            color: t.isSynced ? Colors.green : Colors.orange,
          ),
        );
      },
    );
  }

  Widget _buildResourcesTab() {
    if (_loadingPosts) return const Center(child: CircularProgressIndicator());
    if (_postError != null) return Center(child: Text('Error: $_postError'));
    return ListView.builder(
      itemCount: _posts.length,
      itemBuilder: (_, i) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          title: Text(_posts[i].title),
          subtitle: Text(_posts[i].body, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}