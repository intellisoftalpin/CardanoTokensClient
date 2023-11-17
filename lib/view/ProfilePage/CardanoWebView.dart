import 'dart:io';
import 'package:crypto_offline/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../data/model/CardanoModel.dart';
import 'CardanoDescriptionPage.dart';

class CardanoWebView extends StatefulWidget {
  final String url;
  final String appBar;
  final Tokens token;
  final double exchangeAda;

  const CardanoWebView(
      {Key? key,
      required this.url,
      required this.appBar,
      required this.token,
      required this.exchangeAda})
      : super(key: key);

  @override
  _CardanoWebViewState createState() => _CardanoWebViewState();
}

class _CardanoWebViewState extends State<CardanoWebView> {

  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  void dispose() {
    super.dispose();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      elevation: 0.0,
      centerTitle: true,
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(
        widget.appBar,
        style: kAppBarTextStyle(context),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          size: Theme.of(context).iconTheme.copyWith(size: MediumIcon).size,
          color: Theme.of(context).focusColor,
        ),
        onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => CardanoDescriptionPage(
                    token: widget.token, exchangeAda: widget.exchangeAda)),
                (Route<dynamic> route) => false),
      ),
    );
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => CardanoDescriptionPage(
                      token: widget.token, exchangeAda: widget.exchangeAda)),
                  (Route<dynamic> route) => false);
        },
        child: Scaffold(
            appBar: appBar,
            body: SizedBox(
                height: MediaQuery.of(context).size.height -
                    appBar.preferredSize.height -
                    MediaQuery.of(context).viewPadding.top,
                width: MediaQuery.of(context).size.width,
                child: WebView(
                    javascriptMode: JavascriptMode.unrestricted,
                    initialUrl: widget.url))));
  }
}
