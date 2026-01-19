class ApiServices {
  static const int isPaymentLive = 0;
  static const String googleMapApiKey = 'AIzaSyBqG8oCDY59Pwe68Y0AUiUeis-jWlsmtN8';
  static const String googleMapApiKey2 = 'AIzaSyCILYd8F2M7g95NQErBTZsXLmTD7baDBIw';
  static const String appStoreUrl = '';//'https://apps.apple.com/in/app/mediq-healthcare/id6738270406';
  static const double imageLimitInMB = 5;


  ///Live
  static const String baseURL = 'https://app.bhadetaxi.com/rent_taxi/api/';
  static const String imageURL = 'http://cateyeom.com/studiobook/public/images/';


  ///staging url
//   static const String baseURL = "http://192.168.1.7/Prognostich/BhadaTaxi/api";
//   static const String imageURL = 'http://192.168.1.7/Prognostich/BhadaTaxi/images/';



  // Auth
  static const String login = "${baseURL}send_otp.php";
  static const String logout = "${baseURL}logout-user";

  //User
  static const String addSubAdmin = "${baseURL}add_subadmin.php";
  static const String getSubAdmin = "${baseURL}get_subadmin.php";
  static const String deleteSubAdmin = "${baseURL}delete_subadmin.php";
  static const String updateUserStatus = "${baseURL}update_user_status.php";

  // Booking
  static const String booking = "${baseURL}booking.php";
  static const String bookingDetail = "${baseURL}filter_vendor.php";
  static const String home = "${baseURL}view_booking.php";
  static const String bookingCheck = "${baseURL}check_booking.php";
  static const String completeBooking = "${baseURL}complete_booking_v2.php"; // remaining
  static const String typeWiseBooking = "${baseURL}get_typewise_booking.php";
  static const String dateWiseBooking = "${baseURL}date_wise_booking.php";
  static const String deleteBooking = "${baseURL}delete_booking.php";
  static const String allCustomerAndVendorList = "${baseURL}search_customer_vendor.php";
  static const String deleteRecords = "${baseURL}deleted_records.php";
  static const String specificBookingDetail = "${baseURL}booking_detail.php";

  // Customer / Vendor / Driver
  static const String getCustomer = "${baseURL}view_customer.php";
  static const String getVendor = "${baseURL}view_vendor_v2.php";
  static const String getDriver = "${baseURL}view_driver.php"; // remaining

  // Settlement
  static const String addSettlement = "${baseURL}add_sattlement.php";
  static const String getSettlement = "${baseURL}view_sattlement.php";
  static const String deleteSettlement = "${baseURL}delete_sattlement.php";

  // Vehicle
  static const String getVehicle = "${baseURL}get_vehicle_list.php";
  static const String addVehicle = "${baseURL}add_vehicle.php";
  static const String deleteVehicle = "${baseURL}delete_vehicle.php";
  static const String getVehicleExpense = "${baseURL}get_vehicle_expense.php";
  static const String addVehicleExpense = "${baseURL}add_vehicle_expense.php";
  static const String deleteVehicleExpense = "${baseURL}delete_vehicle_expense.php";
  static const String addVehicleTrip = "${baseURL}add_trip.php";
  static const String getVehicleTripReport = "${baseURL}vehicle_report.php";
  static const String deleteVehicleTrip = "${baseURL}delete_trip.php";

  // Payout
  static const String payout = "${baseURL}payout.php"; // remaining

  // CMS
  static const String cms = "${baseURL}cms.php";

  // Generate Excel
  static const String generateExcel = "${baseURL}excel.php";

  // Profile
  static const String getProfile = "${baseURL}get-profile";
  static const String setupProfile = "${baseURL}update-profile"; // remaining

  // Notification
  static const String notification = "${baseURL}get-notifications"; // remaining

  // Referral
  static const String getMyReferral = "${baseURL}get-referral-user"; // remaining
  static const String notifyMyReferral = "${baseURL}notify-my-referral"; // remaining

  // FAQ
  static const String faq = "${baseURL}get-faq";



}
