// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Burmese (`my`).
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy([String locale = 'my']) : super(locale);

  @override
  String get appTitle => 'Smart Budget';

  @override
  String get settings => 'ဆက်တင်များ';

  @override
  String get appearance => 'အသွင်အပြင်';

  @override
  String get themeMode => 'အလင်း/အမှောင် မုဒ်';

  @override
  String get systemDefault => 'စနစ်အတိုင်း';

  @override
  String get lightMode => 'အလင်း မုဒ်';

  @override
  String get darkMode => 'အမှောင် မုဒ်';

  @override
  String get language => 'ဘာသာစကား';

  @override
  String get english => 'English';

  @override
  String get myanmar => 'မြန်မာ';

  @override
  String get preferencesSaved => 'ဆက်တင်များ သိမ်းပြီးပါပြီ';

  @override
  String languageChanged(Object language) {
    return '$language ဘာသာစကား သို့ ပြောင်းပြီးပါပြီ။';
  }

  @override
  String get dashboard => 'ဒက်ရှ်ဘုတ်';

  @override
  String get totalBalance => 'စုစုပေါင်း လက်ကျန်ငွေ';

  @override
  String get income => 'ဝင်ငွေ';

  @override
  String get expense => 'အသုံးစရိတ်';

  @override
  String get quickActions => 'အမြန်လုပ်ဆောင်ချက်များ';

  @override
  String get add => 'ထည့်ရန်';

  @override
  String get history => 'မှတ်တမ်း';

  @override
  String get budgets => 'ဘတ်ဂျက်များ';

  @override
  String get categories => 'အမျိုးအစားများ';

  @override
  String get recentTransactions => 'နောက်ဆုံး ငွေလွှဲမှတ်တမ်းများ';

  @override
  String get viewAll => 'အားလုံးကြည့်ရန်';

  @override
  String get noTransactionsYet => 'ငွေလွှဲမှတ်တမ်း မရှိသေးပါ';

  @override
  String get topCategories => 'အသုံးများသော အမျိုးအစားများ';

  @override
  String get categoriesWillAppearHere => 'အမျိုးအစားများ ဒီနေရာတွင် ပြပါမည်';

  @override
  String get spendingInsight => 'အသုံးစရိတ် အကြံပြုချက်';

  @override
  String get spendingInsightMessage =>
      'နေ့စဉ် အသုံးစရိတ်ငယ်များကို မှတ်သားပါက ဘတ်ဂျက်ကို ပိုမိုလွယ်ကူစွာ ထိန်းနိုင်ပါသည်။';

  @override
  String get security => 'လုံခြုံရေး';

  @override
  String get fingerprintLogin => 'လက်ဗွေဖြင့် ဝင်ရောက်ခြင်း';

  @override
  String get fingerprintLoginDescription =>
      'အက်ပ်ဖွင့်ချိန်တွင် လက်ဗွေစစ်ဆေးမှု လိုအပ်စေပါ။';

  @override
  String get fingerprintAuthReason =>
      'သင်၏ ဘတ်ဂျက် ဒက်ရှ်ဘုတ်ကို ဖွင့်ရန် အတည်ပြုပါ';

  @override
  String get fingerprintFailed => 'လက်ဗွေ အတည်ပြုမှု မအောင်မြင်ပါ';

  @override
  String get fingerprintActivated => 'လက်ဗွေဝင်ရောက်မှု ဖွင့်ပြီးပါပြီ';

  @override
  String get fingerprintDeactivated => 'လက်ဗွေဝင်ရောက်မှု ပိတ်ပြီးပါပြီ';

  @override
  String get login => 'ဝင်ရောက်ရန်';

  @override
  String get unlockApp => 'အက်ပ်ဖွင့်ရန်';

  @override
  String get disableFingerprintLogin => 'လက်ဗွေဝင်ရောက်မှု ပိတ်ရန်';

  @override
  String get addCategory => 'အမျိုးအစား ထည့်ရန်';

  @override
  String get editCategory => 'အမျိုးအစား ပြင်ရန်';

  @override
  String get categoryDetails => 'အမျိုးအစား အသေးစိတ်';

  @override
  String get categoryName => 'အမျိုးအစား အမည်';

  @override
  String get type => 'ပုံစံ';

  @override
  String get saveCategory => 'အမျိုးအစား သိမ်းရန်';

  @override
  String get edit => 'ပြင်ရန်';

  @override
  String get delete => 'ဖျက်ရန်';

  @override
  String get cancel => 'မလုပ်တော့ပါ';

  @override
  String get deleteCategoryQuestion => 'အမျိုးအစား ဖျက်မလား?';

  @override
  String get deleteCategoryMessage => 'ဤအမျိုးအစားကို စာရင်းမှ ဖယ်ရှားပါမည်။';

  @override
  String get addTransaction => 'ငွေလွှဲမှတ်တမ်း ထည့်ရန်';

  @override
  String get editTransaction => 'ငွေလွှဲမှတ်တမ်း ပြင်ရန်';

  @override
  String get transactionDetails => 'ငွေလွှဲ အသေးစိတ်';

  @override
  String get updateDetails => 'အသေးစိတ် ပြင်ရန်';

  @override
  String get title => 'ခေါင်းစဉ်';

  @override
  String get amount => 'ပမာဏ';

  @override
  String get categoryOptional => 'အမျိုးအစား (ရွေးချယ်နိုင်သည်)';

  @override
  String get noCategory => 'အမျိုးအစား မရှိ';

  @override
  String get note => 'မှတ်ချက်';

  @override
  String get saveTransaction => 'ငွေလွှဲမှတ်တမ်း သိမ်းရန်';

  @override
  String get saveChanges => 'ပြင်ဆင်ချက် သိမ်းရန်';

  @override
  String get transactionDetail => 'ငွေလွှဲ အသေးစိတ်';

  @override
  String get date => 'ရက်စွဲ';

  @override
  String get transactionHistory => 'ငွေလွှဲမှတ်တမ်း';

  @override
  String get searchTransaction => 'ငွေလွှဲမှတ်တမ်း ရှာရန်';

  @override
  String get expenseOnly => 'အသုံးစရိတ်သာ';

  @override
  String get deleteTransactionQuestion => 'ငွေလွှဲမှတ်တမ်း ဖျက်မလား?';

  @override
  String get deleteTransactionMessage =>
      'ဤငွေလွှဲမှတ်တမ်းကို အပြီးတိုင် ဖျက်ပါမည်။';

  @override
  String get budgetSetup => 'ဘတ်ဂျက် သတ်မှတ်ရန်';

  @override
  String get budgetTitle => 'ဘတ်ဂျက် ခေါင်းစဉ်';

  @override
  String get limitAmount => 'ကန့်သတ် ပမာဏ';

  @override
  String get period => 'ကာလ';

  @override
  String get deleteBudgetQuestion => 'ဘတ်ဂျက် ဖျက်မလား?';

  @override
  String get deleteBudgetMessage => 'ဤဘတ်ဂျက်ကို ဘတ်ဂျက်စာရင်းမှ ဖယ်ရှားပါမည်။';

  @override
  String get setBudget => 'ဘတ်ဂျက် သတ်မှတ်ရန်';

  @override
  String get saveBudget => 'ဘတ်ဂျက် သိမ်းရန်';

  @override
  String get budgetDetail => 'ဘတ်ဂျက် အသေးစိတ်';

  @override
  String get spent => 'သုံးပြီး';

  @override
  String get limit => 'ကန့်သတ်';

  @override
  String get budgetAlert => 'ဘတ်ဂျက် သတိပေးချက်';

  @override
  String get budgetExceeded => 'ဘတ်ဂျက် ကျော်လွန်နေပါပြီ';

  @override
  String budgetAlertMessage(
    Object title,
    Object usagePercent,
    Object spentAmount,
    Object limitAmount,
  ) {
    return '$title သည် ဘတ်ဂျက်၏ $usagePercent% ထိ ရောက်နေပါပြီ။\n$limitAmount အနက် $spentAmount သုံးပြီးပါပြီ။';
  }

  @override
  String get ok => 'အိုကေ';

  @override
  String get reportsAnalytics => 'အစီရင်ခံစာ / သုံးသပ်ချက်';

  @override
  String get reports => 'အစီရင်ခံစာများ';

  @override
  String get expenseReport => 'အသုံးစရိတ် အစီရင်ခံစာ';

  @override
  String get totalSpent => 'စုစုပေါင်း သုံးငွေ';

  @override
  String selectedWeek(Object startDate, Object endDate) {
    return '$startDate - $endDate';
  }

  @override
  String selectedMonth(Object month) {
    return '$month';
  }

  @override
  String selectedYear(Object year) {
    return '$year';
  }

  @override
  String get chooseDate => 'ရက်စွဲ ရွေးရန်';

  @override
  String get expenseOnlyReport => 'အသုံးစရိတ် စုစုပေါင်းများသာ';

  @override
  String get noExpenseForPeriod => 'ဤကာလအတွက် အသုံးစရိတ် မရှိပါ';

  @override
  String get periodBreakdown => 'ကာလအလိုက် ခွဲခြမ်းစိတ်ဖြာချက်';

  @override
  String get selectedDateLabel => 'ရွေးထားသော ရက်စွဲ';

  @override
  String get exportExcel => 'Excel ထုတ်မည်';

  @override
  String get exportingExcel => 'Excel ထုတ်နေသည်...';

  @override
  String get excelExported => 'Excel ဖိုင်ကို မျှဝေရန် အဆင်သင့် ဖြစ်ပါသည်။';

  @override
  String get excelExportFailed => 'Excel ဖိုင် မထုတ်နိုင်ပါ။';

  @override
  String get reportSummary => 'အကျဉ်းချုပ်';

  @override
  String get reportTransactions => 'ငွေလွှဲများ';

  @override
  String get generatedAt => 'ထုတ်လုပ်သည့် အချိန်';

  @override
  String get transactionCount => 'ငွေလွှဲ အရေအတွက်';

  @override
  String get category => 'အမျိုးအစား';

  @override
  String get unknownCategory => 'အမျိုးအစား မသတ်မှတ်ရသေး';

  @override
  String get currency => 'ငွေကြေး';

  @override
  String get week => 'အပတ်';

  @override
  String get month => 'လ';

  @override
  String get year => 'နှစ်';
}
