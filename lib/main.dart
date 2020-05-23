import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:isocial_messenger/pages/AuthPage.dart';
import 'package:isocial_messenger/pages/ConversationList.dart';

import 'package:isocial_messenger/repositories/AuthenticationRepository.dart';
import 'package:isocial_messenger/repositories/StorageRepository.dart';
import 'package:isocial_messenger/repositories/ChatRepository.dart';
import 'package:isocial_messenger/repositories/UserDataRepository.dart';
import 'package:isocial_messenger/widgets/ProgressWidget.dart';

import 'config/Constants.dart';
import 'config/Themes.dart';
import 'utils/SharedObjects.dart';
import 'blocs/authentication/Bloc.dart';
import 'blocs/chat/Bloc.dart';

void main() async {
  final AuthenticationRepository authRepository = AuthenticationRepository();
  final UserDataRepository userDataRepository = UserDataRepository();
  final ChatRepository chatRepository = ChatRepository();
  final StorageRepository storageRepository = StorageRepository();
  SharedObjects.prefs = await CachedSharedPreferences.getInstance();
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true);
  Constants.downloadsDirPath = (await DownloadsPathProvider.downloadsDirectory)
    .path;

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          builder: (context) => AuthenticationBloc(
            authenticationRepository: authRepository,
            userDataRepository: userDataRepository
          )..dispatch(AppLaunched()),
        ),
        BlocProvider<ChatBloc>(
          builder: (context) => ChatBloc(
            chatRepository: chatRepository,
            storageRepository: storageRepository,
            userDataRepository: userDataRepository
          )
        )
      ],
      child: iSocialMessenger()
    )
  );
}

// ignore: camel_case_types
class iSocialMessenger extends StatefulWidget {
  @override
  iSocialMessengerState createState() => iSocialMessengerState();
}

// ignore: camel_case_types
class iSocialMessengerState extends State<iSocialMessenger> {
  static ThemeData theme = SharedObjects.prefs.getBool(Constants.configDarkMode)
    ? Themes.dark : Themes.light;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iSocial Messenger',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is UnAuthenticated) {
            return AuthPage();
          } else if (state is Authenticated) {
            return ConversationList();
          } else {
            return Container(
              color: Colors.white,
              child: circularProgress(context)
            );
          }
        }
      ),
    );
  }
}
