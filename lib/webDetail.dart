import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
}

class Web extends StatefulWidget {
  const Web({Key? key}) : super(key: key);

  @override
  State<Web> createState() => _WebState();
}

class _WebState extends State<Web> {
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
    Map detail2 = ModalRoute.of(context)!.settings.arguments as Map;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            if (await inAppWebViewController!.canGoBack()) {
              await inAppWebViewController!.goBack();
            }
          },
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
        ),
        title: Text(
          "${detail2['title']}",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              if (await inAppWebViewController!.canGoForward()) {
                await inAppWebViewController!.goForward();
              }
            },
            icon: const Icon(Icons.arrow_forward_ios),
            color: Colors.white,
          ),
        ],
        backgroundColor: Colors.black,
      ),
      body: InAppWebView(
        pullToRefreshController: pullToRefreshController,
        initialUrlRequest: URLRequest(url: Uri.parse(detail2['link'])),
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
