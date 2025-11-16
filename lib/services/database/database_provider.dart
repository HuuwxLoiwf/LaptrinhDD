import 'package:flutter/material.dart';
import 'package:twitterclone/models/post.dart';
import 'package:twitterclone/models/user.dart';
import 'package:twitterclone/services/auth/auth_service.dart';
import 'package:twitterclone/services/database/database_service.dart';

class DatabaseProvider extends ChangeNotifier {
  final _auth = AuthService();
  final _db = DatabaseService();

  //get user
  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);

  //update bio
  Future<void> updateBio(String bio) => _db.updateUserBioInFirebase(bio);

  //Post

  List<Post> _allPosts = [];

  List<Post> get allPosts => _allPosts;

  Future<void> postMessage(String message) async {
    await _db.postMessageInFirebase(message);
    //load
    await loadAllPosts();
  }

  Future<void> loadAllPosts() async {
    final allPosts = await _db.getAllPostsFromFirebase();

    _allPosts = allPosts;
    //inittalize
    initializeLikeMap();

    notifyListeners();
  }

  //filter and return
  List<Post> filterUserPorts(String uid) {
    return _allPosts.where((post) => post.uid == uid).toList();
  }

  //delete post
  Future<void> deletePost(String postId) async {
    //delete
    await _db.deletePostFromFirebase(postId);

    //reload
    await loadAllPosts();
  }

  //LIKES

  // Local map to track like counts for each post
  Map<String, int> _likeCounts = {
    // for each post id: like count
  };

  // Local list to track posts liked by current user
  List<String> _likedPosts = [];

  //dose current user like
  bool isPostLikeByCurrentUser(String postId) => _likedPosts.contains(postId);
  //get like count
  int getLikeCount(String postId) => _likeCounts[postId] ?? 0;

  // initialize like map locally
  void initializeLikeMap() {
    // get current uid
    final currentUserID = _auth.getCurrentUid();

    //clear liked post
    _likedPosts.clear();

    // for each post get like data
    for (var post in _allPosts) {
      // update like count map
      _likeCounts[post.id] = post.likeCount;

      // if the current user already likes this post
      if (post.likedBy.contains(currentUserID)) {
        // add this post id to local list of liked posts
        _likedPosts.add(post.id);
      }
    }
  }

  //toggle like

  Future<void> toggleLike(String postId) async {
    // store original values in case it fails
    final likedPostsOriginal = _likedPosts;
    final likeCountsOriginal = _likeCounts;

    // perform like / unlike
    if (_likedPosts.contains(postId)) {
      _likedPosts.remove(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) - 1;
    } else {
      _likedPosts.add(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) + 1;
    }

    // update UI locally
    notifyListeners();

    /*

Now let's try to update it in our database

*/

    //empty like indatabase

    try {
      await _db.toggleLikeInFirebase(postId);
    } catch (e) {
      _likedPosts = likedPostsOriginal;
      _likeCounts = likeCountsOriginal;

      notifyListeners();
    }
  }
}
