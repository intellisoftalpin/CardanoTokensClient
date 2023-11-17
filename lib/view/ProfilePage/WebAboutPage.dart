import 'dart:io';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'AboutPage.dart';

class WebAboutPage extends StatefulWidget {
  final String platform;
  final String image;
  final String url;

  const WebAboutPage(
      {Key? key,
      required this.url,
      required this.image,
      required this.platform})
      : super(key: key);

  @override
  _WebAboutPageState createState() => _WebAboutPageState();
}

class _WebAboutPageState extends State<WebAboutPage> {
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      elevation: 0.0,
      centerTitle: true,
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(
        LocaleKeys.about.tr(),
        style: kAppBarTextStyle(context),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          size: Theme.of(context).iconTheme.copyWith(size: MediumIcon).size,
          color: Theme.of(context).focusColor,
        ),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => AboutPage(
          platform: widget.platform,
          image: widget.image,
        ))),
      ),
    );
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AboutPage(
            platform: widget.platform,
            image: widget.image,
          )));
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
