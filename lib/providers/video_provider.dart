import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/video_model.dart';

class VideoProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Video> _videos = [];
  bool _isLoading = false;

  List<Video> get videos => _videos.where((v) => v.isApproved).toList();
  List<Video> get pendingVideos => _videos.where((v) => !v.isApproved).toList();
  bool get isLoading => _isLoading;

  VideoProvider() {
    loadVideos(); // Call public method instead of private
  }

  // ✅ Make this public (remove underscore)
  Future<void> loadVideos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('videos').get();
      _videos = snapshot.docs.map((doc) => Video.fromMap(doc.id, doc.data())).toList();

      // Verify local files exist
      for (var video in _videos) {
        if (!File(video.localPath).existsSync()) {
          await _firestore.collection('videos').doc(video.id).delete();
          _videos.remove(video);
        }
      }
    } catch (e) {
      debugPrint('Error loading videos: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> uploadVideo({
    required String title,
    required String description,
    required File videoFile,
    required String uploaderId,
    required String uploaderName,
    List<String> tags = const [],
  }) async {
    try {
      // Save video to app's local directory
      final appDir = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${appDir.path}/videos');
      if (!await videoDir.exists()) {
        await videoDir.create();
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
      final localPath = '${videoDir.path}/$fileName';

      await videoFile.copy(localPath);

      final video = Video(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        localPath: localPath,
        thumbnailPath: null,
        uploaderId: uploaderId,
        uploaderName: uploaderName,
        uploadDate: DateTime.now(),
        isApproved: false,
        likes: 0,
        tags: tags,
      );

      await _firestore.collection('videos').doc(video.id).set(video.toMap());
      _videos.add(video);
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error uploading video: $e');
      return false;
    }
  }

  Future<void> approveVideo(String videoId) async {
    final video = _videos.firstWhere((v) => v.id == videoId);
    final updatedVideo = Video(
      id: video.id,
      title: video.title,
      description: video.description,
      localPath: video.localPath,
      thumbnailPath: video.thumbnailPath,
      uploaderId: video.uploaderId,
      uploaderName: video.uploaderName,
      uploadDate: video.uploadDate,
      isApproved: true,
      likes: video.likes,
      tags: video.tags,
    );

    await _firestore.collection('videos').doc(videoId).update({'isApproved': true});
    final index = _videos.indexWhere((v) => v.id == videoId);
    _videos[index] = updatedVideo;
    notifyListeners();
  }

  Future<void> deleteVideo(String videoId) async {
    final video = _videos.firstWhere((v) => v.id == videoId);

    // Delete local file
    try {
      await File(video.localPath).delete();
      if (video.thumbnailPath != null) {
        await File(video.thumbnailPath!).delete();
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }

    await _firestore.collection('videos').doc(videoId).delete();
    _videos.removeWhere((v) => v.id == videoId);
    notifyListeners();
  }

  Future<void> likeVideo(String videoId) async {
    final video = _videos.firstWhere((v) => v.id == videoId);
    final newLikes = video.likes + 1;

    await _firestore.collection('videos').doc(videoId).update({'likes': newLikes});

    final index = _videos.indexWhere((v) => v.id == videoId);
    _videos[index] = Video(
      id: video.id,
      title: video.title,
      description: video.description,
      localPath: video.localPath,
      thumbnailPath: video.thumbnailPath,
      uploaderId: video.uploaderId,
      uploaderName: video.uploaderName,
      uploadDate: video.uploadDate,
      isApproved: video.isApproved,
      likes: newLikes,
      tags: video.tags,
    );
    notifyListeners();
  }
}