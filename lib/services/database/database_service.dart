import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitterclone/models/post.dart';
import 'package:twitterclone/models/user.dart';
import 'package:twitterclone/services/auth/auth_service.dart';

class DatabaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  //User ptofole

  Future<void> saveUserInfoFirebase({required String name, email}) async {
    String uid = _auth.currentUser!.uid;
    String username = email.split('@')[0];

    UserProfile user = UserProfile(
      uid: uid,
      name: name,
      email: email,
      username: username,
      bio: '',
    );

    final userMap = user.toMap();
    await _db.collection('Users').doc(uid).set(userMap);
  }

  // Get user info
  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection("Users").doc(uid).get();
      // convert doc to profile
      return UserProfile.fromDocument(userDoc);
    } catch (e) {
      print(e);
      return null;
    }
  }

  //Update bio
  Future<void> updateUserBioInFirebase(String bio) async {
    String uid = AuthService().getCurrentUid();

    try {
      await _db.collection("Users").doc(uid).update({'bio': bio});
    } catch (e) {
      print(e);
    }
  }
  // Post message

  Future<void> postMessageInFirebase(String message) async {
    try {
      String uid = _auth.currentUser!.uid;
      UserProfile? user = await getUserFromFirebase(uid);

      Post newPost = Post(
        id: '',
        uid: uid,
        name: user!.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
        likeCount: 0,
        likedBy: [],
      );

      Map<String, dynamic> newPostMap = newPost.toMap();
      await _db.collection('Posts').add(newPostMap);
    } catch (e) {}
  }

  // Get post

  Future<List<Post>> getAllPostsFromFirebase() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("Posts")
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  //Delete post

  Future<void> deletePostFromFirebase(String postId) async {
    try {
      await _db.collection("Posts").doc(postId).delete();
    } catch (e) {
      print(e);
    }
  }

  //Like
  //like post
  Future<void> toggleLikeInFirebase(String postId) async {
    try {
      // get current uid
      String uid = _auth.currentUser!.uid;

      // go to doc for this post
      DocumentReference postDoc = _db.collection("Posts").doc(postId);

      // execute like
      await _db.runTransaction((transaction) async {
        // get post data
        DocumentSnapshot postSnapshot = await transaction.get(postDoc);

        // get like of users who like this post
        List<String> likedBy = List<String>.from(postSnapshot['likedBy'] ?? []);

        // get like count
        int currentLikeCount = postSnapshot['like'];

        // if user has not liked this post yet => then like
        if (!likedBy.contains(uid)) {
          likedBy.add(uid);

          //increment
          currentLikeCount++;
        }
        // if user has already liked this post => then unlike
        else {
          likedBy.remove(uid);

          currentLikeCount--;
        }
        //update

        transaction.update(postDoc, {
          'likes': currentLikeCount,
          'likedBy': likedBy,
        });
      });
    } catch (e) {
      print(e);
    }
  }

  //Comments

  // Account stuff

  // Flow
}
