import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:crypto_offline/view/ProfilePage/ProfilePage.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  final String platform;
  final String image;

  const AboutPage({Key? key, required this.platform, required this.image})
      : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final platform = widget.platform;
    final image = widget.image;
    String version = _packageInfo.version;
    int dots = version.replaceAll(new RegExp(r'[^\\.]'), '').length;
    if (dots == 3) {
      var pos = version.lastIndexOf('.');
      version = (pos != -1) ? version.substring(0, pos) : version;
      print('VERSION:: $version');
    }
    AssetImage background = AssetImage('assets/background/background.png');
    if (Theme.of(context).primaryColor == lBackgroundColor) {
      background = AssetImage('assets/background/background_lt.png');
    } else if (Theme.of(context).primaryColor == kBackgroundColor) {
      background = AssetImage('assets/background/background.png');
    }
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ProfilePage()));
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              LocaleKeys.about.tr(),
              style: kAppBarTextStyle(context),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 35.0,
                color: Theme.of(context).focusColor,
              ),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => ProfilePage())),
            ),
            backgroundColor: Theme.of(context).splashColor,
            centerTitle: true,
            elevation: 0.0,
            bottomOpacity: 0.0,
          ),
          body: Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
                image: DecorationImage(image: background, fit: BoxFit.cover)),
            child: Center(
                child:
                    portrait(image, platform, _packageInfo, version, context)),
          ),
        ));
  }

  Widget portrait(String image, String platform, PackageInfo info,
      String version, BuildContext context) {
    String tiktok = '';
    String twitter = '';
    String web = '';
    String youtube = '';
    if (Theme.of(context).focusColor == lAppBarIconColor) {
      tiktok = 'assets/icons/l_tiktok.png';
      twitter = 'assets/icons/l_twitter.png';
      web = 'assets/icons/l_web.png';
      youtube = 'assets/icons/l_youtube.png';
    } else {
      tiktok = 'assets/icons/d_tiktok.png';
      twitter = 'assets/icons/d_twitter.png';
      web = 'assets/icons/d_web.png';
      youtube = 'assets/icons/d_youtube.png';
    }
    return Column(
      children: [
        SizedBox(
          height: 40.0,
        ),
        Container(
          width: 120.0,
          child: ClipOval(
            child: Image.asset(
              'assets/icons/cardano_logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(
          height: 24.0,
        ),
        SizedBox(
          child: Column(
            children: [
              Text(
                "Cardano Tokens",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: textSize24,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                "v. $version   build ${info.buildNumber}",
                style: TextStyle(
                  color: Theme.of(context).focusColor,
                  fontSize: textSize14,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              SizedBox(
                height: 36.0,
              ),
              Text(
                LocaleKeys.platform.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: textSize24,
                ),
              ),
              SizedBox(
                height: 14.0,
              ),
              SvgPicture.asset(
                image,
                width: 40.0,
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(platform),
            ],
          ),
        ),
        Container(
            margin: EdgeInsets.only(bottom: 10.0),
            height: MediaQuery.of(context).size.width * 0.10,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.width * 0.10,
                  width: MediaQuery.of(context).size.width * 0.10,
                  child: InkWell(
                    onTap: () {
                      Fluttertoast.showToast(msg: 'web_link');
                    },
                    child: Image.asset(web, fit: BoxFit.fitHeight),
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Container(
                  height: MediaQuery.of(context).size.width * 0.10,
                  width: MediaQuery.of(context).size.width * 0.10,
                  child: InkWell(
                    onTap: () {
                      Fluttertoast.showToast(msg: 'twitter_link');
                    },
                    child: Image.asset(twitter, fit: BoxFit.fitHeight),
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Container(
                  height: MediaQuery.of(context).size.width * 0.10,
                  width: MediaQuery.of(context).size.width * 0.10,
                  child: InkWell(
                    onTap: () {
                      Fluttertoast.showToast(msg: 'tiktok_link');
                    },
                    child: Image.asset(tiktok, fit: BoxFit.fitHeight),
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Container(
                  height: MediaQuery.of(context).size.width * 0.10,
                  width: MediaQuery.of(context).size.width * 0.10,
                  child: InkWell(
                    onTap: () {
                      Fluttertoast.showToast(msg: 'youtube_link');
                    },
                    child: Image.asset(youtube, fit: BoxFit.fitHeight),
                  ),
                ),
              ],
            )),
        launchUrlAbout(context),
      ],
    );
  }

  Widget launchUrlAbout(BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: 20.0),
        child: Center(
          child: new InkWell(
            onTap: () {
              final url = Uri.parse("https://ctokens.io/about");
              print('LAUNCH_URL: https://ctokens.io/about');
              launchUrl(
                url,
                mode: LaunchMode.externalApplication,
              );
              //Navigator.push(
              //    context,
              //    MaterialPageRoute(
              //        builder: (context) =>
              //            WebAboutPage(
              //                platform: widget.platform,
              //                image: widget.image,
              //                url: 'https://ctokens.io/about')));
            },
            child: new Text('ctokens.io/about'),
          ),
        ),
      );
}
