import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/video_provider.dart';
import '../../models/user_model.dart';
import '../../models/video_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AppUser> _users = [];
  bool _isLoadingUsers = true;
  bool _isUploading = false;

  // Controllers for add video dialog
  final TextEditingController _videoTitleController = TextEditingController();
  final TextEditingController _videoDescriptionController = TextEditingController();
  final TextEditingController _videoTagsController = TextEditingController();
  File? _selectedVideo;
  VideoPlayerController? _previewController;
  bool _isPreviewPlaying = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoTitleController.dispose();
    _videoDescriptionController.dispose();
    _videoTagsController.dispose();
    _previewController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final users = await authProvider.getAllUsers();
    setState(() {
      _users = users;
      _isLoadingUsers = false;
    });
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      setState(() {
        _selectedVideo = File(video.path);
        _previewController?.dispose();
        _previewController = VideoPlayerController.file(File(video.path))
          ..initialize().then((_) {
            setState(() {});
          });
        _isPreviewPlaying = false;
      });
    }
  }

  Future<void> _recordVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.camera);

    if (video != null) {
      setState(() {
        _selectedVideo = File(video.path);
        _previewController?.dispose();
        _previewController = VideoPlayerController.file(File(video.path))
          ..initialize().then((_) {
            setState(() {});
          });
        _isPreviewPlaying = false;
      });
    }
  }

  void _togglePreviewPlay() {
    if (_previewController == null) return;
    setState(() {
      if (_isPreviewPlaying) {
        _previewController!.pause();
      } else {
        _previewController!.play();
      }
      _isPreviewPlaying = !_isPreviewPlaying;
    });
  }

  Future<void> _uploadVideoAsAdmin() async {
    if (_videoTitleController.text.isEmpty ||
        _videoDescriptionController.text.isEmpty ||
        _selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a video')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);

    List<String> tags = [];
    if (_videoTagsController.text.isNotEmpty) {
      tags = _videoTagsController.text.split(',').map((t) => t.trim()).toList();
    }

    final success = await videoProvider.uploadVideo(
      title: _videoTitleController.text,
      description: _videoDescriptionController.text,
      videoFile: _selectedVideo!,
      uploaderId: authProvider.currentUser!.id,
      uploaderName: authProvider.currentUser!.name,
      tags: tags,
    );

    setState(() {
      _isUploading = false;
    });

    if (success && mounted) {
      await videoProvider.approveVideo(videoProvider.pendingVideos.last.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video uploaded and approved successfully!')),
      );

      _videoTitleController.clear();
      _videoDescriptionController.clear();
      _videoTagsController.clear();
      setState(() {
        _selectedVideo = null;
        _previewController?.dispose();
        _previewController = null;
      });
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload video. Please try again.')),
      );
    }
  }

  void _showAddVideoDialog() {
    _videoTitleController.clear();
    _videoDescriptionController.clear();
    _videoTagsController.clear();
    setState(() {
      _selectedVideo = null;
      _previewController?.dispose();
      _previewController = null;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Educational Video'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _videoTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Video Title *',
                    hintText: 'Enter video title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _videoDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Enter video description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _videoTagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                    hintText: 'education, sign-language, tutorial',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Select Video',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickVideo,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _recordVideo,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                    ),
                  ],
                ),
                if (_selectedVideo != null && _previewController != null && _previewController!.value.isInitialized) ...[
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(_previewController!),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isPreviewPlaying ? Icons.pause : Icons.play_arrow,
                              size: 50,
                              color: Colors.white,
                            ),
                            onPressed: _togglePreviewPlay,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Video selected: ${_selectedVideo!.path.split('/').last}',
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _previewController?.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isUploading ? null : _uploadVideoAsAdmin,
            child: _isUploading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Upload Video'),
          ),
        ],
      ),
    );
  }

  void _playVideo(String videoPath, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoPath: videoPath, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          labelColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.white),
          controller: _tabController,
          tabs: const [
            Tab(child: Text("Users", style: TextStyle(color: Colors.white))),
            Tab(child: Text("Videos", style: TextStyle(color: Colors.white))),
            Tab(child: Text("Analytics", style: TextStyle(color: Colors.white))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_file_rounded),
            onPressed: _showAddVideoDialog,
            tooltip: 'Add Video',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildUsersTab(),
            _buildVideosTab(videoProvider),
            _buildAnalyticsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: user.role == 'admin' ? Colors.red : Colors.blue,
              child: Text(user.name[0].toUpperCase()),
            ),
            title: Text(user.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email),
                Text(
                  'Role: ${user.role} • Status: ${user.isActive ? "Active" : "Disabled"}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                if (user.isActive)
                  const PopupMenuItem(value: 'disable', child: Text('Disable Account')),
                if (!user.isActive)
                  const PopupMenuItem(value: 'enable', child: Text('Enable Account')),
                const PopupMenuItem(value: 'delete', child: Text('Delete Account', style: TextStyle(color: Colors.red))),
              ],
              onSelected: (value) async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                if (value == 'disable') {
                  await authProvider.updateUserStatus(user.id, false);
                  setState(() {
                    final index = _users.indexWhere((u) => u.id == user.id);
                    _users[index] = AppUser.fromMap(user.id, {
                      ...user.toMap(),
                      'isActive': false,
                    });
                  });
                } else if (value == 'enable') {
                  await authProvider.updateUserStatus(user.id, true);
                  setState(() {
                    final index = _users.indexWhere((u) => u.id == user.id);
                    _users[index] = AppUser.fromMap(user.id, {
                      ...user.toMap(),
                      'isActive': true,
                    });
                  });
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete User'),
                      content: Text('Are you sure you want to delete ${user.name}?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await authProvider.deleteUser(user.id);
                    setState(() {
                      _users.removeWhere((u) => u.id == user.id);
                    });
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideosTab(VideoProvider videoProvider) {
    return Column(
      children: [
        // Upload button at the top
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: _showAddVideoDialog,
            icon: const Icon(Icons.add),
            label: const Text('Upload New Video'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              minimumSize: const Size(double.infinity, 45),
            ),
          ),
        ),

        // Pending approvals section
        if (videoProvider.pendingVideos.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.orange.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Approval (${videoProvider.pendingVideos.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
                ),
                const SizedBox(height: 8),
                const Text('Videos need to be reviewed before they appear in the feed'),
              ],
            ),
          ),

        // Video list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: videoProvider.videos.length + videoProvider.pendingVideos.length,
            itemBuilder: (context, index) {
              final allVideos = [...videoProvider.pendingVideos, ...videoProvider.videos];
              if (index >= allVideos.length) return null;
              final video = allVideos[index];
              return _buildVideoCard(context, video, videoProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(BuildContext context, Video video, VideoProvider videoProvider) {
    return SafeArea(
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Preview Area
            GestureDetector(
              onTap: () => _playVideo(video.localPath, video.title),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Thumbnail placeholder
                    const Icon(Icons.play_circle_filled, size: 60, color: Colors.white),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow, size: 16, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Tap to play', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      
            // Video Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    video.description,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        video.uploaderName,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        video.uploadDate.toString().substring(0, 10),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      if (!video.isApproved)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Pending',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _playVideo(video.localPath, video.title),
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('Play'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!video.isApproved)
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () {
                            videoProvider.approveVideo(video.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Video approved!')),
                            );
                          },
                          tooltip: 'Approve Video',
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Video'),
                              content: const Text('Are you sure you want to delete this video?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () {
                                    videoProvider.deleteVideo(video.id);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Video deleted!')),
                                    );
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        tooltip: 'Delete Video',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Platform Statistics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildAnalyticsCard('Total Users', _users.length.toString(), Icons.people),
                  _buildAnalyticsCard('Active Users', _users.where((u) => u.isActive).length.toString(), Icons.person),
                  _buildAnalyticsCard('Total Videos', Provider.of<VideoProvider>(context).videos.length.toString(), Icons.video_library),
                  _buildAnalyticsCard('Pending Videos', Provider.of<VideoProvider>(context).pendingVideos.length.toString(), Icons.pending),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.person_add, color: Colors.green),
                    title: const Text('New User Registration'),
                    subtitle: Text('Last 24 hours: ${_users.where((u) => u.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 1)))).length}'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.video_call, color: Colors.blue),
                    title: const Text('Video Uploads'),
                    subtitle: Text('Last 7 days: ${Provider.of<VideoProvider>(context).videos.where((v) => v.uploadDate.isAfter(DateTime.now().subtract(const Duration(days: 7)))).length}'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1A237E)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// Video Player Screen for full playback
class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final String title;

  const VideoPlayerScreen({super.key, required this.videoPath, required this.title});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.file(File(widget.videoPath));
    await _controller.initialize();
    _controller.play();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _isInitialized
          ? Column(
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 40,
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying ? _controller.pause() : _controller.play();
                  });
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 40,
                onPressed: () {
                  _controller.seekTo(Duration.zero);
                },
              ),
            ],
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}