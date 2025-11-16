import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitterclone/components/my_bio_box.dart';
import 'package:twitterclone/components/my_input_alert_box.dart';
import 'package:twitterclone/components/my_post_tile.dart';
import 'package:twitterclone/helper/navigate_page.dart';
import 'package:twitterclone/models/user.dart';
import 'package:twitterclone/services/auth/auth_service.dart';
import 'package:twitterclone/services/database/database_provider.dart';

//profile
class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //provider
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );
  //user info
  UserProfile? user;
  String currentUserId = AuthService().getCurrentUid();

  //text controller bio
  final bioTextController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    loadUser();
  }

  Future<void> loadUser() async {
    user = await databaseProvider.userProfile(widget.uid);

    setState(() {
      _isLoading = false;
    });
  }

  void _showEditBioBox() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
        textController: bioTextController,
        hintText: 'Edit bio',
        onPressed: saveBio,
        onPressedText: "Save",
      ),
    );
  }

  //save bio
  Future<void> saveBio() async {
    setState(() {
      _isLoading = true;
    });

    await databaseProvider.updateBio(bioTextController.text);

    await loadUser();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    //get use posts

    final allUserPosts = listeningProvider.filterUserPorts(widget.uid);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _isLoading ? '' : (user?.name ?? 'Unknown User'),
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      //body
      body: ListView(
        children: [
          Center(
            child: Text(
              _isLoading ? '' : '@${user?.username ?? 'Unknown'}',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),

          const SizedBox(height: 25),

          // profile picture
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(21),
              ), // BoxDecoration
              padding: const EdgeInsets.all(25),
              child: Icon(
                Icons.person,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          //edit bio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bio',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                GestureDetector(
                  onTap: _showEditBioBox,
                  child: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          //Bio
          MyBioBox(text: _isLoading ? '...' : user!.bio),

          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 25.0),
            child: Text(
              'Posts',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          //list of posts from user
          allUserPosts.isEmpty
              ? const Center(child: Text("No posts yet.."))
              : ListView.builder(
                  itemCount: allUserPosts.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    //get individual
                    final post = allUserPosts[index];

                    return MyPostTile(
                      post: post,
                      onUserTap: () {},
                      onPostTap: () => goPostPage(context, post),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
