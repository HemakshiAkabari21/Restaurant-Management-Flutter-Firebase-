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

/// contact picker
class ContactPickerExample extends StatefulWidget {
  @override
  _ContactPickerExampleState createState() => _ContactPickerExampleState();
}

class _ContactPickerExampleState extends State<ContactPickerExample> {
  final FlutterContactPickerPlus _contactPicker = FlutterContactPickerPlus();
  List<Contact>? _contacts;
  bool _permissionGranted = false;

  Future<bool> checkPermission(Permission permission) async {
    PermissionStatus status = await permission.status;
    print(status);
    switch (status) {
      case PermissionStatus.denied:
        var result = await permission.request();
        if (result == PermissionStatus.granted || result == PermissionStatus.limited) {
          return true;
        } else {
          _showDeniedDialog();
          return false;
        }

      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return true;

      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        _showDeniedDialog();
        return false;

      default:
        _showDeniedDialog();
        return false;
    }
  }

  void _showDeniedDialog() {
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
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  Future<void> _selectSingleContactWithPermission() async {
    final hasPermission = await checkPermission(Permission.contacts);
    setState(() {
      _permissionGranted = hasPermission;
    });
    if (!hasPermission) return;
    await _selectSingleContact();
  }

  Future<void> _selectMultipleContactsWithPermission() async {
    final hasPermission = await checkPermission(Permission.contacts);
    setState(() {
      _permissionGranted = hasPermission;
    });
    if (!hasPermission) return;
    await _selectMultipleContacts();
  }

  Future<void> _selectSingleContact() async {
    try {
      Contact? contact = await _contactPicker.selectContact();
      setState(() {
        _contacts = contact == null ? null : [contact];
      });
    } on PlatformException catch (e) {
      _handleContactError(e);
    }
  }

  Future<void> _selectMultipleContacts() async {
    try {
      if (Platform.isIOS) {
        List<Contact>? contacts = await _contactPicker.selectContacts();
        setState(() {
          _contacts = contacts;
        });
      } else {
        List<Contact> contacts = [];
        while (true) {
          Contact? contact = await _contactPicker.selectContact();
          if (contact == null) break;
          contacts.add(contact);

          final continueSelecting =
              await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(title: const Text('Add another contact?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes'))]),
              ) ??
              false;

          if (!continueSelecting) break;
        }

        setState(() {
          _contacts = contacts.isEmpty ? null : contacts;
        });
      }
    } on PlatformException catch (e) {
      _handleContactError(e);
    }
  }

  Future<void> _selectPhoneNumber() async {
    try {
      Contact? contact = await _contactPicker.selectPhoneNumber();
      setState(() {
        _contacts = contact == null ? null : [contact];
      });
    } on PlatformException catch (e) {
      _handleContactError(e);
    }
  }

  void _handleContactError(PlatformException e) {
    if (e.code == 'PERMISSION_DENIED') {
      _showDeniedDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.message}'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Picker with Permissions'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() => _contacts = null), tooltip: 'Clear Contacts')]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('Contact Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 12),
                Text(_permissionGranted ? 'Permission: Granted' : 'Permission: Denied', style: TextStyle(color: _permissionGranted ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildActionButton(icon: Icons.person_add, label: 'Single (with perm)', onPressed: _selectSingleContactWithPermission, color: Colors.green),
                    _buildActionButton(icon: Icons.group_add, label: 'Multi (with perm)', onPressed: _selectMultipleContactsWithPermission, color: Colors.green),
                    _buildActionButton(icon: Icons.person_outline, label: 'Single (no perm)', onPressed: _selectSingleContact, color: Colors.blue),
                    _buildActionButton(icon: Icons.group_outlined, label: 'Multi (no perm)', onPressed: _selectMultipleContacts, color: Colors.blue),
                    _buildActionButton(icon: Icons.phone, label: 'Phone Number', onPressed: _selectPhoneNumber, color: Colors.purple),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _contacts == null
                    ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.contacts, size: 80, color: Colors.grey), SizedBox(height: 16), Text('No contacts selected', style: TextStyle(fontSize: 18, color: Colors.grey))]))
                    : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _contacts!.length,
                      itemBuilder: (context, index) {
                        final contact = _contacts![index];
                        return _buildContactCard(contact);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback? onPressed, required Color color}) {
    return ElevatedButton.icon(icon: Icon(icon, size: 18), label: Text(label), onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white));
  }

  Widget _buildContactCard(Contact contact) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar and Name Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (contact.avatar != null) Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: MemoryImage(base64Decode(contact.avatar!)), fit: BoxFit.cover))),
                if (contact.avatar == null) Container(width: 80, height: 80, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.indigo), child: const Icon(Icons.person, size: 40, color: Colors.white)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contact.fullName ?? 'Unknown Name', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      if (contact.organizationInfo?.jobTitle != null || contact.organizationInfo?.company != null)
                        Padding(padding: const EdgeInsets.only(top: 4.0), child: Text([contact.organizationInfo?.jobTitle, contact.organizationInfo?.company].where((e) => e != null).join(' at '), style: TextStyle(fontSize: 16, color: Colors.grey[700]))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Contact Information Sections
            if (contact.phoneNumbers != null && contact.phoneNumbers!.isNotEmpty)
              _buildSection(Icons.phone, 'Phone Numbers', contact.phoneNumbers!.map((number) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.phone, size: 24), title: Text(number), onTap: () => _launchPhoneCall(number))).toList()),

            if (contact.selectedPhoneNumber != null)
              _buildSection(Icons.phone_android, 'Selected Phone', [ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.star, color: Colors.amber, size: 24), title: Text(contact.selectedPhoneNumber!), onTap: () => _launchPhoneCall(contact.selectedPhoneNumber!))]),

            if (contact.emailAddresses != null && contact.emailAddresses!.isNotEmpty)
              _buildSection(
                Icons.email,
                'Email Addresses',
                contact.emailAddresses!.map((email) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.email, size: 24), title: Text(email.email ?? ''), subtitle: email.label != null ? Text(email.label!) : null, onTap: () => _launchEmail(email.email))).toList(),
              ),

            if (contact.postalAddresses != null && contact.postalAddresses!.isNotEmpty)
              _buildSection(
                Icons.location_on,
                'Addresses',
                contact.postalAddresses!
                    .map(
                      (address) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.location_on, size: 24),
                        title: Text([address.street, address.city, address.state, address.postalCode, address.country].where((e) => e != null).join(', ')),
                        subtitle: address.label != null ? Text(address.label!) : null,
                        onTap: () => _launchMaps(address),
                      ),
                    )
                    .toList(),
              ),

            if (contact.organizationInfo != null && (contact.organizationInfo?.company != null || contact.organizationInfo?.jobTitle != null))
              _buildSection(Icons.business, 'Organization', [
                ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.business, size: 24), title: Text(contact.organizationInfo?.company ?? ''), subtitle: contact.organizationInfo?.jobTitle != null ? Text(contact.organizationInfo!.jobTitle!) : null),
              ]),

            if (contact.birthday != null) _buildSection(Icons.cake, 'Birthday', [ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.cake, size: 24), title: Text(contact.birthday!))]),

            if (contact.notes != null) _buildSection(Icons.notes, 'Notes', [ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.notes, size: 24), title: Text(contact.notes!))]),

            if (contact.websiteURLs != null && contact.websiteURLs!.isNotEmpty) _buildSection(Icons.link, 'Websites', contact.websiteURLs!.map((url) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.link, size: 24), title: Text(url), onTap: () => _launchUrl(url))).toList()),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPhoneCall(String? phoneNumber) async {
    if (phoneNumber == null) return;
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String? email) async {
    if (email == null) return;
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchMaps(PostalAddress address) async {
    final query = [address.street, address.city, address.state, address.postalCode, address.country].where((e) => e != null).join(', ');
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildSection(IconData icon, String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 24, color: Colors.indigo), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))]),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.only(left: 32.0), child: Column(children: children)),
          const Divider(height: 24),
        ],
      ),
    );
  }
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
                  Navigator.pop(context);
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

/// phone call
Future<void> makePhoneCall(String number) async {
  final Uri callUri = Uri.parse("tel:$number");
  if (await canLaunchUrl(callUri)) {
    await launchUrl(callUri);
  } else {
    print("Could not launch $callUri");
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

/// pickAndUpload image in Cloudinary global function
Future<String> pickAndUpload() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    File image = File(pickedFile.path);
    String? imageUrl = await CloudinaryService.uploadImage(image);

    if (imageUrl != null) {
      print("Uploaded Image URL: $imageUrl");
      return imageUrl;
      // Save this URL in Firebase Realtime Database
    }else{
      return "https://t4.ftcdn.net/jpg/06/57/37/01/360_F_657370150_pdNeG5pjI976ZasVbKN9VqH1rfoykdYU.jpg";
    }
  }else {
    // user cancelled picker
    return "https://t4.ftcdn.net/jpg/06/57/37/01/360_F_657370150_pdNeG5pjI976ZasVbKN9VqH1rfoykdYU.jpg";
  }
}

Widget imagePickerBox({required String imageUrl, required VoidCallback onPick,}) {
  return InkWell(
    onTap: onPick,
    child: Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.edit, color: Colors.white, size: 18),
        ),
      ),
    ),
  );
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

/*class InvoicePdf {
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
                    final amount =
                        item.productQty * (item.productPrice);
                    return pw.TableRow(
                      children: [
                        tableCell(item.productName, regularFont),
                        tableCell(item.productQty.toString(), regularFont),
                        tableCell(
                            formatCurrency((item.productPrice)), regularFont),
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
}*/

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

  Navigator.pop(context); // close loading dialog

  //  Ask Open or Share
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Invoice Ready'),
      content: const Text('What would you like to do?'),
      actions: [

        TextButton(
          onPressed: () {
            Navigator.pop(context);
            OpenFile.open(file.path);
          },
          child: const Text('OPEN'),
        ),

        TextButton(
          onPressed: () {
            Navigator.pop(context);
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