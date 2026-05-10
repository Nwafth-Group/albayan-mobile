import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// API Constants
class ApiConstants {
  static String get baseUrl =>'http://3.68.184.228/api/v1';
      // dotenv.env['BASE_URL'] ?? 'https://';
  static final navigatorKey = GlobalKey<NavigatorState>();

  // Auth Endpoints
  static const String login = '/owner/auth/login';
  static const String register = '/owner/auth/register';
  static const String verifyEmail = '/owner/auth/verify-email';
  static const String resendOtp = '/owner/auth/resend-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String getProfile = '/owner/profile';
  static const String getTenants = '/common/tenants';
  static const String completeOwnerProfile = '/owner/profile';
  static const String profileStatus = '/owner/profile/status';
  static const String getUnits = '/common/units';
  static const String getEstates = '/common/real-estates';
  static String getEstate(String id) => '/common/real-estates/$id';
  static const String notifications = '/common/notifications';
  static const String unreadNotifications = '/common/notifications/unread-count';
  static const String realEstates = '/common/real-estates';
  static const String units = '/common/units';
  static const String managementContractRequests = '/common/management-contract-requests';
  static const String initContractRequests = '/common/management-contract-requests/v2/initialize';

}

// App Colors
class AppColors {
  static const Color primary = Color(0xFF006D77);
  static const Color secondary = Color(0xFFFF4043);
  static const Color accent = Color(0xFF83C5BE);
  static const Color bgAccent = Color(0xFFE0F2F1);
  static const Color textDark = Color(0xFF313330);
  static const Color textLight = Color(0xFF0C0C0C);
  static const Color background = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFDC3545);
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppImages {
  static String homeIcon = 'assets/icons/home.svg';
  static String maintenanceIcon = 'assets/icons/Widget.svg';
  static String tenantsIcon = 'assets/icons/tenants.svg';
  static String leaseIcon = 'assets/icons/lease.svg';
  static String propertiesIcon = 'assets/icons/properties.svg';
  static String legalIcon = 'assets/icons/legal.svg';
  static String editIcon = 'assets/icons/edit.svg';
  static String reportsIcon = 'assets/icons/reports.svg';
  static String notification = 'assets/images/notification.png';
  static String tower = 'assets/images/tower.png';
  static String units = 'assets/images/units.png';
  static String warning = 'assets/images/warning.png';
  static String noProperty = 'assets/images/no-property.png';
  static String noLeases = 'assets/images/no-leases.png';
  static String noTenants = 'assets/images/not-tenant.png';
  static String income = 'assets/images/income.png';
  static String propertyIcon = 'assets/images/building.png';
  static String contracts = 'assets/images/contracts.png';
  static String overdue = 'assets/images/overdue.png';
  static String personal = 'assets/images/personal.png';
  static String legal = 'assets/images/legal.png';
  static String doc = 'assets/images/doc.png';
  static String bank = 'assets/images/bank.png';
  static String logoSplash = 'assets/images/logo-splash.png';
  static String success = 'assets/images/success_password.png';
  static String deleteImage = 'assets/images/delete-image.png';
  static String successImage = 'assets/images/success-image.png';
  static String file = 'assets/images/file.png';
  static String editIc = 'assets/images/edit_ic.png';
  static String deleteIcon = 'assets/images/delete_ic.png';
}

// App Dimensions
class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingxSmall = 3.0;

  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;
}

// Storage Keys
class StorageKeys {
  static const String token = 'token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String isLoggedIn = 'is_logged_in';
  static const String fcmToken = 'fcm_token';
  static const String isAdmin = 'is_admin';
}

String lng = 'en';

int ownerId = 0;
int? leaseId;
int? contractId;
String leaseType = "residential";
String? contractStartDate;
String? contractEndDate;

class AppStrings {
  // Signup Screen
  static const String appName = 'app_name';
  static const String createNewAccount = 'Create New Account';
  static const String createNow = 'create_now';
  static const String name = 'Name';
  static const String email = 'email';
  static const String phoneNumber = 'phone';
  static const String password = 'password';
  static const String confirmPassword = 'Confirm Password';
  static const String agreeToTerms = 'I agree to the terms and conditions';
  static const String termsAndConditions = 'Terms & Conditions';
  static const String legalAgencyNumber = 'legal_agency_number';
  static const String legalAgencyDate = 'legal_agency_date';
  static const String legalAgencySource = 'legal_agency_source';
  static const String authorizationType = 'authorization_type';
  static const String authorizationTypeRequired = 'authorization_type_required';
  static const String generalPowerOfAttorney = 'general_power_of_attorney';
  static const String specialPowerOfAttorney = 'special_power_of_attorney';
  static const String authorizedSignatory = 'authorized_signatory';
  static const String register = 'Register';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String login = 'login';
  static const String rememberMe = 'remember_me';
  static const String orContinue = 'or_continue';
  static const String dont_have_account = "dont_have_account";
  static const String forgetPass = "forget_password";
  static const String textEmail = "text_email";
  static const String textPassword = "text_password";

  // Placeholders
  static const String enterYourName = 'Enter your name';
  static const String enterYourEmail = 'Enter your email';
  static const String enterYourPhone = 'Enter your phone number';
  static const String enterYourPassword = 'Enter your password';
  static const String confirmYourPassword = 'Confirm your password';

  // Validation Messages
  static const String pleaseEnterName = 'Please enter your name';
  static const String pleaseEnterEmail = 'Please enter your email';
  static const String pleaseEnterValidEmail = 'Please enter a valid email address';
  static const String pleaseEnterPhone = 'Please enter your phone number';
  static const String pleaseEnterPassword = 'Please enter your password';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String pleaseConfirmPassword = 'Please confirm your password';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String pleaseAgreeToTerms = 'Please agree to the terms and conditions';

  // General
  static const String success = 'Success';
  static const String error = 'Error';
  static const String loading = 'Loading...';

  // Owner Services
  static const String ownerSelectsServices = 'Owner Selects Services';
  static const String propertyManagementRequest = 'Property Management Request';
  static const String manageCreateLeaseContracts = 'Manage or Create Lease Contracts';

  // Lease Type
  static const String pleaseSelectLeaseType = 'Please select a lease type';
  static const String residentialLease = 'Residential Lease';
  static const String commercialLease = 'Commercial Lease';

  // Contract Info Screen
  static const String contractInfo = 'Contract Information';
  static const String date = 'Date';
  static const String to = 'To';
  static const String startDate = 'Start Date';
  static const String endDate = 'End Date';
  static const String leaseDuration = 'Lease Duration';
  static const String months12 = '12 Months';
  static const String noUnitsYet = 'No Units Yet';
  static const String contractExecutionPlace = 'Contract Execution Place';
  static const String riyadhSaudiArabia = 'Riyadh, Saudi Arabia';
  static const String contractExecutionDate = 'Contract Execution Date';
  static const String status = 'Status';
  static const String draft = 'Draft';
  static const String next = 'Next';

// Lessor Info Screen
  static const String previousBusinessLicense = 'Previous Business License?';
  static const String commercialOccupancyPermit = 'Commercial Occupancy Permit?';
  static const String lessorOwnerInformation = 'Lessor / Owner Information';
  static const String nationality = 'Nationality';
  static const String jordanian = 'Jordanian';
  static const String nationalPersonalNo = 'National / Personal Number';
  static const String idNo = 'ID Number';
  static const String address = 'Address';
  static const String bankAccountNumber = 'Bank Account Number';
  static const String lessorRepresentative = 'Lessor Representative';
  static const String isLessorSelfRepresented = 'Is the lessor self-represented?';
  static const String lessorDelegationName = 'Representative Name';
  static const String lessorDelegationType = 'Representation Type';
  static const String lessorDelegationNationality = 'Representative Nationality';
  static const String ownerLessorPhoneNumber = 'Lessor Phone Number';
  static const String ownerLessorEmail = 'Lessor Email';
  static const String lessorDelegationAddress = 'Representative Address';
  static const String tenantIdNo = 'Tenant ID Number';
  static const String isLesseeSelfRepresented = 'Is the lessee self-represented?';
  static const String type = 'Type';
  static const String addedByBroker = 'Added by Broker';
  static const String brokerName = 'Broker Name';
  static const String establishmentName = 'Establishment Name';
  static const String establishmentNationalNo = 'Establishment National Number';
  static const String establishmentCommissionPercent = 'Establishment Commission (%)';
  static const String propertyDetails = 'Property Details';
  static const String propertyName = 'Property Name';
  static const String propertyNumber = 'Property Number';
  static const String propertyType = 'Property Type';
  static const String city = 'City';
  static const String villageNo = 'Village Number';
  static const String basinNameNo = 'Basin Name / Number';
  static const String propertyStreetAdress = 'Street Address';
  static const String plotNo = 'Plot Number';
  static const String buildingNo = 'Building Number';
  static const String buildingType = 'Building Type';
  static const String propertyUsage = 'Property Usage';
  static const String floorsCount = 'Number of Floors';
  static const String unitsCount = 'Number of Units';
  static const String basicUnitInformation = 'Basic Unit Information';
  static const String unitNumberCode = 'Unit Number / Code';
  static const String unitType = 'Unit Type';
  static const String floorNumber = 'Floor Number';
  static const String unitAddress = 'Unit Address';
  static const String furnished = 'Furnished';
  static const String furnishingCondition = 'Furnishing Condition';
  static const String kitchenInstalled = 'Kitchen Installed';
  static const String airConditioning = 'Air Conditioning';
  static const String isThereAC = 'Is there air conditioning?';
  static const String acType = 'Air Conditioner Type';
  static const String acCount = 'Number of Air Conditioners';
  static const String electricityDetails = 'Electricity Details';
  static const String electricityMeterOwnership = 'Electricity Meter Ownership';
  static const String payingForElectricityServices = 'Who pays for electricity services?';
  static const String electricityBillAmount = 'Electricity Bill Amount';
  static const String electricityMeterNo = 'Electricity Meter Number';
  static const String electricityCurrentReading = 'Current Electricity Meter Reading';
  static const String waterDetails = 'Water Details';
  static const String waterMeterOwnership = 'Water Meter Ownership';
  static const String payingForWaterServices = 'Who pays for water services?';
  static const String waterBillAmount = 'Water Bill Amount';
  static const String waterMeterNo = 'Water Meter Number';
  static const String waterCurrentReading = 'Current Water Meter Reading';
  static const String subtenancySubletting = 'Subtenancy / Subletting';
  static const String subtenancyAllowed = 'Is subletting allowed?';
  static const String roomsCount = 'Rooms Count';
  static const String rentalInformation = 'Rental Information';
  static const String rentPaymentAmount = 'Rent Payment Amount';
  static const String paymentPeriodicity = 'Payment Frequency';
  static const String numberOfRentPayments = 'Number of Rent Payments';
  static const String rentValue = 'Rent Value';
  static const String depositAmount = 'Security Deposit Amount';
  static const String downpaymentAmount = 'Down Payment Amount';
  static const String maintenanceFeeAmount = 'Maintenance Fee Amount';
  static const String serviceChargesAmount = 'Service Charges Amount';
  static const String maarofTax = 'Maarof Tax';
  static const String maarofTaxAmount = 'Maarof Tax Amount';
  static const String penaltyClauseAmount = 'Penalty Clause Amount';
  static const String totalContractValue = 'Total Contract Value';
  static const String delayType = 'Delay Type';
  static const String lateFeeAmount = 'Late Fee Amount';
  static const String brokerCommissionAmount = 'Broker Commission Amount';
  static const String paymentMethod = 'Payment Method';
  static const String renewalMode = 'Renewal Mode';
  static const String noticePeriodDays = 'Notice Period (Days)';
  static const String renewalTermValue = 'Renewal Term Value';
  static const String requireMutualConfirmation = 'Requires mutual confirmation';
  static const String pleaseSelectStartDateFirst = 'Please select the start date first';
  static const String endDateMustBeAfterStartDate = 'End date must be after the start date';
  static const String pleaseFillAllFields = 'Please fill in all required fields';
  static const String thisFieldIsRequired = 'This field is required';
  static const String selectNationality = 'Select Nationality';
  static const String pleaseSelectNationality = 'Please select a nationality';
  static const String loadingCountries = 'Loading countries...';
  static const String nationalIdMustBe10Digits = 'National ID must be exactly 10 digits';
  static const String invalidPhoneNumber = 'Invalid phone number';
  static const String invalidEmailFormat = 'Invalid email format';
  static const String optional = 'Optional';
  static const String selectType = 'Select Type';
  static const String identificationNumber = 'Identification Number';
  static const String nationalId = 'National ID';
  static const String nationalIdNum = 'national_id';
  static const String individual = 'Individual';
  static const String company = 'Company';
  static const String selectAuthorizationType = 'Select Authorization Type';
  static const String self = 'Self';
  static const String legalAgent = 'Legal Agent';
  static const String guardian = 'Guardian';
  static const String trustee = 'Trustee';
  static const String curator = 'Curator';
  static const String heirRepresentative = 'Heir Representative';
  static const String judicialCustodian = 'Judicial Custodian';
  static const String invalidNumber = 'Invalid number';
  static const String percentMustBe0To100 = 'Percentage must be between 0 and 100';
  static const String realEstateRecordNumber = 'Real Estate Record Number';
  static const String selectPropertyType = 'Select Property Type';
  static const String street = 'Street';
  static const String villageNumber = 'Village Number';
  static const String basinIdentifier = 'Basin Identifier';
  static const String plotNumber = 'Plot Number';
  static const String buildingNumber = 'Building Number';
  static const String selectBuildingType = 'Select Building Type';
  static const String usagePurpose = 'Usage Purpose';
  static const String selectUsagePurpose = 'Select Usage Purpose';
  static const String floorCount = 'Number of Floors';
  static const String unitCount = 'Number of Units';
  static const String description = 'Description';
  static const String residential = 'Residential';
  static const String commercial = 'Commercial';
  static const String villa = 'Villa';
  static const String chalet = 'Chalet';
  static const String building = 'Building';
  static const String mall = 'Mall';
  static const String apartment = 'Apartment';
  static const String floor = 'Floor';
  static const String shop = 'Shop';
  static const String room = 'Room';
  static const String land = 'Land';
  static const String buildingOption = 'Building';
  static const String villaOption = 'Villa';
  static const String tower = 'Tower';
  static const String commercialComplex = 'Commercial Complex';
  static const String villaBuildingWithShops = 'Villa Building with Shops';
  static const String basement = 'Basement';
  static const String warehouses = 'Warehouses';
  static const String residentialFamily = 'Residential (Family)';
  static const String residentialIndividuals = 'Residential (Individuals)';
  static const String industrial = 'Industrial';
  static const String commercialUsage = 'Commercial';
  static const String commercialResidential = 'Commercial / Residential';
  static const String unitNumber = 'Unit Number';
  static const String selectUnitType = 'Select Unit Type';
  static const String furnishedStatus = 'Furnished Status';
  static const String selectFurnishedStatus = 'Select Furnished Status';
  static const String bedrooms = 'Number of Bedrooms';
  static const String hasAC = 'Has Air Conditioning?';
  static const String selectAcType = 'Select Air Conditioning Type';
  static const String selectOwnershipType = "Select Ownership Type";
  static const String properties = 'Properties';
  static const String units = 'Units';
  static const String tenants = 'Tenants';
  static const String search = 'Search';
  static const String leased = 'Leased';
  static const String vacant = 'Vacant';
  static const String viewUnits = 'View units';
  static const String failedToLoadProperty = 'Failed to load property details';
  static const String retry = 'Retry';
  static const String information = 'Information';
  static const String propertyContent = 'Property Content';
  static const String documents = 'Documents';
  static const String basicInformation = 'Basic Information';
  static const String realEstateName = 'Real Estate Name';
  static const String realEstateNameAr = 'Real Estate Name (AR)';
  static const String realEstateNumber = 'Real Estate Number';
  static const String propertyCharacteristic = 'Property Characteristic';
  static const String registrationDate = 'Registration Date';
  static const String inspected = 'Inspected';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String buildingInformation = 'Building Information';
  static const String buildingStatus = 'Building Status';
  static const String yearBuilt = 'Year Built';
  static const String leasedUnits = 'Leased Units';
  static const String vacantUnits = 'Vacant Units';
  static const String country = 'Country';
  static const String neighborhood = 'Neighborhood';
  static const String ownerInformation = 'Owner Information';
  static const String ownerNameEn = 'Owner Name (EN)';
  static const String ownerNameAr = 'Owner Name (AR)';
  static const String mobile = 'Mobile';
  static const String ownerType = 'Owner Type';
  static const String propertiesCount = 'Properties Count';
  static const String managementInformation = 'Management Information';
  static const String noBuildingInformationAvailable = 'No building information available';
  static const String elevators = 'Elevators';
  static const String parking = 'Parking';
  static const String floors = 'Floors';
  static const String fitness = 'Fitness';
  static const String security = 'Security';
  static const String ownershipProof = 'Ownership Proof';
  static const String sitePlan = 'Site Plan';
  static const String propertyPlan = 'Property Plan';
  static const String unit = 'Unit';
  static const String unitDetails = 'Unit Details';
  static const String meterType = 'Meter Type';
  static const String leases = 'Leases';
  static const String noMeterInformationAvailable = 'No meter information available';
  static const String meter = 'Meter';
  static const String meterNumber = 'Meter Number';
  static const String currentReading = 'Current Reading';
  static const String ownershipType = 'Ownership Type';
  static const String feeType = 'Fee Type';
  static const String feeValue = 'Fee Value';
  static const String notes = 'Notes';
  static const String noLeaseInformationAvailable = 'No lease information available';
  static const String leaseNumber = 'Lease Number';
  static const String rentalStatus = 'Rental Status';
  static const String rentalMethod = 'Rental Method';
  static const String baselineRent = 'Baseline Rent';
  static const String addNewUnit = 'Add a new unit';
  static const String lease = 'Lease';
  static const String rent = 'Rent';
  static const String method = 'Method';
  static const String securityDeposit = 'Security Deposit';
  static const String income = 'Income';
  static const String overdue = 'Overdue';
  static const String contracts = 'Contracts';
  static const String reports = 'reports';
  static const String contractSummary = 'Contract Summary';
  static const String seeAll = 'See All';
  static const String recentRentals = 'Recent Rentals';
  static const String paid = 'Paid';
  static const String unpaid = 'Unpaid';
  static const String duration = 'Duration';
  static const String home = 'Home';
  static const String portfolio = 'Portfolio';
  static const String maintenance = 'Maintenance';
  static const String legalCases = 'Legal Cases';
  static const String personalInfo = "Personal Info";
  static const String bankInformation = "Bank Information";
  static const String legalRepresentative = "Legal Representative";
  //=========
  static const String save = "save";
  static const String profile = "Profile";
  static const String document = "document";
  static const String tenant = "tenant";
  static const String owner = "owner";

  static const String tenantIdentityProof = "tenant_identity_proof";
  static const String tenantLegalRepresentative = "tenant_legal_representative";
  static const String powerOfAttorney = "power_of_attorney";
  static const String legalRepresentativeIdentity = "legal_representative_identity";

  static const String propertyOwnershipProof = "property_ownership_proof";
  static const String ownerIdentityProof = "owner_identity_proof";
  static const String ownerLegalRepresentative = "owner_legal_representative";

  static const String depositInvoice = "deposit_invoice";

  static const String uploadAtLeastOneDocument = "upload_at_least_one_document";
  static const String errorPickingFile = "error_picking_file";


  static const String paymentInformation = 'Payment Information';
  static const String rentPaymentValue = 'Rent Payment Value';
  static const String selectPaymentPeriodicity = 'Select Payment Frequency';
  static const String downPayment = 'Down Payment';
  static const String downPaymentMustBeLessThanRent = 'Down payment must be less than the rent amount';
  static const String maintenanceFee = 'Maintenance Fee';
  static const String serviceCharges = 'Service Charges';
  static const String lateFeeValue = 'Late Fee Amount';
  static const String selectDelayType = 'Select Delay Type';
  static const String maxLength50 = 'Maximum length is 50 characters';
  static const String hasMaarefTax = 'Includes Maaref Tax';
  static const String allowPaymentScheduleUpdate = 'Allow payment schedule updates';
  static const String annualRentIncreases = 'Annual Rent Increases';
  static const String hasAnnualIncrease = 'Has annual increase?';
  static const String yearIncreaseAmount = 'Annual Increase Amount';
  static const String renewalSettings = 'Renewal Settings';
  static const String selectRenewalMode = 'Select Renewal Mode';
  static const String viewPaymentSchedule = 'View Payment Schedule';
  static const String paymentDate = 'Payment Date';
  static const String amount = 'Amount';
  static const String morePayments = 'More Payments';
  static const String financialSummary = 'Financial Summary';
  static const String rentBreakdown = 'Rent Breakdown';
  static const String numberOfPayments = 'Number of Payments';
  static const String totalRent = 'Total Rent';
  static const String oneTimeFees = 'One-Time Fees';
  static const String totalOneTimeFees = 'Total One-Time Fees';
  static const String recurringFeesPerPayment = 'Recurring Fees per Payment';
  static const String totalRecurringFees = 'Total Recurring Fees';
  static const String penaltiesAndFees = 'Penalties and Fees';
  static const String grandTotal = 'Grand Total';
  static const String selectLeaseDuration = 'Select Lease Duration';
  static const String month = 'Month';
  static const String months = 'Months';
  static const String years = 'Years';
  static const String customDuration = 'Custom Duration';
  static const String enterCustomDuration = 'Enter custom duration';
  static const String enterMonths = 'Enter number of months';
  static const String invalidDuration = 'Invalid duration';
  static const String autoCalculated = 'Auto-calculated';
  static const String confirm = 'Confirm';
  static const String cancel = 'Cancel';
  static const String isConditional = 'Is this conditional?';
  static const String conditionType = 'Condition Type';
  static const String selectConditionType = 'Select Condition Type';
  static const String conditionNote = 'Condition Note';
  static const String selectPaymentMethod = "Select Payment Method";
  static const String delete = 'delete';
  static const String confirmDelete = 'confirm_delete';
  static const String confirmDeleteDocument = 'confirm_delete_document';
  static const String documentsSavedSuccessfully = 'documents_saved_successfully';
  static const String leasesList = 'leases_list';
  static const String searchLeases = 'search_leases';
  static const String filter = 'filter';
  static const String leaseType = 'lease_type';
  static const String all = 'all';
  static const String download = 'download';
  static const String pendingReview = 'pending_review';
  static const String active = 'active';
  static const String apply = 'apply';
  static const String noLeasesFound = 'no_leases_found';
  static const String clickBelowToGenerate = 'Click below to generate your first lease';
  static const String generateLease = 'generate_lease';
  static const String noData = 'no_data';
  static const String addLease = 'add_lease';
  static const String confirmDeleteLease = 'confirm_delete_lease';
  static const String edit = 'edit';
  static const String sendToReview = 'send_to_review';

  // Lease Detail Screen
  static const String leaseDetails = 'lease_details';
  static const String leaseRegisterNo = 'lease_register_no';
  static const String leaseStartDate = 'lease_start_date';
  static const String leaseEndDate = 'lease_end_date';
  static const String createdOn = 'created_on';
  static const String changePassword = 'change_password';
  static const String changeLanguage = 'change_language';
  static const String privacyPolicy = 'privacy_policy';
  static const String aboutAlaqedAlamin = 'about_alaqed_alamin';
  static const String terms_and_conditions = 'terms_&_conditions';
  static const String faq = 'faq';
  static const String financials = 'financials';
  static const String contactUs = 'contact_us';
  static const String logout = 'logout';

  static const String leaseInformation = 'Lease Information';
  static const String tenantLesseeInformation = 'Tenant / Lessee Information';
  static const String tenantLesseeRepresentative = 'Tenant / Lessee Representative';
  static const String brokerOfficeData = 'Broker Office Information';
  static const String unitLeasedUnitDetails = 'Leased Unit Details';
  static const String financialInformation = 'Financial Information';
  static const String contractPreview = 'Contract Details';
  static const String descriptionBoarding = 'description_boarding';
  static const String discoverDream = 'discover_dream';

  static const String verificationCode = 'Verification Code';
  static const String weHaveSent = 'We have sent a verification code to your email';
  static const String codeHas = 'A code has been sent to your email';
  static const String resendOTP = 'Resend OTP';
  static const String resendOTPIn = 'Resend In';
  static const String submit = 'Submit';
  static const String iban = 'IBAN';
  static const String bank = 'Bank';
  static const String selectBank = 'Select Bank';
  static const String loadingBanks = 'Loading banks...';
  static const String pleaseSelectBank = 'Please select a bank';
  static const String invalidIbanFormat = 'Invalid IBAN format';
  static const String accountHolderName = 'Account Holder Name';
  static const String commercialInformation = 'Commercial Information';
  static const String tenantType = 'Tenant Type';
  static const String selectTenantType = 'Select Tenant Type';
  static const String businessTradeName = 'Business Trade Name';
  static const String businessLicenseNumber = 'Business License Number';
  static const String businessLicenseIssuedPlace = 'Business License Issued At';
  static const String businessActivity = 'Business Activity';
  static const String commercialRegisterNumber = 'Commercial Register Number';
  static const String commercialRegisterIssuedPlace = 'Commercial Register Issued At';
  static const String commercialRegisterDate = 'Commercial Register Date';
  static const String allowActivityChange = 'Allow Activity Change';
  static const String activityChangeNote = 'Activity Change Note';
  static const String businessTradeNameRequired = 'Business trade name is required';
  static const String businessLicenseNumberRequired = 'Business license number is required';
  static const String businessLicenseIssuedPlaceRequired =
      'Business license issued place is required';
  static const String businessActivityRequired =
      'Business activity is required';
  static const String commercialRegisterNumberRequired =
      'Commercial register number is required';
  static const String commercialRegisterIssuedPlaceRequired =
      'Commercial register issued place is required';
  static const String commercialRegisterDateRequired =
      'Commercial register date is required';
  static const String activityChangeNoteRequired =
      'Activity change note is required';
  static const String selectOwnerType = 'Select Owner Type';
  static const String isJordanian = 'Is the owner Jordanian?';
  static const String companyName = 'Company Name';
  static const String crn = 'Commercial Registration Number';
  static const String isSelfRepresented = 'Is the owner self-represented?';
  static const String pleaseSelectOwnerType = 'Please select an owner type';
  static const String removeAuthorizedPerson = 'Remove Authorized Person';
  static const String propertyArea = 'Property Area';
  static const String selectPropertyCharacteristic = 'Select Property Characteristic';
  static const String pleaseSelectPropertyTypeFirst =
      'Please select the property type first';
  static const String residentialCommercial = 'Residential / Commercial';
  static const String vacantLand = 'Vacant Land';
  static const String floorsAndApartments = 'Floors and Apartments';
  static const String settlement = 'Settlement';
  static const String undividedProperty = 'Undivided Property';
  static const String pleaseSelectPropertyType =
      'Please select a property type';
  static const String pleaseSelectPropertyCharacteristic =
      'Please select a property characteristic';
  static const String pleaseSelectBuildingType =
      'Please select a building type';
  static const String pleaseSelectUsagePurpose =
      'Please select a usage purpose';
  static const String loadingPropertyType = 'Loading property type...';

  static const String requiredField = 'This field is required';
  static const String yyyyMmDd = 'YYYY-MM-DD';

  // AppBar
  static const String createRealEstate = 'Create Real Estate';
  static const String updateRealEstate = 'Update Real Estate';

  // Sections
  static const String location = 'Location';
  static const String facilities = 'Facilities';
  static const String management = 'Management';
  static const String managementRequest = 'Management Request';
  static const String managementContract = 'Management Contract';
  static const String commissionRate = 'Commission Rate';

  // Basic info fields
  static const String nameArabic = 'Name (Arabic)';
  static const String nameEnglish = 'Name (English)';
  static const String propertyRegistrationDate = 'Property Registration Date';
  static const String isInspected = 'Is Inspected';

  // Basic info hints
  static const String nameArabicHint = 'برج الياسمين';
  static const String nameEnglishHint = 'Al-Yasmeen Tower';
  static const String propertyAreaHint = '1500.75';
  static const String selectCharacteristic = 'Select characteristic';
  static const String recordNumberHint = 'REC-99887766';
  static const String descriptionHint = 'A luxury tower with retail shops...';

  // Location hints
  static const String countryHint = 'Jordan';
  static const String cityHint = 'Amman';
  static const String neighborhoodHint = 'Al-Abdali';
  static const String streetHint = 'Boulevard Street';
  static const String villageNumberHint = 'V-12';
  static const String basinIdentifierHint = 'Basin 4';
  static const String plotNumberHint = 'P-404';

  static const String leaseUnitCount = 'Lease Unit Count';

  // Building info hints
  static const String buildingNumberHint = 'Tower A';
  static const String buildingStatusHint = 'New';
  static const String yearBuiltHint = '2024';
  static const String floorCountHint = '12';
  static const String unitCountHint = '48';
  static const String leaseUnitCountHint = '45';

  // Facilities fields
  static const String elevatorsCount = 'Elevators Count';
  static const String parkingSpacesCount = 'Parking Spaces Count';
  static const String fitnessCentersCount = 'Fitness Centers Count';
  static const String securityEntrancesCount = 'Security Entrances Count';

  // Facilities hints
  static const String elevatorsCountHint = '3';
  static const String parkingSpacesCountHint = '60';
  static const String fitnessCentersCountHint = '1';
  static const String securityEntrancesCountHint = '2';

  // Management
  static const String managementStartDate = 'Management Start Date';
  static const String managementEndDate = 'Management End Date';

  // Pickers titles
  static const String selectTypeTitle = 'Select Type';
  static const String selectPropertyCharacteristicTitle =
      'Select Property Characteristic';
  static const String selectUsagePurposeTitle = 'Select Usage Purpose';
  static const String selectBuildingTypeTitle = 'Select Building Type';

  // Dialog
  static const String realEstateCreatedSuccessfully =
      'Real estate created successfully!\n\nWould you like to add units to this property now?';
  static const String later = 'Later';
  static const String addUnits = 'Add Units';
  static const String allRequest = 'allRequest';
  static const String pending = 'pending';
  static const String cancelled = 'cancelled';
  static const String contractSent = 'contractSent';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  static const String deleted = 'deleted';
  static const String expired = 'Expired';
  static const String chooseTheDate = 'chooseTheDate';
  static const String noContractsFound = 'noContractsFound';
  static const String portfolioSize = 'portfolioSize';
  static const String propertiesTypes = 'propertiesTypes';
  static const String paymentMode = 'paymentMode';
  static const String managementType = 'managementType';
  static const String requestDate = 'requestDate';
  static const String view = 'view';
  static const String display = 'display';
  static const String resubmit = 'resubmit';
  static const String managementPlanSelection = 'managementPlanSelection';
  static const String selectManagementType = 'selectManagementType';
  static const String monthlyManagement = 'monthlyManagement';
  static const String quarterlyManagement = 'quarterlyManagement';
  static const String annualManagement = 'annualManagement';
  static const String durationUnit = 'durationUnit';
  static const String selectDurationUnit = 'selectDurationUnit';
  static const String day = 'day';
  static const String year = 'year';
  static const String residentialBuildingCloseToServices = 'residentialBuildingCloseToServices';
  static const String durationMustBeGreaterThanZero = 'durationMustBeGreaterThanZero';
  static const String pleaseSelectManagementType = 'pleaseSelectManagementType';
  static const String pleaseSelectDurationUnit = 'pleaseSelectDurationUnit';
  static const String propertiesList = 'propertiesList';
  static const String selectProperty = 'selectProperty';
  static const String addProperty = 'addProperty';
  static const String thereAreNoPropertiesYet = 'thereAreNoPropertiesYet';
  static const String pleaseSelectOrAddProperty = 'pleaseSelectOrAddProperty';
  static const String propertyInformation = 'propertyInformation';
  static const String registrationDeedNumber = 'registrationDeedNumber';
  static const String areaNeighborhood = 'areaNeighborhood';
  static const String addressStreet = 'addressStreet';
  static const String leasedUnitCount = 'leasedUnitCount';
  static const String propertyStatus = 'propertyStatus';
  static const String selectPropertyUsage = 'selectPropertyUsage';
  static const String selectCity = 'selectCity';
  static const String selectBuildingStatus = 'selectBuildingStatus';
  static const String selectPropertyStatus = 'selectPropertyStatus';
  static const String propertySavedSuccessfully = 'propertySavedSuccessfully';
  static const String propertyTypes = 'propertyTypes';

  static const String ownerProfile = 'owner_profile';
  static const String realEstateOffice = 'real_estate_office';
  static const String personIqamaNumber = 'person_iqama_number';
  static const String loadingNationalities = 'loading_nationalities';
  static const String nationalityRequired = 'nationality_required';
  static const String identificationNumberRequired = 'identification_number_required';
  static const String companyLegalName = 'company_legal_name';
  static const String companyNameRequired = 'company_name_required';
  static const String companyRegistrationNumber = 'company_registration_number';
  static const String crnRequired = 'crn_required';
  static const String bankName = 'bank_name';
  static const String ibanNumber = 'iban_number';
  static const String accountNumber = 'account_number';
  static const String swiftCode = 'swift_code';
  static const String clear = 'clear';
  static const String monthly = 'monthly';
  static const String annual = 'annual';
  static const String comprehensive = 'comprehensive';
  static const String sharedFacilities = 'shared_facilities';
  static const String durationType = 'duration_type';
  static const String selectDurationType = 'select_duration_type';
  static const String pleaseSelectDurationType = 'please_select_duration_type';
  static const String durationValue = 'duration_value';
  static const String managementRequestDetails = 'management_request_details';
  static const String requestInformation = 'request_information';
  static const String requestNumber = 'request_number';
  static const String ownerName = 'owner_name';
  static const String property = 'property';

  static const String searchTenants = 'searchTenants';
  static const String noTenantsFound = 'noTenantsFound';
  static const String noTenantsFoundDesc = 'noTenantsFoundDesc';
  static const String inactive = 'inactive';
  static const String addTenant = 'addTenant';
  static const String firstNameAr = 'firstNameAr';
  static const String secondNameAr = 'secondNameAr';
  static const String thirdNameAr = 'thirdNameAr';
  static const String lastNameAr = 'lastNameAr';
  static const String firstNameEn = 'firstNameEn';
  static const String secondNameEn = 'secondNameEn';
  static const String thirdNameEn = 'thirdNameEn';
  static const String lastNameEn = 'lastNameEn';
  static const String companyNameAr = 'companyNameAr';
  static const String companyNameEn = 'companyNameEn';
  static const String companyMobile = 'companyMobile';
  static const String companyEmail = 'companyEmail';
  static const String companyNationalNumber = 'companyNationalNumber';
  static const String isThereALegalRepresentative = 'isThereALegalRepresentative';
  static const String tenantAddedSuccess = 'tenantAddedSuccess';
  static const String days = 'Days';
  static const String activityChangeApprovalRequired = 'Activity Change Approval Required';
  static const String newContractRequiredOnActivityChange = 'New Contract Required On Activity Change';
  static const String businessLicenseIssuedDate = 'Business License Issued Date';
  static const String leaseTerm = 'leaseTerm';
  static const String downPaymentAmount = 'downPaymentAmount';
  static const String downPaymentNote = 'downPaymentNote';
  static const String amountOfEachMonth = 'amountOfEachMonth';
  static const String serviceChargesAddedToTotal = 'serviceChargesAddedToTotal';
  static const String theElectricityBillAddedToTotalRentAmount = 'theElectricityBillAddedToTotalRentAmount';
  static const String theWaterBillAddedToTotalRentAmount = 'theWaterBillAddedToTotalRentAmount';
  static const String static = 'Static';
  static const String meterReading = 'Meter reading';
  static const String electricity = 'electricity';
  static const String water = 'water';
  static const String configure = 'configure';
  static const String delayFeeAmount = 'delayFeeAmount';
  static const String changeableRentValueYearly = 'changeableRentValueYearly';
  static const String yearlyIncrease = 'yearlyIncrease';
  static const String generatePaymentSchedule = 'generatePaymentSchedule';
  static const String renewal = 'renewal';
  static const String yearly = 'yearly';
  static const String value = 'value';
  static const String done = 'done';
  static const String ibanTooLong = 'ibanTooLong';
  static const String completeProfile = 'completeProfile';
  static const String completeYourProfileToUnlockAllFeatures = 'completeYourProfileToUnlockAllFeatures';
  static const String paymentSchedule = 'paymentSchedule';
  static const String leaseSummary = 'leaseSummary';
  static const String periodicity = 'periodicity';
  static const String totalValue = 'totalValue';
  static const String installment = 'installment';
  static const String dueDate = 'dueDate';
  static const String totalDue = 'totalDue';
  static const String editingAllowedInDraftOnly = 'editingAllowedInDraftOnly';
  static const String thereAreNoData = 'thereAreNoData';
  static const String termsOfUse = 'termsOfUse';
  static const String privacyPolicyy = 'privacyPolicy';
  static const String aboutUs = 'aboutUs';
  static const String maintenanceRequests = 'maintenanceRequests';
  static const String legalCasess = 'legalCases';
  static const String cashFlow = 'cashFlow';

  static String getStringByKey(String key) {
    switch (key) {
      case 'allRequest':
        return allRequest;
      case 'draft':
        return draft;
      case 'pending':
      case 'pending_owner_signature':
        return pending;
      case 'cancelled':
        return cancelled;
      case 'contractSent':
      case 'contract_sent':
        return contractSent;
      case 'approved':
        return approved;
      case 'rejected':
        return rejected;
      case 'deleted':
        return deleted;
      case 'expired':
        return expired;
      default:
        return key;
    }
  }

}
