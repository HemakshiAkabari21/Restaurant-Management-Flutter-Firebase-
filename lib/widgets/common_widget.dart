import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker_plus/flutter_native_contact_picker_plus.dart';
import 'package:flutter_native_contact_picker_plus/model/contact_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/model/order_model.dart';
import 'package:restaurant_management_fierbase/repository/cloudinary_service.dart';
import 'package:restaurant_management_fierbase/utils/const_images_key.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;


ColorFilter setSvgColor(Color color) {
  return ColorFilter.mode(color, BlendMode.srcIn);
}

showToast({required String message}) {
  Fluttertoast.showToast(
    msg: message.tr,
    backgroundColor: AppColors.black,
    textColor: AppColors.white,
    fontSize: 14.sp,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    // textColor: Colors.pink
  );
}

Future<bool> hasInternet() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
    return true;
  } else {
    return false;
  }
}

/*UserDetail getUserDetail() {
  UserDetail userDetail = UserDetail();
  if (getStorage.read(USER_DETAIL) != null) {
    userDetail = UserDetail.fromJson(jsonDecode(getStorage.read(USER_DETAIL).toString()));
  }
  return userDetail;
}*/

getAppVersion() async {
  final versionInfo = await PackageInfo.fromPlatform();
  return versionInfo.version;
}

/// formatDDMMMYYYY
String formatDDMMMYYYY(String date) {
  try {
    DateTime parsedDate = DateFormat("yyyy-MM-dd").parse(date);
    return DateFormat("dd-MM-yyyy").format(parsedDate);
  } catch (e) {
    return '';
  }
}

/// formatYYYYMMDD  yyyy-MM-dd
String formatYYYYMMDD(String date) {
  try {
    DateTime parsedDate = DateFormat("dd-MM-yyyy").parse(date);
    return DateFormat("yyyy-MM-dd").format(parsedDate);
  } catch (e) {
    return '';
  }
}

/// Convert "HH:mm:ss" (24h) to "hh:mm a" (12h with AM/PM)
String formatBookingTime(String time24h) {
  try {
    final inputFormat = DateFormat("HH:mm:ss");
    final dateTime = inputFormat.parse(time24h);
    final outputFormat = DateFormat("hh:mm a");
    return outputFormat.format(dateTime);
  } catch (e) {
    return time24h;
  }
}

TimeOfDay parseBookingTime(String time24h) {
  try {
    final inputFormat = DateFormat("HH:mm:ss");
    final dateTime = inputFormat.parse(time24h);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  } catch (e) {
    // fallback: return midnight if parsing fails
    return const TimeOfDay(hour: 0, minute: 0);
  }
}

/// 6:00 am format for TimeOfDay
String formatTimeOfDay(TimeOfDay tod) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
  final format = DateFormat.jm(); // gives h:mm a (e.g. 6:00 AM)
  return format.format(dt).toLowerCase(); // convert AM/PM to am/pm
}

/// HH:MM Time format
String convertToHHmm(String timeString) {
  try {
    DateTime dateTime = DateFormat("HH:mm:ss").parse(timeString);
    return DateFormat("HH:mm").format(dateTime);
  } catch (e) {
    return timeString;
  }
}

String convertTimeOfDayToString(TimeOfDay timeOfDay) {
  final now = DateTime.now();
  final dateTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  return DateFormat("HH:mm").format(dateTime);
}

String convertTo24Hour(String timeString) {
  var cleaned = timeString.replaceAll('\u202f', ' ').replaceAll('\u00a0', ' ').trim();

  cleaned = cleaned.replaceAllMapped(RegExp(r'\b(am|pm)\b', caseSensitive: false), (m) => m.group(0)!.toUpperCase());

  final parsed = DateFormat('h:mm a').parse(cleaned);
  debugPrint("Convert time is ::::: ${DateFormat('HH:mm').format(parsed)}");
  return DateFormat('HH:mm').format(parsed);
}

class ContactInfo {
  final String? name;
  final String? phoneNumber;

  ContactInfo({this.name, this.phoneNumber});

  @override
  String toString() => 'ContactInfo(name: $name, phone: $phoneNumber)';
}

class GlobalContactPicker {
  static final GlobalContactPicker _instance = GlobalContactPicker._internal();
  factory GlobalContactPicker() => _instance;
  GlobalContactPicker._internal();

  final FlutterContactPickerPlus _contactPicker = FlutterContactPickerPlus();

  /// Opens device contact book and returns selected contact info
  /// Returns ContactInfo with name and phone number, or null if cancelled
  static Future<ContactInfo?> pickContact(BuildContext context) async {
    return await _instance._pickContactInternal(context);
  }

  /// Picks contact with automatic permission handling
  Future<ContactInfo?> _pickContactInternal(BuildContext context) async {
    try {
      // Check and request permission
      final hasPermission = await checkContactPermission(context);
      if (!hasPermission) return null;

      // Pick contact
      Contact? contact = await _contactPicker.selectContact();
      if (contact == null) return null;

      // Extract name and phone number
      String? name = contact.fullName;
      String? phoneNumber;

      // Get first available phone number
      if (contact.phoneNumbers != null && contact.phoneNumbers!.isNotEmpty) {
        phoneNumber = contact.phoneNumbers!.first;
      }

      return ContactInfo(name: name, phoneNumber: phoneNumber);
    } on PlatformException catch (e) {
      handleContactError(context, e);
      return null;
    } catch (e) {
      showErrorDialog(context, 'Error picking contact: $e');
      return null;
    }
  }

  /// Picks only phone number (contact picker focused on phone)
  static Future<ContactInfo?> pickPhoneNumber(BuildContext context) async {
    return await _instance.pickPhoneNumberInternal(context);
  }

  Future<ContactInfo?> pickPhoneNumberInternal(BuildContext context) async {
    try {
      // Check and request permission
      final hasPermission = await checkContactPermission(context);
      if (!hasPermission) return null;

      // Pick phone number specifically
      Contact? contact = await _contactPicker.selectPhoneNumber();
      if (contact == null) return null;

      String? name = contact.fullName;
      String? phoneNumber = contact.selectedPhoneNumber;

      return ContactInfo(name: name, phoneNumber: phoneNumber);
    } on PlatformException catch (e) {
      handleContactError(context, e);
      return null;
    } catch (e) {
      showErrorDialog(context, 'Error picking phone number: $e');
      return null;
    }
  }

  /// Opens contact picker and automatically fills the provided controllers
  static Future<bool> pickContactAndFillControllers(BuildContext context, {TextEditingController? nameController, TextEditingController? phoneController}) async {
    ContactInfo? contact = await _instance._pickContactInternal(context);

    if (contact != null) {
      if (nameController != null && contact.name != null) {
        nameController.text = contact.name!;
      }
      if (phoneController != null && contact.phoneNumber != null) {
        phoneController.text = contact.phoneNumber!;
      }
      return true;
    }
    return false;
  }

  /// Check and request contact permission
  Future<bool> checkContactPermission(BuildContext context) async {
    PermissionStatus status = await Permission.contacts.status;

    switch (status) {
      case PermissionStatus.denied:
        var result = await Permission.contacts.request();
        if (result == PermissionStatus.granted) {
          return true;
        } else {
          showPermissionDialog(context);
          return false;
        }

      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return true;

      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        showPermissionDialog(context);
        return false;

      default:
        showPermissionDialog(context);
        return false;
    }
  }

  void showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text('Contacts permission is needed to access your contacts. Please enable it in app settings.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  Get.back();
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  void handleContactError(BuildContext context, PlatformException e) {
    if (e.code == 'PERMISSION_DENIED') {
      showPermissionDialog(context);
    } else {
      showErrorDialog(context, 'Error: ${e.message}');
    }
  }

  void showErrorDialog(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 3)));
  }
}

extension ContactPickerExtension on BuildContext {
  /// Quick access to pick contact from any BuildContext
  Future<ContactInfo?> pickContact() => GlobalContactPicker.pickContact(this);

  /// Quick access to pick phone number from any BuildContext
  Future<ContactInfo?> pickPhoneNumber() => GlobalContactPicker.pickPhoneNumber(this);
}

class AnimatedRadioButton extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String tag;

  const AnimatedRadioButton({super.key, required this.isSelected, required this.onTap, required this.tag});

  @override
  State<AnimatedRadioButton> createState() => _AnimatedRadioButtonState();
}

class _AnimatedRadioButtonState extends State<AnimatedRadioButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Row(
          children: [
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: widget.isSelected ? Icon(Icons.radio_button_checked, color: AppColors.black, size: 24.sp, key: ValueKey("check")) : Icon(Icons.radio_button_off, color: AppColors.black, size: 24.sp, key: ValueKey("empty")),
              ),
            ).paddingOnly(right: 5.w),
            Text(widget.tag, style: StyleHelper.customStyle(color: AppColors.white, size: 16.sp, family: semiBold)),
          ],
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 9, dashSpace = 5, startX = 0;
    final paint =
        Paint()
          ..color = AppColors.white
          ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}



class PaddingHorizontal15 extends StatelessWidget {
  const PaddingHorizontal15({super.key, required this.child, this.top, this.bottom, this.horizontal});

  final Widget child;
  final double? top;
  final double? bottom;
  final double? horizontal;
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(left: horizontal ?? 15.w, right: horizontal ?? 15.w, top: top ?? 0, bottom: bottom ?? 0), child: child);
  }
}

void showErrorSnackBar({required String title,required String message,Color? color}) {
  Get.rawSnackbar(
    backgroundColor: Colors.transparent,
    snackPosition: SnackPosition.TOP,
    margin: EdgeInsets.all(20.sp),
    padding: EdgeInsets.zero,
    duration: Duration(seconds: 3),
    messageText: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset:  Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Left red stripe
          Container(
            width: 6.w,
            height: 160.h,
            decoration: BoxDecoration(
              color: color ?? Colors.red,
              borderRadius:  BorderRadius.only(
                topLeft: Radius.circular(12.r),
                bottomLeft: Radius.circular(12.r),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          /// Red cross circle icon
          if(color != null)...[
            color == AppColors.green
                ? Icon(Icons.check_circle_outline,size: 24.sp,color: AppColors.green)
                : SvgPicture.asset(AppImages.closeCircleIcon,height: 24.h,width: 24.w,color: AppColors.errorColor
            ),
            SizedBox(width: 12.w),
          ],
          /// Title + message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children:  [
                Text(
                  title,
                  style: StyleHelper.customStyle(
                    size: 8.sp,
                    family: bold,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  message,
                  style: StyleHelper.customStyle(
                    size: 6.sp,
                    family: medium,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),

          /// Right side close button
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.darkGray),
            onPressed: () {
              if (Get.isSnackbarOpen) {
                Get.back();
              }
            },
          ),
        ],
      ),
    ),
  );
}

/// valid e-mail
bool isEmailValid(String email) {
  final RegExp emailRegex = RegExp(
    r'(^.*[a-zA-Z]+[\.\-]?[a-zA-Z0-9]+@\w+([\.-]?\w+)*(\.\w{2,3})+$)',
    caseSensitive: false,
    multiLine: false,
  );
  return emailRegex.hasMatch(email);
}

/// sendInvoiceE-mail
Future<void> sendInvoiceEmail({required String toEmail, required File pdfFile,}) async {
  debugPrint("E-mail:::$toEmail,File:::::::::${pdfFile.path}");
  //  Use app-specific password (NOT real password)
  final smtpServer = SmtpServer(
    'smtp.gmail.com',
    port: 587,
    ssl: false,
    allowInsecure: false,
    username: 'hemaxipatel768@gmail.com',
    password: 'absabuaonqrdrjxz',
  );


  final message = Message()
    ..from = Address('hemaxipatel768@gmail.com', 'Restaurant')
    ..recipients.add(toEmail)
    ..subject = 'Your Invoice'
    ..text = 'Please find your invoice attached.'
    ..attachments.add(FileAttachment(pdfFile));

  try {
    await send(message, smtpServer);
    print('Invoice email sent');
  } catch (e) {
    print('Email failed: $e');
  }
}

/// pdf genrate...
pw.Widget invoiceDivider({double thickness = 1}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 6),
    child: pw.Container(
      height: thickness,
      width: double.infinity,
      color: PdfColors.grey200,
    ),
  );
}

pw.Widget tableCell(String text, pw.Font? font) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(
      text,
      style: pw.TextStyle(font: font, fontSize: 10),
    ),
  );
}

pw.Widget totalRow(String label, String value, pw.Font? font, {bool isGrand = false,}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontSize: isGrand ? 12 : 10,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: font,
            fontSize: isGrand ? 12 : 10,
          ),
        ),
      ],
    ),
  );
}

String formatInvoiceDateTime(DateTime date) {
  return DateFormat('dd MMM yyyy, hh:mm a').format(date);
}

String formatCurrency(double value) {
  return '₹ ${value.toStringAsFixed(2)}';
}

class InvoicePdf {
  static Future<File> generate(OrderModel order) async {
    final pdf = pw.Document();
    pw.Font? regularFont;
    pw.Font? boldFont;
    late pw.MemoryImage logo;
    final emojiFont = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoEmoji-Regular.ttf'),);

    try {
      final logoBytes = (await rootBundle
          .load('assets/images/splash_image.png'))
          .buffer
          .asUint8List();
      logo = pw.MemoryImage(logoBytes);

      regularFont = await PdfGoogleFonts.robotoRegular();
      boldFont = await PdfGoogleFonts.robotoBold();
    } catch (_) {}

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      pw.Image(logo, height: 60),
                      pw.SizedBox(width: 12),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Prognostic', style: pw.TextStyle(font: boldFont, fontSize: 18,),),
                          pw.Text('INVOICE', style: pw.TextStyle(fontSize: 12,),),
                        ],
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice: # ${order.orderId}', style: pw.TextStyle(font: boldFont, fontSize: 11),),
                      pw.Text(formatInvoiceDateTime(order.orderDate), style: const pw.TextStyle(fontSize: 10),),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              invoiceDivider(thickness: 1),
              pw.SizedBox(height: 4),
              /// ================= CUSTOMER DETAILS =================
              pw.Text('Customer Details', style: pw.TextStyle(font: boldFont, fontSize: 14)),
              pw.SizedBox(height: 6),
              pw.Text('Name   : ${order.customerName}'),
              pw.SizedBox(height: 2),
              pw.Text('Mobile : ${order.customerMobile}'),
              pw.SizedBox(height: 2),
              pw.Text('Email  : ${order.customerEmail}'),
              pw.SizedBox(height: 4),
              invoiceDivider(),
              pw.SizedBox(height: 4),
              /// ================= ITEMS TABLE =================
              pw.Text('Order Items',
                  style: pw.TextStyle(font: boldFont, fontSize: 14)),
              pw.SizedBox(height: 8),

              pw.Table(
                border: pw.TableBorder.all(width: 0.6),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      tableCell('Item', boldFont),
                      tableCell('Qty', boldFont),
                      tableCell('Price', boldFont),
                      tableCell('Amount', boldFont),
                    ],
                  ),
                  ...order.orderJson.items.map((item) {
                    // Calculate effective quantity (reduce by 0.5 if half)
                    final effectiveQty = item.isHalf == 1
                        ? (item.productQty - 0.5)
                        : item.productQty.toDouble();

                    // Calculate amount with effective quantity
                    final amount = effectiveQty * item.productPrice;

                    // Display quantity with .5 if half
                    final displayQty = item.isHalf == 1
                        ? "${item.productQty - 0.5}"
                        : item.productQty.toString();

                    // Create item name with half indicator
                    final itemName = item.isHalf == 1
                        ? "${item.productName} (Half)"
                        : item.productName;

                    return pw.TableRow(
                      children: [
                        tableCell(itemName, regularFont),
                        tableCell(displayQty, regularFont),
                        tableCell(
                            formatCurrency(item.productPrice), regularFont),
                        tableCell(formatCurrency(amount), regularFont),
                      ],
                    );
                  }).toList(),
                ],
              ),

              //invoiceDivider(),
              pw.SizedBox(height: 8),
              /// ================= TOTALS =================
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 220,
                    child: pw.Column(
                      children: [
                        totalRow(
                            'Subtotal',
                            formatCurrency(order.orderJson.subTotal),
                            boldFont),
                        totalRow(
                            'GST (${order.orderJson.gstPercent}%)',
                            formatCurrency(order.orderJson.gstAmount),
                            boldFont),
                        totalRow(
                            'Service Charge',
                            formatCurrency(order.orderJson.serviceCharge),
                            boldFont),
                        totalRow(
                            'Discount',
                            '- ${formatCurrency(order.orderJson.discount)}',
                            boldFont),
                        invoiceDivider(thickness: 1.4),
                        totalRow(
                          'GRAND TOTAL',
                          formatCurrency(order.orderJson.grandTotal),
                          boldFont,
                          isGrand: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              invoiceDivider(thickness: 1.2),
              pw.SizedBox(height: 2),
              /// ================= FOOTER =================
              pw.Text(
                'Thank you for dining with us!',
                style: pw.TextStyle(font: boldFont, fontSize: 12),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                  children: [
                    pw.Text('Visit again ', textAlign: pw.TextAlign.center),
                    pw.Text('🙂', textAlign: pw.TextAlign.center,style: pw.TextStyle(font: emojiFont)),
                  ]
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file =
    File('${dir.path}/invoice_${order.orderId}.pdf');

    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
// Helper methods (copy from your BookingInformationPdf widget)
Future<void> openPdf(Uint8List bytes) async {
  if (kIsWeb) {
    await Printing.sharePdf(bytes: bytes, filename: 'restaurant_invoice.pdf');
    return;
  }

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/restaurant_invoice.pdf');
  await file.writeAsBytes(bytes);
  await OpenFile.open(file.path);
}

Future<void> sharePdf(Uint8List bytes) async {
  await Printing.sharePdf(bytes: bytes, filename: 'restaurant_invoice.pdf');
}

void onInvoiceClick(BuildContext context, OrderModel order) async {

  //  Loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 15),
          Text('Please wait...\nPDF generating'),
        ],
      ),
    ),
  );

  final file = await InvoicePdf.generate(order);

  Get.back(); // close loading dialog

  //  Ask Open or Share
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Invoice Ready'),
      content: const Text('What would you like to do?'),
      actions: [

        TextButton(
          onPressed: () {
            Get.back();
            OpenFile.open(file.path);
          },
          child: const Text('OPEN'),
        ),

        TextButton(
          onPressed: () {
            Get.back();
            Share.shareXFiles(
              [XFile(file.path)],
              subject: 'Invoice',
              text: 'Please find attached invoice PDF',
            );
          },
          child: const Text('SHARE'),
        ),
      ],
    ),
  );
}