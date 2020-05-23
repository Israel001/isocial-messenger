import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isocial_messenger/pages/ConversationList.dart';
import 'package:isocial_messenger/widgets/ProgressWidget.dart';
import 'package:isocial_messenger/blocs/authentication/Bloc.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  bool _obscureText = true;
  String _email, _password;
  AuthenticationBloc authenticationBloc;

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
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    });
  }

  InputDecoration textFieldDecoration(
      {String labelText, String hintText, Icon icon, FocusNode focusNode,
        bool obscureText}) {
    return InputDecoration(
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).accentColor)
      ),
      labelStyle: TextStyle(
        color: focusNode.hasFocus ? Theme.of(context).accentColor : Colors.grey
      ),
      suffixIcon: obscureText ? GestureDetector(
        onTap: () => setState(() =>  _obscureText = !_obscureText),
        child: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: focusNode.hasFocus ? Theme.of(context).accentColor : Colors.grey
        )
      ) : Text(''),
      labelText: labelText,
      hintText: hintText,
      icon: icon
    );
  }

  Widget _showTitle() {
    return Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: Text(
        'Log In',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30.0
        )
      )
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: TextFormField(
        focusNode: _emailFocusNode,
        onSaved: (val) => _email = val,
        decoration: textFieldDecoration(
          labelText: 'Email Address',
          hintText: 'Enter your email address',
          icon: Icon(
            Icons.mail,
            color: _emailFocusNode.hasFocus
                ? Theme.of(context).accentColor : Colors.grey
          ),
          focusNode: _emailFocusNode,
          obscureText: false
        )
      )
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: TextFormField(
        focusNode: _passwordFocusNode,
        onSaved: (val) => _password = val,
        obscureText: _obscureText,
        decoration: textFieldDecoration(
          labelText: 'Password',
          hintText: 'Enter your password',
          icon: Icon(
            Icons.lock,
            color: _passwordFocusNode.hasFocus
                ? Theme.of(context).accentColor : Colors.grey
          ),
          focusNode: _passwordFocusNode,
          obscureText: true
        )
      )
    );
  }

  Widget _showFormActions() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              if (state is AuthInProgress) {
                return circularProgress(context);
              } else {
                return RaisedButton(
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.black
                    )
                  ),
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                  ),
                  onPressed: () => BlocProvider.of<AuthenticationBloc>(
                    context
                  ).dispatch(ClickedLoginButton(_email, _password)),
                  color: Theme.of(context).accentColor,
                );
              }
            }
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _showTitle(),
                  _showEmailInput(),
                  _showPasswordInput(),
                  _showFormActions()
                ]
              )
            )
          )
        )
      )
    );
  }
}
