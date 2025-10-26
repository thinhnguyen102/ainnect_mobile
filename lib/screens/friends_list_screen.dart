import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class FriendsListScreen extends StatelessWidget {
  final List<dynamic> friends;

  FriendsListScreen({Key? key, required this.friends}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends List'),
      ),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: friend['avatarUrl'] != null
                  ? NetworkImage(friend['avatarUrl'])
                  : null,
              child: friend['avatarUrl'] == null
                  ? Icon(Icons.person)
                  : null,
            ),
            title: Text(friend['displayName'] ?? 'Unknown'),
            subtitle: Text(friend['username'] ?? ''),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2),
    );
  }
}