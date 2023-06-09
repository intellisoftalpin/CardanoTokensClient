import 'dart:io';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'ProfilePage.dart';

class PrivacyPolicyPage extends StatefulWidget {
  final url;
  PrivacyPolicyPage(this.url);

  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {

  final _key = UniqueKey();

  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ProfilePage()));
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          LocaleKeys.privacy_policy.tr(),
          style: kPrivacyAppBarTextStyle(context),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: Theme.of(context).iconTheme.copyWith(size: MediumIcon).size,
            color: Theme.of(context).focusColor,
          ),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => ProfilePage())),
        ),
      ),
      body:  Column(
        children: [
          Expanded(
              child: WebView(
                  key: _key,
                  javascriptMode: JavascriptMode.unrestricted,
                  initialUrl: widget.url))
        ],
      )));

      /*FutureBuilder(
          future: rootBundle.loadString("assets/privacy_policy.md"),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return SafeArea(child: Markdown(data: snapshot.data.toString()));
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),*/
  }
}
