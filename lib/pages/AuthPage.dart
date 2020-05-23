import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:isocial_messenger/config/Assets.dart';

import 'package:isocial_messenger/pages/LoginPage.dart';

import 'package:isocial_messenger/blocs/authentication/Bloc.dart';
import 'package:isocial_messenger/widgets/ProgressWidget.dart';

import 'ConversationList.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AuthPageState();
  }
}

class AuthPageState extends State<AuthPage> {
  AuthenticationBloc authenticationBloc;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    authenticationBloc.state.listen((state) {
      if (state is Authenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationList()
          )
        );
      }
    });
    authenticationBloc.state.listen((state) {
      if (state is AuthError) {
        SnackBar snackBar = SnackBar(
          content: Text(state.err, overflow: TextOverflow.ellipsis),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 3000)
        );
        scaffoldKey.currentState.showSnackBar(snackBar);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        color: Colors.white,
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Image.asset(
                        Assets.app_icon,
                        width: 80,
                        height: 80
                      )
                    )
                  ]
                )
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      padding: EdgeInsets.symmetric(horizontal: 80.0),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26.5
                          )
                        )
                      ),
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage())
                        );
                      },
                    )
                  ]
                )
              ),
              Expanded(
                flex: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 30.0),
                      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
                        builder: (context, state) {
                          if (state is AuthInProgress) {
                            return circularProgress(context);
                          }
                          return GestureDetector(
                            onTap: () => BlocProvider.of<AuthenticationBloc>(
                              context
                            ).dispatch(ClickedGoogleLogin()),
                            child: Container(
                              width: 260.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    Assets.google_button
                                  ),
                                  fit: BoxFit.cover
                                )
                              )
                            )
                          );
                        }
                      )
                    )
                  ],
                )
              )
            ]
        )
      )
    );
  }
}
