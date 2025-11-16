import 'package:flutter/material.dart';
import 'package:twitterclone/components/my_post_tile.dart';
import 'package:twitterclone/helper/navigate_page.dart';
import 'package:twitterclone/models/post.dart';

class PostPage extends StatefulWidget {
  final Post post;
  const PostPage({super.key, required this.post});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  //build ui
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(foregroundColor: Theme.of(context).colorScheme.primary),

      //body
      body: ListView(
        children: [
          //post
          MyPostTile(
            post: widget.post,
            onUserTap: () => goUserPage(context, widget.post.uid),
            onPostTap: () {},
          ),
          //comments
        ],
      ),
    );
  }
}
