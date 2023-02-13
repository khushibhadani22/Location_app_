import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
}

class LOC extends StatefulWidget {
  const LOC({Key? key}) : super(key: key);

  @override
  State<LOC> createState() => _LOCState();
}

class _LOCState extends State<LOC> {
  InAppWebViewController? inAppWebViewController;
  late PullToRefreshController pullToRefreshController;
  @override
  void initState() {
    super.initState();
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.blue),
      onRefresh: () async {
        if (Platform.isAndroid) {
          await inAppWebViewController!.reload();
        } else if (Platform.isIOS) {
          await inAppWebViewController!.loadUrl(
              urlRequest:
                  URLRequest(url: await inAppWebViewController!.getUrl()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Map detail = ModalRoute.of(context)!.settings.arguments as Map;
    return SafeArea(
        child: Scaffold(
      body: InAppWebView(
        pullToRefreshController: pullToRefreshController,
        initialUrlRequest: URLRequest(url: Uri.parse(detail['lat - long'])),
        onLoadStop: (controller, url) async {
          await pullToRefreshController.endRefreshing();
        },
        onWebViewCreated: (val) {
          setState(() {
            inAppWebViewController = val;
          });
        },
      ),
    ));
  }
}
