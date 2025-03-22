import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class DynamicContextWidgets {
  static final DynamicContextWidgets _instance =
      DynamicContextWidgets._internal();
  static BuildContext? _context;

  factory DynamicContextWidgets() {
    return _instance;
  }

  DynamicContextWidgets._internal();

  static void init(BuildContext context) {
    _context = context;
  }

  BuildContext get context {
    if (_context == null) {
      throw Exception(
          'DynamicContextWidgets not initialized. Call init() first.');
    }
    return _context!;
  }

  Future<void> bottomSheet(
      {required String title,
      required String msg,
      required IconData icon,
      required Future<void> Function() pressed,
      required String btnText}) async {
    if (_context != null && _context!.mounted) {
      await showModalBottomSheet(
          context: _context!,
          elevation: 8.0, // elevation of sheet
          backgroundColor:
              Colors.transparent, // background color of modal sheet
          isDismissible:
              false, // specifies whether the bottom sheet will be dismissed when user taps on the scrim.
          enableDrag:
              true, // specifies whether the bottom sheet can be dragged up and down and dismissed by swiping downwards.
          useSafeArea:
              true, // parameter specifies whether the sheet will avoid system intrusions on the top, left, and right
          builder: (BuildContext context) {
            Size size = MediaQuery.of(context).size; // Get the screen size.
            return Card(
              // Use a Card widget to create a visually distinct alert.
              elevation: 6, // Set the elevation of the card (shadow).
              shadowColor: Colors.black54, // Set the shadow color.
              color: Colors.white, // Set the background color of the card.
              margin:
                  const EdgeInsets.all(16.0), // Set margins around the card.
              shape: RoundedRectangleBorder(
                // Set the shape of the card with rounded corners.
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Container(
                // Container to hold the content within the card.
                width: size.width, // Set the width to the screen width.
                height: size.height *
                    0.12, // Set the height to 12% of the screen height.
                margin: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 6.0), // Set margins within the container.
                child: Row(
                  // Use a Row to arrange the content horizontally.
                  mainAxisAlignment: MainAxisAlignment
                      .start, // Align content to the start of the row.
                  crossAxisAlignment: CrossAxisAlignment
                      .start, // Align content to the top of the row.
                  mainAxisSize:
                      MainAxisSize.min, // Minimize the size of the row.
                  children: [
                    Icon(
                      // Display a location off icon.
                      icon,
                      color: Colors.red, // Set the icon color to red.
                      size: size.height *
                          .04, // Set the icon size to 4% of the screen height.
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      // Use Expanded to allow the text to take up available space.
                      child: Column(
                        // Use a Column to arrange the text vertically.
                        mainAxisAlignment: MainAxisAlignment
                            .start, // Align text to the top of the column.
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align text to the start of the column.
                        children: [
                          Text(
                            // Display the status message.
                            title,
                            style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(
                              height: 2.0), // Add a small vertical space.
                          Text(
                            // Display the detailed message.
                            msg,
                            softWrap:
                                true, // Allow text to wrap to the next line.
                            textAlign:
                                TextAlign.start, // Align text to the start.
                            style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black45,
                                fontWeight: FontWeight.w300),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      // Display an "Enable" button.
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          minimumSize: Size(size.width * .25, 40),
                          alignment: Alignment.center,
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero),

                      onPressed: () {
                        // Handle the button press.
                        pressed().whenComplete(Navigator.of(context)
                                .pop // Close the alert after opening settings.
                            );
                      },
                      // Display an "Enable" button.
                      child: Text(
                        btnText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
    } else {
      // Use Fluttertoast instead of Snackbar for error cases
      showSnackbar("Error: Context is not initialized");
    }
  }

  /// No task Warning Dialog
  void deleteAlertMsg() {
    if (_context != null && _context!.mounted) {
      PanaraInfoDialog.showAnimatedGrow(
        _context!,
        title: "Oops!",
        message: "There is no Task For Delete!",
        buttonText: "Okay",
        onTapDismiss: () {
          Navigator.pop(_context!);
        },
        panaraDialogType: PanaraDialogType.error,
      );
    } else {
      showSnackbar("Error: Context is not initialized");
    }
  }

  /// Delete All Task Dialog
  void deleteAllTask(Function(bool delete) confirm) {
    if (_context != null && _context!.mounted) {
      PanaraConfirmDialog.show(
        _context!,
        title: "Are You Sure?",
        message:
            "Do You really want to delete all tasks? You will no be able to undo this action!",
        confirmButtonText: "Yes",
        cancelButtonText: "No",
        onTapCancel: () {
          confirm(false);
          Navigator.pop(_context!);
        },
        onTapConfirm: () {
          confirm(true);
          Navigator.pop(_context!);
        },
        panaraDialogType: PanaraDialogType.warning,
        barrierDismissible: false,
      );
    } else {
      showSnackbar("Error: Context is not initialized");
    }
  }

  void showSnackbar(String msg) {
    if (_context != null && _context!.mounted) {
      final scaffoldMessenger = ScaffoldMessenger.of(_context!);
      scaffoldMessenger.removeCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.fixed,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } else {
      // Fallback to Fluttertoast
      Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent.shade400,
        textColor: Colors.white,
      );
    }
  }

  void deleteAccount(Function(bool delete) confirm) {
    if (_context != null && _context!.mounted) {
      PanaraConfirmDialog.show(
        _context!,
        title: "Are You Sure?",
        message:
            "Do you really want to delete Your account?. You will not be able to undo this action.",
        confirmButtonText: "Confirm",
        cancelButtonText: "Cancel",
        onTapCancel: () {
          Navigator.pop(_context!);
          confirm(false);
        },
        onTapConfirm: () {
          Navigator.pop(_context!);
          confirm(true);
        },
        panaraDialogType: PanaraDialogType.warning,
        barrierDismissible: false, // optional parameter (default is true)
      );
    } else {
      showSnackbar("Error: Context is not initialized");
    }
  }
}
