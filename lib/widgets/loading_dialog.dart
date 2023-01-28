
import 'package:flutter/material.dart';

class LoadingDialog {
  static void showLoadingDialog(BuildContext context, String msg) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
              child: Container(
                height: 100,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text(
                        msg,
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop(context);
  }
}

class LoadingDialog2 {
  static void showLoadingDialog(BuildContext context, String msg) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
              child: Container(
                height: 300,
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // CircularProgressIndicator(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: Text(
                        msg,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Image.asset('assets/images/Radar.gif'),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/Triangle-indicator.gif'),
                        const SizedBox(
                          width: 40,
                        ),
                        Image.asset('assets/images/Triangle-indicator.gif'),
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    MaterialButton(
                        onPressed: () {
                          // Globals.timing.cancel();
                          Navigator.of(context).pop(context);
                        },
                        child: const Text(
                          "Close",
                          style: TextStyle(color: Colors.red),
                        ))
                  ],
                ),
              ),
            ));
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop(context);
  }
}
