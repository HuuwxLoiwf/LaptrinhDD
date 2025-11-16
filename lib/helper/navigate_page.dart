import 'package:flutter/material.dart';
import 'package:twitterclone/pages/post_page.dart';
import 'package:twitterclone/pages/profile_page.dart';

import '../models/post.dart';

void goUserPage(BuildContext context, String uid) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ProfilePage(uid: uid)),
  );
}

//go to post page

void goPostPage(BuildContext context, Post post) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PostPage(post: post)),
  );
}
