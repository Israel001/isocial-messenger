import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isocial_messenger/blocs/authentication/Bloc.dart';
import 'package:isocial_messenger/blocs/chat/Bloc.dart';
import 'package:isocial_messenger/config/Constants.dart';
import 'package:isocial_messenger/config/Palette.dart';
import 'package:isocial_messenger/utils/SharedObjects.dart';

import 'AuthPage.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage> {
  AuthenticationBloc authenticationBloc;
  bool darkMode = SharedObjects.prefs.getBool(Constants.configDarkMode);
  ChatBloc chatBloc;
  
  @override
  void initState() {
    super.initState();
    authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Me', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 30.0)),
          Center(
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                SharedObjects.prefs.getString(Constants.sessionPhoto),
              ),
              radius: 50
            )
          ),
          Padding(padding: EdgeInsets.only(top: 20.0)),
          Center(
            child: Text(
              SharedObjects.prefs.getString(Constants.sessionName),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30.0
              )
            )
          ),
          Padding(padding: EdgeInsets.only(top: 30.0)),
          SwitchListTile(
            title: Text('Dark mode'),
            value: darkMode,
            onChanged: (bool value) {
              setState(() {
                darkMode = value;
                SharedObjects.prefs.setBool(Constants.configDarkMode, value);
              });
            },
            secondary: Image.asset(
              'assets/dark_mode.png', height: 40, width: 40,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white : Colors.black,
            )
          ),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          ListTile(
            leading: Icon(
              Icons.settings, size: 40.0, color: Palette.accentColor
            ),
            title: Text('Account settings'),
          ),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          ListTile(
            leading: Icon(
              Icons.warning, size: 40.0, color: Colors.red
            ),
            title: Text('Report technical problem')
          ),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          ListTile(
            leading: Image.asset(
              'assets/question_mark.png', height: 40, width: 40
            ),
            title: Text('Help')
          ),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          ListTile(
            leading: Image.asset(
              'assets/book.png', height: 40, width: 40,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white : Colors.black
            ),
            title: Text('Legal and policies')
          ),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          ListTile(
            onTap: () {
              authenticationBloc.dispatch(ClickedLogout());
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthPage()
                )
              );
            },
            leading: Icon(
              Icons.power_settings_new, size: 40.0, color: Colors.red
            ),
            title: Text('Logout')
          )
        ],
      )
    );
  }
}
