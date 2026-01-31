import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/order_model.dart';
import 'package:restaurant_management_fierbase/utils/const_images_key.dart';
import 'package:restaurant_management_fierbase/utils/const_keys.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;



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

///Get Today's Key
String get todayKey {
  final now = DateTime.now();
  return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
}

/// Daily Reset
class DailyResetService {
  static Future<void> checkAndResetIfNeeded() async {
    final today = todayKey;
    final lastReset = getStorage.read(LAST_RESET_KEY);

    if (lastReset != today) {
      debugPrint('New day → resetting tables & carts');

      await RealtimeDbHelper.instance.resetAllTables();
      await RealtimeDbHelper.instance.clearAllCarts();

      await getStorage.write(LAST_RESET_KEY, today);
    } else {
      debugPrint('Same day → no reset needed');
    }
  }
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
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context)=> [
           pw.Column(
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
          )
        ],
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