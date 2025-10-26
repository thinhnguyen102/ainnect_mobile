import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class FriendRequestsScreen extends StatelessWidget {
  final List<dynamic> friendRequests;

  FriendRequestsScreen({Key? key, required this.friendRequests}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Requests'),
      ),
      body: ListView.builder(
        itemCount: friendRequests.length,
        itemBuilder: (context, index) {
          final request = friendRequests[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: request['avatarUrl'] != null
                  ? NetworkImage(request['avatarUrl'])
                  : null,
              child: request['avatarUrl'] == null
                  ? Icon(Icons.person)
                  : null,
            ),
            title: Text(request['displayName'] ?? 'Unknown'),
            subtitle: Text(request['username'] ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    // Handle accept friend request
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    // Handle decline friend request
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }
}