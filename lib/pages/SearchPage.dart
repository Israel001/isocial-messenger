import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isocial_messenger/config/Assets.dart';
import 'package:isocial_messenger/config/Constants.dart';
import 'package:isocial_messenger/models/Chat.dart';
import 'package:isocial_messenger/models/User.dart';
import 'package:isocial_messenger/utils/SharedObjects.dart';
import 'package:isocial_messenger/widgets/ProgressWidget.dart';

import 'ConversationList.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SearchPageState();
  }
}

class SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  List<DocumentSnapshot> queryResultSet = [];
  List<User> searchResults = [];
  List<String> tempStore = [];
  final usersRef = Firestore.instance.collection('users');
  String uId = SharedObjects.prefs.getString(Constants.sessionUid);

  @override
  void initState() {
    super.initState();
  }

  void handleSearch(String query) async {
    if (query.trim().isNotEmpty) {
      setState(() { isLoading = true; });
      query = query.toLowerCase();
      if (queryResultSet.length == 0 && query.length == 1) {
        QuerySnapshot users = await usersRef
          .where('searchKeys', arrayContains: query)
          .getDocuments();
        print(users.documents.length);
        for (int i = 0; i < users.documents.length; i++) {
          queryResultSet.add(users.documents[i]);
        }
      }
      searchResults = [];
      tempStore = [];
      queryResultSet.forEach((user) {
        if (user.data['displayName'].toLowerCase().startsWith(query)
            || user.data['username'].toLowerCase().startsWith(query)) {
          User deSerializedUser = User.fromDocument(user);
          searchResults.add(deSerializedUser);
          tempStore.add(user.data['displayName']);
        }
        if ((user.data['displayName'].toLowerCase().contains(query)
            || user.data['username'].toLowerCase().contains(query))
            && !tempStore.contains(user.data['displayName'])) {
          User deSerializedUser = User.fromDocument(user);
          searchResults.add(deSerializedUser);
        }
      });
      setState(() => isLoading = false);
    } else {
      setState(() {
        searchResults.clear();
        queryResultSet.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search...'
          ),
          controller: searchController,
          onChanged: handleSearch,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                searchController.clear();
                searchResults.clear();
                queryResultSet.clear();
              });
            },
          )
        ],
      ),
      body: isLoading ? circularProgress(context) : ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              Chat chat = new Chat(
                uId+searchResults[index].id,
                searchResults[index]
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationList(chat: chat)
                )
              );
            },
            leading: CircleAvatar(
              backgroundImage: searchResults[index].photoUrl.isNotEmpty
                  ? CachedNetworkImageProvider(searchResults[index].photoUrl)
                  : AssetImage(Assets.user)
            ),
            title: Text(
              searchResults[index].displayName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)
            )
          );
        },
      )
    );
  }
}
