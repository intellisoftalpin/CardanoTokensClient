import 'dart:io';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/view/ProfilePage/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebBlogPage extends StatefulWidget {
  final String url;

  const WebBlogPage({Key? key, required this.url})
      : super(key: key);

  @override
  _WebBlogPageState createState() => _WebBlogPageState();
}

class _WebBlogPageState extends State<WebBlogPage> {
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
        LocaleKeys.cardanoBlog.tr(),
        style: kAppBarTextStyle(context),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          size: Theme.of(context).iconTheme.copyWith(size: MediumIcon).size,
          color: Theme.of(context).focusColor,
        ),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProfilePage())),
      ),
    );
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage()));
          return true;
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