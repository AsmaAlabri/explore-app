import '../app_settings.dart';

/// In-app translation table. No code generation, no .arb files —
/// just add a new key/entry here whenever a new page needs text,
/// then call tr('your_key') wherever that text is shown.
class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _values = {
    // Drawer / navigation
    'home': {'en': 'Home', 'ar': 'الرئيسية'},
    'about_oman': {'en': 'About Oman', 'ar': 'عن عُمان'},
    'explore': {'en': 'Explore', 'ar': 'استكشف'},
    'events': {'en': 'Events', 'ar': 'الفعاليات'},
    'notifications': {'en': 'Notifications', 'ar': 'الإشعارات'},
    'profile_settings': {
      'en': 'Profile & Settings',
      'ar': 'الملف الشخصي والإعدادات',
    },
    'help_support': {'en': 'Help & Support', 'ar': 'المساعدة والدعم'},
    'about_us': {'en': 'About us', 'ar': 'من نحن'},
    'logout': {'en': 'Logout', 'ar': 'تسجيل الخروج'},
    'need_help': {'en': 'Need help?', 'ar': 'تحتاج مساعدة؟'},

    // Home page
    'welcome_title': {
      'en': 'Welcome To Sultanate of Oman',
      'ar': 'مرحبًا بكم في سلطنة عُمان',
    },
    'home_intro': {
      'en':
          'The Sultanate of Oman features a vibrant and varied natural '
          'environment, combining plains, oceans, deserts, highlands, '
          'springs, valleys, and fertile vegetation. Moreover, cities '
          'today, modern infrastructure, heritage markets, ancient '
          'forts, and evenly allocated services and amenities enhance '
          'this scenery nationwide.\n\n'
          'Oman showcases a distinctive blend of historic cities, '
          'mountainous rural towns, contemporary lifestyle, and the '
          'enduring riches of genuine Arab culture. It is recognized '
          'for its hospitable and friendly residents, along with its '
          'top safety rankings globally. Omani hospitality is firmly '
          'based in tradition, where guests are greeted with authentic '
          'respect and kindness, fostering an atmosphere of genuine '
          'gratitude and concern. This nation offers thrilling choices '
          'for adventurers, including mountain climbing, hiking, '
          'diving, fishing, surfing, and exploring ancient caves like '
          'Al Hoota Cave and Majlis al Jinn Cave',
      'ar':
          'تتميز سلطنة عُمان ببيئة طبيعية نابضة بالحياة ومتنوعة، تجمع '
          'بين السهول والمحيطات والصحاري والمرتفعات والينابيع والوديان '
          'والنباتات الخصبة. علاوة على ذلك، تعزز المدن الحديثة، '
          'والبنية التحتية العصرية، والأسواق التراثية، والحصون '
          'القديمة، والخدمات والمرافق الموزعة بالتساوي هذا المشهد في '
          'جميع أنحاء البلاد.\n\n'
          'تُظهر عُمان مزيجًا مميزًا من المدن التاريخية، والبلدات '
          'الريفية الجبلية، ونمط الحياة المعاصر، والثراء الدائم '
          'للثقافة العربية الأصيلة. وهي معروفة بسكانها المضيافين '
          'والودودين، إلى جانب تصنيفاتها العالمية العالية في مجال '
          'السلامة. تتجذر الضيافة العُمانية بعمق في التقاليد، حيث '
          'يُستقبل الضيوف باحترام وحفاوة أصيلين مما يخلق أجواءً من '
          'الامتنان والاهتمام الصادقين. تقدم هذه الدولة خيارات مثيرة '
          'للمغامرين، بما في ذلك تسلق الجبال والمشي لمسافات طويلة '
          'والغوص وصيد الأسماك وركوب الأمواج واستكشاف الكهوف القديمة '
          'مثل كهف الهوتة وكهف مجلس الجن',
    },
    'coming_soon_suffix': {'en': 'page coming soon', 'ar': 'الصفحة قادمة قريبًا'},
    'help_support_coming_soon': {
      'en': 'Help & Support coming soon',
      'ar': 'المساعدة والدعم قريبًا',
    },

    // Profile & settings page
    'loading': {'en': 'Loading...', 'ar': 'جاري التحميل...'},
    'account': {'en': 'Account', 'ar': 'الحساب'},
    'change_password': {'en': 'Change Password', 'ar': 'تغيير كلمة المرور'},
    'edit_profile': {'en': 'Edit Profile', 'ar': 'تعديل الملف الشخصي'},
    'theme': {'en': 'Theme', 'ar': 'المظهر'},
    'language': {'en': 'Language', 'ar': 'اللغة'},

    // Welcome page
    'join_explore_oman': {
      'en': 'JOIN US AND\nEXPLORE OMAN',
      'ar': 'انضم إلينا و\nاستكشف عُمان',
    },
    'get_started': {'en': 'GET STARTED!', 'ar': 'ابدأ الآن!'},

    // Login page
    'welcome_back': {'en': 'Welcome Back', 'ar': 'مرحبًا بعودتك'},
    'email_hint': {'en': 'Email', 'ar': 'البريد الإلكتروني'},
    'password_hint': {'en': 'Password', 'ar': 'كلمة المرور'},
    'role_hint': {'en': 'Role', 'ar': 'الدور'},
    'role_selection_label': {'en': 'I am a', 'ar': 'أنا'},
    'login_button': {'en': 'Login', 'ar': 'تسجيل الدخول'},
    'register_link': {'en': 'Register', 'ar': 'إنشاء حساب'},
    'forgot_password_link': {
      'en': 'Forgot Password',
      'ar': 'نسيت كلمة المرور',
    },
    'err_enter_email': {
      'en': 'Please enter email',
      'ar': 'يرجى إدخال البريد الإلكتروني',
    },
    'err_invalid_email': {
      'en': 'Invalid email',
      'ar': 'بريد إلكتروني غير صالح',
    },
    'err_enter_password': {
      'en': 'Please enter password',
      'ar': 'يرجى إدخال كلمة المرور',
    },
    'err_min_8_chars': {
      'en': 'Minimum 8 characters',
      'ar': 'الحد الأدنى 8 أحرف',
    },

    // Register page
    'create_account': {'en': 'Create Account', 'ar': 'إنشاء حساب'},
    'full_name_hint': {'en': 'Full Name', 'ar': 'الاسم الكامل'},
    'confirm_password_hint': {
      'en': 'Confirm Password',
      'ar': 'تأكيد كلمة المرور',
    },
    'password_requirements_hint': {
      'en': 'Password must contain uppercase, lowercase,\n'
          'number and special character',
      'ar': 'يجب أن تحتوي كلمة المرور على حرف كبير وحرف صغير\n'
          'ورقم ورمز خاص',
    },
    'register_button': {'en': 'Register', 'ar': 'إنشاء حساب'},
    'already_have_account': {
      'en': 'Already have an account? ',
      'ar': 'لديك حساب بالفعل؟ ',
    },
    'err_enter_name': {
      'en': 'Please enter your name',
      'ar': 'يرجى إدخال اسمك',
    },
    'err_name_min_3': {
      'en': 'Name must be at least 3 characters',
      'ar': 'يجب أن يتكون الاسم من 3 أحرف على الأقل',
    },
    'err_enter_valid_email': {
      'en': 'Enter valid email',
      'ar': 'أدخل بريدًا إلكترونيًا صالحًا',
    },
    'err_password_strength': {
      'en': 'Password must contain:\n'
          '- 8 characters\n'
          '- Uppercase letter\n'
          '- Lowercase letter\n'
          '- Number\n'
          '- Special character',
      'ar': 'يجب أن تحتوي كلمة المرور على:\n'
          '- 8 أحرف\n'
          '- حرف كبير\n'
          '- حرف صغير\n'
          '- رقم\n'
          '- رمز خاص',
    },
    'err_confirm_password': {
      'en': 'Please confirm password',
      'ar': 'يرجى تأكيد كلمة المرور',
    },
    'err_passwords_mismatch': {
      'en': 'Passwords do not match',
      'ar': 'كلمتا المرور غير متطابقتين',
    },
    'register_success': {
      'en': 'Registration successful. Please log in.',
      'ar': 'تم التسجيل بنجاح. يرجى تسجيل الدخول.',
    },
    'register_success_profile_fail': {
      'en': 'Registration successful, but profile details were not saved.',
      'ar': 'تم التسجيل بنجاح، ولكن لم يتم حفظ تفاصيل الملف الشخصي.',
    },

    // Forgot / reset password
    'forgot_password_title': {
      'en': 'Forgot Password',
      'ar': 'نسيت كلمة المرور',
    },
    'send_reset_link': {
      'en': 'Send Reset Link',
      'ar': 'إرسال رابط إعادة التعيين',
    },
    'back_to_login': {'en': 'Back to Login', 'ar': 'العودة لتسجيل الدخول'},
    'reset_link_sent': {
      'en': 'Password reset link sent to your email',
      'ar': 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
    },
    'reset_password_title': {
      'en': 'Reset Password',
      'ar': 'إعادة تعيين كلمة المرور',
    },
    'reset_your_password_heading': {
      'en': 'Reset Your Password',
      'ar': 'أعد تعيين كلمة المرور',
    },
    'old_password_hint': {
      'en': 'Old Password',
      'ar': 'كلمة المرور القديمة',
    },
    'new_password_hint': {
      'en': 'New Password',
      'ar': 'كلمة المرور الجديدة',
    },
    'err_enter_old_password': {
      'en': 'Enter old password',
      'ar': 'أدخل كلمة المرور القديمة',
    },
    'err_enter_new_password': {
      'en': 'Enter new password',
      'ar': 'أدخل كلمة المرور الجديدة',
    },
    'err_new_password_same': {
      'en': 'New password must be different',
      'ar': 'يجب أن تكون كلمة المرور الجديدة مختلفة',
    },
    'err_weak_password': {'en': 'Weak password', 'ar': 'كلمة مرور ضعيفة'},
    'err_incorrect_old_password': {
      'en': 'The old password you entered is incorrect.',
      'ar': 'كلمة المرور القديمة التي أدخلتها غير صحيحة.',
    },
    'password_updated_success': {
      'en': 'Password Updated Successfully',
      'ar': 'تم تحديث كلمة المرور بنجاح',
    },
    'login_again_message': {
      'en': 'Please log in again to change your password',
      'ar': 'يرجى تسجيل الدخول مرة أخرى لتغيير كلمة المرور',
    },

    // About Oman page
    'about_oman_intro': {
      'en': 'The Sultanate of Oman features a vibrant and varied natural '
          'environment, combining plains, oceans, deserts, highlands, '
          'springs, valleys, and fertile vegetation. Moreover, cities '
          'today, modern infrastructure, heritage markets, ancient '
          'forts, and evenly allocated services and amenities enhance '
          'this scenery nationwide.\n\n'
          'Oman showcases a distinctive blend of historic cities, '
          'mountainous rural towns, contemporary lifestyle, and the '
          'enduring riches of Arab culture. It is recognized for its '
          'hospitable and friendly residents, along with its top '
          'safety rankings globally. Omani hospitality is firmly '
          'based in tradition, where guests are greeted with authentic '
          'respect and kindness, fostering an atmosphere of genuine '
          'gratitude and concern.\n\n'
          'This nation offers thrilling choices for adventurers, '
          'including mountain climbing, hiking, diving, fishing, '
          'surfing, and exploring ancient caves like Al Hoota Cave '
          'and Majlis al Jinn Cave.',
      'ar': 'تتميز سلطنة عُمان ببيئة طبيعية نابضة بالحياة ومتنوعة، تجمع '
          'بين السهول والمحيطات والصحاري والمرتفعات والينابيع والوديان '
          'والنباتات الخصبة. علاوة على ذلك، تعزز المدن الحديثة، '
          'والبنية التحتية العصرية، والأسواق التراثية، والحصون '
          'القديمة، والخدمات والمرافق الموزعة بالتساوي هذا المشهد في '
          'جميع أنحاء البلاد.\n\n'
          'تُظهر عُمان مزيجًا مميزًا من المدن التاريخية، والبلدات '
          'الريفية الجبلية، ونمط الحياة المعاصر، والثراء الدائم '
          'للثقافة العربية. وهي معروفة بسكانها المضيافين والودودين، '
          'إلى جانب تصنيفاتها العالمية العالية في مجال السلامة. '
          'تتجذر الضيافة العُمانية بعمق في التقاليد، حيث يُستقبل '
          'الضيوف باحترام وحفاوة أصيلين مما يخلق أجواءً من الامتنان '
          'والاهتمام الصادقين.\n\n'
          'تقدم هذه الدولة خيارات مثيرة للمغامرين، بما في ذلك تسلق '
          'الجبال والمشي لمسافات طويلة والغوص وصيد الأسماك وركوب '
          'الأمواج واستكشاف الكهوف القديمة مثل كهف الهوتة وكهف مجلس '
          'الجن.',
    },

    // Notifications page
    'no_notifications_yet': {
      'en': "You're all caught up. No notifications yet.",
      'ar': 'أنت على اطلاع بكل شيء. لا توجد إشعارات بعد.',
    },

    // Feedback page
    'feedback': {'en': 'Feedback', 'ar': 'التقييم'},
    'feedback_prompt': {
      'en': 'Tell us about your experience',
      'ar': 'أخبرنا عن تجربتك',
    },
    'feedback_hint': {
      'en': 'Write your feedback here ...',
      'ar': 'اكتب ملاحظاتك هنا ...',
    },
        'rating_value_label': {'en': '{n} out of 5', 'ar': '{n} من 5'},
    'tag_easy_to_use': {'en': 'Easy to use', 'ar': 'سهل الاستخدام'},
    'tag_helpful_info': {
      'en': 'Helpful information',
      'ar': 'معلومات مفيدة',
    },
    'tag_needs_improvement': {
      'en': 'Needs Improvement',
      'ar': 'يحتاج إلى تحسين',
    },
    'submit_feedback': {'en': 'Submit Feedback', 'ar': 'إرسال التقييم'},
    'select_rating_first': {
      'en': 'Please select a star rating first.',
      'ar': 'يرجى اختيار تقييم بالنجوم أولاً.',
    },
    'feedback_thanks': {
      'en': 'Thanks for your feedback!',
      'ar': 'شكرًا لملاحظاتك!',
    },
    'feedback_submit_error_prefix': {
      'en': 'Could not submit feedback: ',
      'ar': 'تعذر إرسال الملاحظات: ',
    },

    // Place details page
    'place_details_title': {
      'en': 'Place Details',
      'ar': 'تفاصيل المكان',
    },
    'view_on_map': {'en': 'View on Map', 'ar': 'عرض على الخريطة'},
    'give_feedback': {'en': 'Give Feedback', 'ar': 'إرسال ملاحظات'},
    'share': {'en': 'Share', 'ar': 'مشاركة'},
    'opening_map_prefix': {'en': 'Opening ', 'ar': 'جارٍ فتح '},
    'opening_map_suffix': {
      'en': ' on the map...',
      'ar': ' على الخريطة...',
    },
    'could_not_open_map': {
      'en': 'Could not open the map.',
      'ar': 'تعذر فتح الخريطة.',
    },

    // Explore / Events search pages
    'destinations_title': {'en': 'Destinations', 'ar': 'الوجهات'},
    'search_destination_hint': {
      'en': 'Search destination...',
      'ar': 'ابحث عن وجهة...',
    },
    'no_destinations_match': {
      'en': 'No destinations match your search.',
      'ar': 'لا توجد وجهات مطابقة لبحثك.',
    },
    'search_events_hint': {
      'en': 'Search events...',
      'ar': 'ابحث عن الفعاليات...',
    },
    'no_events_match': {
      'en': 'No events match your search.',
      'ar': 'لا توجد فعاليات مطابقة لبحثك.',
    },

    // About Us page
    'about_us_title': {
      'en': 'About Explore Oman',
      'ar': 'عن تطبيق استكشف عُمان',
    },
    'about_us_intro': {
      'en': 'Explore Oman is a mobile app built to help residents and '
          "visitors discover the Sultanate's culture, destinations, "
          'and events in one place. It was created as a graduation '
          "project, with the goal of making it easier to explore Oman's "
          'heritage sites, plan visits to festivals and attractions, '
          'and share feedback that helps other travelers.\n\n'
          'This app is actively being developed, and new features are '
          'added regularly.',
      'ar': 'استكشف عُمان تطبيق للهواتف المحمولة صُمم لمساعدة المقيمين '
          'والزوار على اكتشاف ثقافة السلطنة ووجهاتها وفعالياتها في '
          'مكان واحد. تم إنشاؤه كمشروع تخرج، بهدف تسهيل استكشاف مواقع '
          'التراث في عُمان، والتخطيط لزيارة المهرجانات والمعالم '
          'السياحية، ومشاركة الملاحظات التي تساعد المسافرين الآخرين.\n\n'
          'يخضع هذا التطبيق للتطوير المستمر، وتتم إضافة ميزات جديدة '
          'بانتظام.',
    },

    // Help & Support page
    'help_support_intro': {
      'en': 'Find quick answers below, or reach out to us directly if '
          'you need more help.',
      'ar': 'اعثر على إجابات سريعة أدناه، أو تواصل معنا مباشرة إذا كنت '
          'بحاجة إلى مزيد من المساعدة.',
    },
    'faq_q1': {
      'en': 'How do I create an account?',
      'ar': 'كيف يمكنني إنشاء حساب؟',
    },
    'faq_a1': {
      'en': 'On the Welcome screen, tap Get Started, then Register to '
          'create a new account with your name, email, and password.',
      'ar': 'في شاشة الترحيب، اضغط على ابدأ الآن، ثم إنشاء حساب لإنشاء '
          'حساب جديد باستخدام اسمك وبريدك الإلكتروني وكلمة المرور.',
    },
    'faq_q2': {
      'en': 'How do I switch the app language?',
      'ar': 'كيف يمكنني تغيير لغة التطبيق؟',
    },
    'faq_a2': {
      'en': 'Open the menu and go to Profile & Settings, then tap ENG '
          'or عربي under Language.',
      'ar': 'افتح القائمة وانتقل إلى الملف الشخصي والإعدادات، ثم اضغط '
          'على ENG أو عربي ضمن اللغة.',
    },
    'faq_q3': {
      'en': 'How do I turn on dark mode?',
      'ar': 'كيف يمكنني تفعيل الوضع الداكن؟',
    },
    'faq_a3': {
      'en': 'Open Profile & Settings and tap the moon icon under Theme.',
      'ar': 'افتح الملف الشخصي والإعدادات واضغط على أيقونة القمر ضمن '
          'المظهر.',
    },
    'faq_q4': {
      'en': 'I forgot my password. What should I do?',
      'ar': 'نسيت كلمة المرور، ماذا أفعل؟',
    },
    'faq_a4': {
      'en': 'On the Login screen, tap Forgot Password and enter your '
          'email to receive a reset link.',
      'ar': 'في شاشة تسجيل الدخول، اضغط على نسيت كلمة المرور وأدخل '
          'بريدك الإلكتروني لتلقي رابط إعادة التعيين.',
    },
    'faq_q5': {
      'en': 'How do I leave feedback about a place or event?',
      'ar': 'كيف يمكنني ترك ملاحظات حول مكان أو فعالية؟',
    },
    'faq_a5': {
      'en': 'Open a destination or event from Explore or Events, then '
          'tap Give Feedback to rate it and leave a comment.',
      'ar': 'افتح وجهة أو فعالية من استكشف أو الفعاليات، ثم اضغط على '
          'إرسال ملاحظات لتقييمها وترك تعليق.',
    },
    'contact_us': {'en': 'Contact Us', 'ar': 'تواصل معنا'},
    'contact_email_value': {
      'en': 'support@exploreoman.app',
      'ar': 'support@exploreoman.app',
    },
    'copied_to_clipboard': {
      'en': 'Email copied to clipboard',
      'ar': 'تم نسخ البريد الإلكتروني',
    },

    // User roles
    'role_admin': {'en': 'Admin', 'ar': 'مسؤول'},
    'role_business_owner': {
      'en': 'Local Business Owner',
      'ar': 'صاحب عمل محلي',
    },
    'role_tourist': {'en': 'Tourist', 'ar': 'سائح'},

    // Destination content (Explore page)
    'dest1_name': {
      'en': 'Oman Across Ages Museum',
      'ar': 'متحف عُمان عبر العصور',
    },
    'dest1_location': {'en': 'Manah', 'ar': 'منح'},
    'dest1_description': {
      'en': "Discover Oman's rich legacy through immersive exhibits "
          'and cultural artifacts dating back thousands of years.',
      'ar': 'اكتشف تراث عُمان الغني من خلال معارض تفاعلية وقطع أثرية '
          'ثقافية يعود تاريخها إلى آلاف السنين.',
    },
    'dest1_details': {
      'en': "Wilayat Manah's Oman Across Ages Museum provides guests "
          "with an enthralling voyage through the country's rich "
          "natural heritage, history, and culture. The museum's "
          'interactive displays and state-of-the-art technologies '
          "are intended to captivate visitors of all ages, bringing "
          "Oman's history to life in a distinctive and unforgettable "
          'way.',
      'ar': 'يقدم متحف عُمان عبر العصور في ولاية منح للزوار رحلة '
          'آسرة عبر تراث البلاد الطبيعي وتاريخها وثقافتها الغنية. '
          'صُممت العروض التفاعلية والتقنيات الحديثة في المتحف '
          'لجذب الزوار من جميع الأعمار، مما يعيد تاريخ عُمان إلى '
          'الحياة بطريقة مميزة لا تُنسى.',
    },
    'dest2_name': {'en': 'Bar Al Hikman', 'ar': 'بر الحكمان'},
    'dest2_location': {'en': 'Al Wusta', 'ar': 'الوسطى'},
    'dest2_description': {
      'en': 'Bar Al Hikman is an island located in the center of '
          "Oman's coast and is considered to be one of the most "
          'important bird migration...',
      'ar': 'بر الحكمان جزيرة تقع في وسط ساحل عُمان، وتُعد من أهم '
          'مواقع هجرة الطيور...',
    },
    'dest2_details': {
      'en': 'Bar Al Hikman is a vast coastal wetland and peninsula '
          'on the Arabian Sea, renowned as one of the most important '
          'migratory bird stopover sites in the Middle East, hosting '
          'hundreds of thousands of shorebirds each year.',
      'ar': 'بر الحكمان هو أرض رطبة ساحلية شاسعة وشبه جزيرة على بحر '
          'العرب، تشتهر بكونها واحدة من أهم محطات توقف الطيور '
          'المهاجرة في الشرق الأوسط، حيث تستقبل مئات الآلاف من '
          'طيور الشواطئ كل عام.',
    },
    'dest3_name': {'en': 'Nizwa Fort', 'ar': 'حصن نزوى'},
    'dest3_location': {'en': 'Ad Dakhiliyah', 'ar': 'الداخلية'},
    'dest3_description': {
      'en': 'Nizwa Fort, the largest of its kind in the Arabian '
          'Peninsula, is a massive circular stronghold built from '
          'mud by Imam Sultan bin Saif Al-...',
      'ar': 'حصن نزوى، أكبر حصن من نوعه في شبه الجزيرة العربية، هو '
          'معقل دائري ضخم بناه الإمام سلطان بن سيف...',
    },
    'dest3_details': {
      'en': "Nizwa Fort was built in the 17th century and is one of "
          "Oman's most visited national monuments, famous for its "
          'massive circular tower, defensive design, and sweeping '
          'views over Nizwa and the surrounding date palm oasis.',
      'ar': 'بُني حصن نزوى في القرن السابع عشر، وهو أحد أكثر '
          'المعالم الوطنية زيارةً في عُمان، ويشتهر ببرجه الدائري '
          'الضخم وتصميمه الدفاعي وإطلالاته الخلابة على نزوى وواحة '
          'النخيل المحيطة بها.',
    },
    'dest4_name': {
      'en': 'Sultan Qaboos Grand Mosque',
      'ar': 'جامع السلطان قابوس الأكبر',
    },
    'dest4_location': {'en': 'Muscat', 'ar': 'مسقط'},
    'dest4_description': {
      'en': 'Sultan Qaboos Grand Mosque is one of the most '
          'recognizable architectural and religious landmarks in '
          'Oman.',
      'ar': 'جامع السلطان قابوس الأكبر هو أحد أبرز المعالم '
          'المعمارية والدينية في عُمان.',
    },
    'dest4_details': {
      'en': 'Completed in 2001, the Grand Mosque can hold up to '
          '20,000 worshippers and is known for its enormous '
          'hand-woven Persian carpet and one of the largest '
          'single-piece chandeliers in the world.',
      'ar': 'اكتمل بناء الجامع الأكبر عام 2001، ويتسع لأكثر من '
          '20,000 مصلٍ، ويشتهر بسجادته الفارسية الضخمة المصنوعة '
          'يدويًا وواحدة من أكبر الثريات ذات القطعة الواحدة في '
          'العالم.',
    },

    // Event content (Events page)
    'event1_name': {'en': 'Muscat Festival', 'ar': 'مهرجان مسقط'},
    'event1_location': {'en': 'Muscat', 'ar': 'مسقط'},
    'event1_description': {
      'en': 'Oman welcomes you all to start the new year by '
          'exploring the Muscat night festivals.',
      'ar': 'ترحب عُمان بالجميع لبدء العام الجديد من خلال استكشاف '
          'مهرجانات مسقط الليلية.',
    },
    'event1_info1': {
      'en': 'Date: The Muscat festival 2026 dates are expected to '
          'run from January to February 2026.',
      'ar': 'التاريخ: من المتوقع أن يقام مهرجان مسقط 2026 من '
          'يناير إلى فبراير 2026.',
    },
    'event1_info2': {
      'en': 'Timing: 4:00 PM - 11:00 PM',
      'ar': 'التوقيت: 4:00 مساءً - 11:00 مساءً',
    },
    'event1_info3': {
      'en': 'Things To Do: Explore the open-air stage shows during '
          'the Muscat night festival, look at the local artefacts '
          'and taste the famous cuisine of Oman.',
      'ar': 'الأنشطة: استكشف العروض المسرحية في الهواء الطلق خلال '
          'مهرجان مسقط الليلي، وشاهد الحرف المحلية وتذوق المأكولات '
          'العُمانية الشهيرة.',
    },
    'event2_name': {
      'en': 'Salalah Tourism Festival',
      'ar': 'مهرجان صلالة السياحي',
    },
    'event2_location': {'en': 'Salalah', 'ar': 'صلالة'},
    'event2_description': {
      'en': 'The Festival is a famous attraction to tourists. This '
          'festival in Salalah has expanded to an international '
          'festival because of the high efforts.',
      'ar': 'يُعد المهرجان جذبًا مشهورًا للسياح، وقد توسع هذا '
          'المهرجان في صلالة ليصبح مهرجانًا عالميًا بفضل الجهود '
          'الكبيرة.',
    },
    'event2_info1': {
      'en': 'Date: Held annually during the Khareef (monsoon) '
          'season, typically July to September.',
      'ar': 'التاريخ: يُقام سنويًا خلال موسم الخريف، عادةً من '
          'يوليو إلى سبتمبر.',
    },
    'event2_info2': {
      'en': 'Timing: Evening hours, from around 4:00 PM until late.',
      'ar': 'التوقيت: ساعات المساء، من حوالي الرابعة عصرًا حتى '
          'وقت متأخر.',
    },
    'event2_info3': {
      'en': 'Things To Do: Enjoy cultural pavilions, live music, '
          'local produce markets, and the cool Salalah monsoon '
          'weather.',
      'ar': 'الأنشطة: استمتع بالأجنحة الثقافية والموسيقى الحية '
          'وأسواق المنتجات المحلية وأجواء الخريف الباردة في صلالة.',
    },
    'event3_name': {
      'en': 'Muscat International Book Fair',
      'ar': 'معرض مسقط الدولي للكتاب',
    },
    'event3_location': {'en': 'Muscat', 'ar': 'مسقط'},
    'event3_description': {
      'en': 'Get to see books related to Omani heritage and '
          'history, which further contribute to enhancing cultural '
          'understanding.',
      'ar': 'تعرف على الكتب المتعلقة بالتراث والتاريخ العُماني، '
          'مما يسهم في تعزيز الفهم الثقافي.',
    },
    'event3_info1': {
      'en': 'Date: Usually held in February each year.',
      'ar': 'التاريخ: يُقام عادةً في فبراير من كل عام.',
    },
    'event3_info2': {
      'en': 'Timing: Daily, morning through evening.',
      'ar': 'التوقيت: يوميًا، من الصباح حتى المساء.',
    },
    'event3_info3': {
      'en': 'Things To Do: Browse regional and international '
          'publishers, attend author talks, and pick up books on '
          'Omani history and culture.',
      'ar': 'الأنشطة: تصفح إصدارات دور النشر المحلية والعالمية، '
          'واحضر لقاءات مع المؤلفين، واقتنِ كتبًا عن تاريخ عُمان '
          'وثقافتها.',
    },
    'event4_name': {'en': 'Oman Marathon 2026', 'ar': 'ماراثون عُمان 2026'},
    'event4_location': {'en': 'Muscat', 'ar': 'مسقط'},
    'event4_description': {
      'en': 'Escape to Oman Marathon blended with adventures, '
          'vibrant coastal views making it a perfect event for '
          'runners and creates a memorable journey.',
      'ar': 'اهرب إلى ماراثون عُمان الممزوج بالمغامرة والإطلالات '
          'الساحلية النابضة بالحياة، مما يجعله فعالية مثالية '
          'للعدائين ويخلق رحلة لا تُنسى.',
    },
    'event4_info1': {
      'en': 'Date: Typically held in January.',
      'ar': 'التاريخ: يُقام عادةً في يناير.',
    },
    'event4_info2': {
      'en': 'Timing: Early morning start, around 6:00 AM.',
      'ar': 'التوقيت: بداية مبكرة في الصباح، حوالي الساعة 6:00 '
          'صباحًا.',
    },
    'event4_info3': {
      'en': 'Things To Do: Run the coastal course, cheer at the '
          'finish line festival, or join the family fun-run.',
      'ar': 'الأنشطة: اركض على المسار الساحلي، احتفل عند خط '
          'النهاية، أو شارك في سباق الجري العائلي.',
    },

    // ---- Arabic translation pass (A) ----
    'a_admin_login': {'en': 'Admin Login', 'ar': 'دخول المسؤول'},
    'a_restricted_access': {'en': 'Restricted access', 'ar': 'دخول مقيّد'},
    'a_admin_email_hint': {'en': 'Admin email', 'ar': 'البريد الإلكتروني للمسؤول'},
    'a_login_as_admin': {'en': 'Login as Admin', 'ar': 'تسجيل الدخول كمسؤول'},
    'a_back': {'en': 'Back', 'ar': 'رجوع'},
    'a_firebase_login_failed': {
      'en': 'Firebase could not log in this account.',
      'ar': 'تعذر تسجيل الدخول بهذا الحساب.',
    },
    'a_not_admin': {
      'en': 'This account is not registered as an Admin.',
      'ar': 'هذا الحساب غير مسجّل كمسؤول.',
    },
    'a_admin_dashboard': {'en': 'Admin Dashboard', 'ar': 'لوحة المسؤول'},
    'a_view_as_tourist': {'en': 'View app as tourist', 'ar': 'عرض التطبيق كسائح'},
    'a_manage_users': {'en': 'Manage Users', 'ar': 'إدارة المستخدمين'},
    'a_manage_users_sub': {'en': 'Roles & business approval', 'ar': 'الأدوار واعتماد الأعمال'},
    'a_all_feedback': {'en': 'All Feedback', 'ar': 'جميع الملاحظات'},
    'a_all_feedback_sub': {'en': 'Every rating & comment', 'ar': 'كل التقييمات والتعليقات'},
    'a_manage_destinations': {'en': 'Manage Destinations', 'ar': 'إدارة الوجهات'},
    'a_manage_destinations_sub': {'en': 'Add / edit / remove places', 'ar': 'إضافة / تعديل / حذف الأماكن'},
    'a_manage_events': {'en': 'Manage Events', 'ar': 'إدارة الفعاليات'},
    'a_manage_events_sub': {'en': 'Add / edit / remove events', 'ar': 'إضافة / تعديل / حذف الفعاليات'},
    'a_manage_businesses': {'en': 'Manage Businesses', 'ar': 'إدارة الأعمال'},
    'a_manage_businesses_sub': {'en': 'Approve / edit / remove listings', 'ar': 'اعتماد / تعديل / حذف القوائم'},
    'a_analytics': {'en': 'Analytics', 'ar': 'التحليلات'},
    'a_analytics_sub': {'en': 'Usage insights & charts', 'ar': 'رؤى الاستخدام والرسوم البيانية'},
    'a_announcements': {'en': 'Announcements', 'ar': 'الإعلانات'},
    'a_announcements_sub': {'en': 'Post updates to tourists', 'ar': 'انشر التحديثات للسياح'},
    'a_back_to_admin': {'en': 'Back to Admin', 'ar': 'العودة إلى لوحة المسؤول'},
    'a_error_prefix': {'en': 'Error: {error}', 'ar': 'خطأ: {error}'},
    'a_no_feedback': {'en': 'No feedback submitted yet.', 'ar': 'لم تُرسل أي ملاحظات بعد.'},
    'a_unknown_place': {'en': 'Unknown place', 'ar': 'مكان غير معروف'},
    'a_unknown_user': {'en': 'Unknown user', 'ar': 'مستخدم غير معروف'},
    'a_feedback_by': {'en': 'By {name}', 'ar': 'بواسطة {name}'},
    'a_no_users': {'en': 'No users yet.', 'ar': 'لا يوجد مستخدمون بعد.'},
    'a_no_name': {'en': '(no name)', 'ar': '(بدون اسم)'},
    'a_approved': {'en': 'Approved', 'ar': 'معتمد'},
    'a_waiting_approval': {'en': 'Waiting for approval', 'ar': 'بانتظار الاعتماد'},
    'a_revoke': {'en': 'Revoke', 'ar': 'إلغاء الاعتماد'},
    'a_approve': {'en': 'Approve', 'ar': 'اعتماد'},
    'a_err_email_registered': {'en': 'This email is already registered.', 'ar': 'هذا البريد الإلكتروني مسجّل بالفعل.'},
    'a_err_valid_email': {'en': 'Please enter a valid email address.', 'ar': 'يرجى إدخال بريد إلكتروني صالح.'},
    'a_err_invalid_credentials': {'en': 'Invalid email or password.', 'ar': 'البريد الإلكتروني أو كلمة المرور غير صحيحة.'},
    'a_err_stronger_password': {'en': 'Please choose a stronger password.', 'ar': 'يرجى اختيار كلمة مرور أقوى.'},
    'a_err_account_disabled': {'en': 'This account has been disabled.', 'ar': 'تم تعطيل هذا الحساب.'},
    'a_err_network': {'en': 'Network error. Check your connection and try again.', 'ar': 'خطأ في الشبكة. تحقق من اتصالك وحاول مرة أخرى.'},
    'a_err_too_many': {'en': 'Too many attempts. Please try again later.', 'ar': 'محاولات كثيرة جدًا. يرجى المحاولة لاحقًا.'},
    'a_err_recent_login': {'en': 'Please log in again before changing your password.', 'ar': 'يرجى تسجيل الدخول مجددًا قبل تغيير كلمة المرور.'},
    'a_err_op_not_allowed': {'en': 'Email/password sign-in is not enabled in Firebase.', 'ar': 'تسجيل الدخول بالبريد وكلمة المرور غير مفعّل في Firebase.'},
    'a_err_unauth_domain': {'en': 'This website is not allowed in Firebase Authentication settings.', 'ar': 'هذا الموقع غير مسموح به في إعدادات مصادقة Firebase.'},
    'a_err_config_not_found': {'en': 'Firebase Authentication is not configured for this app.', 'ar': 'لم يتم إعداد مصادقة Firebase لهذا التطبيق.'},
    'a_err_role_mismatch': {'en': 'This account is not registered for that role.', 'ar': 'هذا الحساب غير مسجّل لهذا الدور.'},
    'a_err_auth_failed': {'en': 'Firebase authentication failed.', 'ar': 'فشلت المصادقة.'},
    'a_err_permission': {'en': 'You do not have permission to access this data.', 'ar': 'ليس لديك صلاحية للوصول إلى هذه البيانات.'},
    'a_err_request_failed': {'en': 'Firebase request failed.', 'ar': 'فشل الطلب.'},
    'a_err_generic': {'en': 'Something went wrong. Please try again.', 'ar': 'حدث خطأ ما. يرجى المحاولة مرة أخرى.'},

    // ---- Arabic translation pass (B) ----
    'b_required': {'en': 'Required', 'ar': 'مطلوب'},
    'b_could_not_save': {'en': 'Could not save: {error}', 'ar': 'تعذر الحفظ: {error}'},
    'b_name': {'en': 'Name', 'ar': 'الاسم'},
    'b_name_en': {'en': 'Name (English)', 'ar': 'الاسم (بالإنجليزية)'},
    'b_name_ar': {'en': 'Name (Arabic)', 'ar': 'الاسم (بالعربية)'},
    'b_location': {'en': 'Location', 'ar': 'الموقع'},
    'b_location_en': {'en': 'Location (English)', 'ar': 'الموقع (بالإنجليزية)'},
    'b_location_ar': {'en': 'Location (Arabic)', 'ar': 'الموقع (بالعربية)'},
    'b_short_desc': {'en': 'Short description (shown on the card)', 'ar': 'وصف مختصر (يظهر على البطاقة)'},
    'b_desc_en': {'en': 'Description (English)', 'ar': 'الوصف (بالإنجليزية)'},
    'b_desc_ar': {'en': 'Description (Arabic)', 'ar': 'الوصف (بالعربية)'},
    'b_icon': {'en': 'Icon', 'ar': 'الأيقونة'},
    'b_photo_url': {'en': 'Photo URL (optional — leave blank to show an icon tile)', 'ar': 'رابط الصورة (اختياري — اتركه فارغًا لعرض أيقونة)'},
    'b_cancel': {'en': 'Cancel', 'ar': 'إلغاء'},
    'b_delete': {'en': 'Delete', 'ar': 'حذف'},
    'b_edit': {'en': 'Edit', 'ar': 'تعديل'},
    'b_remove_confirm': {'en': 'This will permanently remove "{name}".', 'ar': 'سيتم حذف "{name}" نهائيًا.'},
    'b_save_changes': {'en': 'Save Changes', 'ar': 'حفظ التغييرات'},
    'b_manage_dest': {'en': 'Manage Destinations', 'ar': 'إدارة الوجهات'},
    'b_add_dest': {'en': 'Add Destination', 'ar': 'إضافة وجهة'},
    'b_edit_dest': {'en': 'Edit Destination', 'ar': 'تعديل الوجهة'},
    'b_no_dest': {'en': 'No destinations yet.', 'ar': 'لا توجد وجهات بعد.'},
    'b_delete_dest_q': {'en': 'Delete destination?', 'ar': 'حذف الوجهة؟'},
    'b_full_details': {'en': 'Full details (shown on the detail page)', 'ar': 'التفاصيل الكاملة (تظهر في صفحة التفاصيل)'},
    'b_details_en': {'en': 'Details (English)', 'ar': 'التفاصيل (بالإنجليزية)'},
    'b_details_ar': {'en': 'Details (Arabic)', 'ar': 'التفاصيل (بالعربية)'},
    'b_manage_events': {'en': 'Manage Events', 'ar': 'إدارة الفعاليات'},
    'b_add_event': {'en': 'Add Event', 'ar': 'إضافة فعالية'},
    'b_edit_event': {'en': 'Edit Event', 'ar': 'تعديل الفعالية'},
    'b_no_events': {'en': 'No events yet.', 'ar': 'لا توجد فعاليات بعد.'},
    'b_delete_event_q': {'en': 'Delete event?', 'ar': 'حذف الفعالية؟'},
    'b_info_lines': {'en': 'Info lines (Date, Timing, Things To Do, ...)', 'ar': 'أسطر المعلومات (التاريخ، التوقيت، الأنشطة، ...)'},
    'b_add_line': {'en': 'Add line', 'ar': 'إضافة سطر'},
    'b_line_n': {'en': 'Line {n}', 'ar': 'السطر {n}'},
    'b_english': {'en': 'English', 'ar': 'الإنجليزية'},
    'b_arabic': {'en': 'Arabic', 'ar': 'العربية'},
    'b_delete_biz_q': {'en': 'Delete this business?', 'ar': 'حذف هذا النشاط التجاري؟'},
    'b_manage_biz': {'en': 'Manage Businesses', 'ar': 'إدارة الأنشطة التجارية'},
    'b_add_biz': {'en': 'Add Business', 'ar': 'إضافة نشاط تجاري'},
    'b_no_biz': {'en': 'No businesses yet.', 'ar': 'لا توجد أنشطة تجارية بعد.'},
    'b_owner_n': {'en': 'Owner: {name}', 'ar': 'المالك: {name}'},
    'b_approve': {'en': 'Approve', 'ar': 'موافقة'},
    'b_reject': {'en': 'Reject', 'ar': 'رفض'},
    'b_confirm_delete': {'en': 'Confirm Delete', 'ar': 'تأكيد الحذف'},
    'b_keep_listing': {'en': 'Keep Listing', 'ar': 'إبقاء الإدراج'},
    'b_undo_reject': {'en': 'Undo Reject', 'ar': 'التراجع عن الرفض'},
    'b_status_approved': {'en': 'Approved', 'ar': 'تمت الموافقة'},
    'b_status_pending': {'en': 'Pending approval', 'ar': 'بانتظار الموافقة'},
    'b_status_delete_requested': {'en': 'Delete requested', 'ar': 'طُلب الحذف'},
    'b_status_rejected': {'en': 'Rejected', 'ar': 'مرفوض'},

    // ---- Arabic translation pass (C) ----
    'c_my_business': {'en': 'My Business', 'ar': 'نشاطي التجاري'},
    'c_login_required': {'en': 'You need to be logged in.', 'ar': 'يجب تسجيل الدخول أولاً.'},
    'c_business_report_tip': {'en': 'Business report', 'ar': 'تقرير النشاط التجاري'},
    'c_business_report': {'en': 'Business Report', 'ar': 'تقرير النشاط التجاري'},
    'c_owner_only_title': {'en': 'This page is for Business Owner accounts', 'ar': 'هذه الصفحة لحسابات أصحاب الأعمال'},
    'c_owner_only_msg': {'en': 'Your account isn\'t registered as a Local Business Owner, so there\'s no business to manage here.', 'ar': 'حسابك غير مسجل كصاحب نشاط تجاري محلي، لذا لا يوجد نشاط لإدارته هنا.'},
    'c_wait_approval_title': {'en': 'Waiting for admin approval', 'ar': 'بانتظار موافقة المشرف'},
    'c_wait_approval_msg': {'en': 'An admin needs to approve your Business Owner account before you can add your business. Check back soon.', 'ar': 'يجب أن يوافق المشرف على حساب صاحب النشاط التجاري قبل أن تتمكن من إضافة نشاطك. عاود المحاولة قريبًا.'},
    'c_no_business_title': {'en': 'You haven\'t added your business yet', 'ar': 'لم تضف نشاطك التجاري بعد'},
    'c_no_business_msg': {'en': 'Add it below. An admin will review and approve it before it appears to tourists.', 'ar': 'أضفه أدناه. سيراجعه المشرف ويوافق عليه قبل ظهوره للسياح.'},
    'c_add_your_business': {'en': 'Add Your Business', 'ar': 'أضف نشاطك التجاري'},
    'c_add_another_business': {'en': 'Add Another Business', 'ar': 'أضف نشاطًا تجاريًا آخر'},
    'c_remove_business_q': {'en': 'Remove your business?', 'ar': 'إزالة نشاطك التجاري؟'},
    'c_remove_pending_msg': {'en': 'This listing isn\'t live yet, so it will be removed right away.', 'ar': 'هذا الإدراج غير منشور بعد، لذا ستتم إزالته فورًا.'},
    'c_remove_live_msg': {'en': 'This sends a delete request to the admin. Your listing stays visible to tourists until the admin confirms it.', 'ar': 'سيُرسل هذا طلب حذف إلى المشرف. يبقى إدراجك ظاهرًا للسياح حتى يؤكد المشرف الحذف.'},
    'c_cancel': {'en': 'Cancel', 'ar': 'إلغاء'},
    'c_remove': {'en': 'Remove', 'ar': 'إزالة'},
    'c_rejected_note': {'en': 'The admin declined this listing. Edit and save it to resubmit for approval.', 'ar': 'رفض المشرف هذا الإدراج. عدّله واحفظه لإعادة إرساله للموافقة.'},
    'c_edit': {'en': 'Edit', 'ar': 'تعديل'},
    'c_delete': {'en': 'Delete', 'ar': 'حذف'},
    'c_required': {'en': 'Required', 'ar': 'مطلوب'},
    'c_sent_for_approval': {'en': 'Sent for admin approval.', 'ar': 'تم الإرسال لموافقة المشرف.'},
    'c_could_not_save': {'en': 'Could not save: {error}', 'ar': 'تعذر الحفظ: {error}'},
    'c_edit_business': {'en': 'Edit Business', 'ar': 'تعديل النشاط التجاري'},
    'c_form_notice': {'en': 'Saving sends this to the admin for approval before it goes live.', 'ar': 'سيُرسل الحفظ هذا إلى المشرف للموافقة قبل النشر.'},
    'c_business_name': {'en': 'Business Name', 'ar': 'اسم النشاط التجاري'},
    'c_location': {'en': 'Location', 'ar': 'الموقع'},
    'c_description': {'en': 'Description', 'ar': 'الوصف'},
    'c_contact_phone': {'en': 'Contact Phone', 'ar': 'هاتف التواصل'},
    'c_icon': {'en': 'Icon', 'ar': 'الأيقونة'},
    'c_photo_url': {'en': 'Photo URL (optional — https://...)', 'ar': 'رابط الصورة (اختياري — https://...)'},
    'c_save_changes': {'en': 'Save Changes', 'ar': 'حفظ التغييرات'},
    'c_submit': {'en': 'Submit', 'ar': 'إرسال'},
    'c_report_share_title': {'en': 'Explore Oman - Business report', 'ar': 'استكشف عُمان - تقرير النشاط التجاري'},
    'c_report_generated': {'en': 'Generated: {date}', 'ar': 'تاريخ الإنشاء: {date}'},
    'c_report_views_line': {'en': '  Views: {n}', 'ar': '  المشاهدات: {n}'},
    'c_report_feedback_line': {'en': '  Feedback: {n}', 'ar': '  التقييمات: {n}'},
    'c_report_average': {'en': ', average {avg}/5', 'ar': '، المتوسط {avg}/5'},
    'c_refresh': {'en': 'Refresh', 'ar': 'تحديث'},
    'c_report_load_error': {'en': 'Could not load the report.', 'ar': 'تعذر تحميل التقرير.'},
    'c_report_no_business': {'en': 'Add a business first. Its views and feedback will appear here.', 'ar': 'أضف نشاطًا تجاريًا أولاً. ستظهر مشاهداته وتقييماته هنا.'},
    'c_report_no_permission': {'en': 'Some report data is not available yet (database permissions).', 'ar': 'بعض بيانات التقرير غير متاحة بعد (صلاحيات قاعدة البيانات).'},
    'c_views': {'en': 'Views', 'ar': 'المشاهدات'},
    'c_rating': {'en': 'Rating', 'ar': 'التقييم'},
    'c_views_per_listing': {'en': 'Views per listing', 'ar': 'المشاهدات لكل إدراج'},
    'c_feedback_views_line': {'en': '   {f} feedback  -  {v} views', 'ar': '   {f} تقييم  -  {v} مشاهدة'},
    'c_no_ratings': {'en': 'No ratings yet.', 'ar': 'لا توجد تقييمات بعد.'},
    'c_one_star': {'en': '1 star', 'ar': 'نجمة واحدة'},
    'c_n_stars': {'en': '{n} stars', 'ar': '{n} نجوم'},
    'c_recent_comments': {'en': 'Recent comments', 'ar': 'أحدث التعليقات'},
    'c_share_report': {'en': 'Share report', 'ar': 'مشاركة التقرير'},
    'c_no_data_period': {'en': 'No data in this period yet.', 'ar': 'لا توجد بيانات في هذه الفترة بعد.'},

    // ---- Arabic translation pass (D) ----
    'd_an_title': {'en': 'Analytics', 'ar': 'التحليلات'},
    'd_an_refresh': {'en': 'Refresh', 'ar': 'تحديث'},
    'd_an_load_error': {'en': 'Could not load analytics.', 'ar': 'تعذّر تحميل التحليلات.'},
    'd_an_denied': {
      'en': 'Some data could not be read ({paths}). Check the Firebase database rules.',
      'ar': 'تعذّرت قراءة بعض البيانات ({paths}). تحقق من قواعد قاعدة بيانات Firebase.',
    },
    'd_an_users': {'en': 'Users', 'ar': 'المستخدمون'},
    'd_an_new_week': {'en': '{n} new this week', 'ar': '{n} جديد هذا الأسبوع'},
    'd_an_page_views': {'en': 'Page views', 'ar': 'مشاهدات الصفحات'},
    'd_an_last7': {'en': '{n} in last 7 days', 'ar': '{n} في آخر 7 أيام'},
    'd_an_destinations': {'en': 'Destinations', 'ar': 'الوجهات'},
    'd_an_events_n': {'en': '{n} events', 'ar': '{n} فعالية'},
    'd_an_businesses': {'en': 'Businesses', 'ar': 'الأعمال'},
    'd_an_feedback': {'en': 'Feedback', 'ar': 'التقييمات'},
    'd_an_avg_rating': {'en': 'Average rating', 'ar': 'متوسط التقييم'},
    'd_an_out_of_5': {'en': 'out of 5', 'ar': 'من 5'},
    'd_an_app_activity': {'en': 'App activity', 'ar': 'نشاط التطبيق'},
    'd_an_views_per_day': {'en': 'Page views per day - last 14 days', 'ar': 'مشاهدات الصفحات يوميًا - آخر 14 يومًا'},
    'd_an_new_signups': {'en': 'New sign-ups', 'ar': 'التسجيلات الجديدة'},
    'd_an_signups_per_day': {'en': 'Accounts created per day - last 14 days', 'ar': 'الحسابات المنشأة يوميًا - آخر 14 يومًا'},
    'd_an_users_by_role': {'en': 'Users by role', 'ar': 'المستخدمون حسب الدور'},
    'd_an_users_lower': {'en': 'users', 'ar': 'مستخدم'},
    'd_an_tourists': {'en': 'Tourists', 'ar': 'السياح'},
    'd_an_owners': {'en': 'Business owners', 'ar': 'أصحاب الأعمال'},
    'd_an_admins': {'en': 'Admins', 'ar': 'المسؤولون'},
    'd_an_owners_waiting': {
      'en': '{n} business owner account(s) waiting for approval',
      'ar': '{n} حساب(ات) لأصحاب الأعمال بانتظار الموافقة',
    },
    'd_an_biz_by_status': {'en': 'Businesses by status', 'ar': 'الأعمال حسب الحالة'},
    'd_an_no_businesses': {'en': 'No businesses yet.', 'ar': 'لا توجد أعمال بعد.'},
    'd_an_listings': {'en': 'listings', 'ar': 'قوائم'},
    'd_an_most_viewed_places': {'en': 'Most viewed places', 'ar': 'الأماكن الأكثر مشاهدة'},
    'd_an_dest_opened': {'en': 'Destinations opened by visitors', 'ar': 'الوجهات التي فتحها الزوار'},
    'd_an_no_views': {
      'en': 'No views recorded yet. They appear as visitors open places.',
      'ar': 'لم تُسجَّل مشاهدات بعد. ستظهر عندما يفتح الزوار الأماكن.',
    },
    'd_an_most_viewed_biz': {'en': 'Most viewed local businesses', 'ar': 'الأعمال المحلية الأكثر مشاهدة'},
    'd_an_event_engagement': {'en': 'Event engagement', 'ar': 'التفاعل مع الفعاليات'},
    'd_an_event_engagement_sub': {'en': 'Views, with feedback count and rating', 'ar': 'المشاهدات مع عدد التقييمات والتقييم'},
    'd_an_no_events': {'en': 'No events yet.', 'ar': 'لا توجد فعاليات بعد.'},
    'd_an_feedback_n': {'en': '{n} feedback', 'ar': '{n} تقييم'},
    'd_an_feedback_summary': {'en': 'Feedback summary', 'ar': 'ملخص التقييمات'},
    'd_an_rating_breakdown': {'en': 'Rating breakdown', 'ar': 'توزيع التقييمات'},
    'd_an_no_feedback': {'en': 'No feedback yet.', 'ar': 'لا توجد تقييمات بعد.'},
    'd_an_star': {'en': '{n} star', 'ar': '{n} نجمة'},
    'd_an_stars': {'en': '{n} stars', 'ar': '{n} نجوم'},
    'd_an_top_rated': {'en': 'Top rated places', 'ar': 'الأماكن الأعلى تقييمًا'},
    'd_an_no_ratings': {'en': 'No ratings yet.', 'ar': 'لا توجد تقييمات بعد.'},
    'd_an_mention_most': {'en': 'What visitors mention most', 'ar': 'أكثر ما يذكره الزوار'},
    'd_an_feedback_tags': {'en': 'Feedback tags', 'ar': 'وسوم التقييمات'},
    'd_an_latest_comments': {'en': 'Latest comments', 'ar': 'أحدث التعليقات'},
    'd_an_share_report': {'en': 'Share report', 'ar': 'مشاركة التقرير'},
    'd_an_rep_title': {'en': 'Explore Oman - Analytics report', 'ar': 'استكشف عُمان - تقرير التحليلات'},
    'd_an_rep_generated': {'en': 'Generated: {date}', 'ar': 'تاريخ الإنشاء: {date}'},
    'd_an_rep_users': {'en': 'Users: {n} ({w} new this week)', 'ar': 'المستخدمون: {n} ({w} جديد هذا الأسبوع)'},
    'd_an_rep_roles': {
      'en': '  Tourists {t}, Business owners {o}, Admins {a}',
      'ar': '  السياح {t}، أصحاب الأعمال {o}، المسؤولون {a}',
    },
    'd_an_rep_destinations': {'en': 'Destinations: {n}', 'ar': 'الوجهات: {n}'},
    'd_an_rep_events': {'en': 'Events: {n}', 'ar': 'الفعاليات: {n}'},
    'd_an_rep_businesses': {'en': 'Businesses: {n}', 'ar': 'الأعمال: {n}'},
    'd_an_rep_views': {'en': 'Page views: {n} ({w} in the last 7 days)', 'ar': 'مشاهدات الصفحات: {n} ({w} في آخر 7 أيام)'},
    'd_an_rep_feedback': {'en': 'Feedback: {n}, average rating {avg}/5', 'ar': 'التقييمات: {n}، متوسط التقييم {avg}/5'},
    'd_an_rep_most_viewed': {'en': 'Most viewed places:', 'ar': 'الأماكن الأكثر مشاهدة:'},
    'd_an_rep_item_views': {'en': '{i}. {name} - {n} views', 'ar': '{i}. {name} - {n} مشاهدة'},
    'd_an_rep_event_engagement': {'en': 'Event engagement:', 'ar': 'التفاعل مع الفعاليات:'},
    'd_an_rep_event_line': {'en': '- {name}: {v} views, {f} feedback', 'ar': '- {name}: {v} مشاهدة، {f} تقييم'},
    'd_an_rep_top_rated': {'en': 'Top rated places:', 'ar': 'الأماكن الأعلى تقييمًا:'},
    'd_ann_title': {'en': 'Announcements', 'ar': 'الإعلانات'},
    'd_ann_new': {'en': 'New Announcement', 'ar': 'إعلان جديد'},
    'd_ann_delete_q': {'en': 'Delete announcement?', 'ar': 'حذف الإعلان؟'},
    'd_ann_cancel': {'en': 'Cancel', 'ar': 'إلغاء'},
    'd_ann_delete': {'en': 'Delete', 'ar': 'حذف'},
    'd_ann_empty': {
      'en': 'No announcements yet.\nTap "New Announcement" to post one.',
      'ar': 'لا توجد إعلانات بعد.\nاضغط على "إعلان جديد" لنشر إعلان.',
    },
    'd_ann_event_update': {'en': 'Event update', 'ar': 'تحديث فعالية'},
    'd_ann_general_news': {'en': 'General news', 'ar': 'أخبار عامة'},
    'd_ann_posted': {'en': 'Announcement posted.', 'ar': 'تم نشر الإعلان.'},
    'd_ann_post_failed': {'en': 'Could not post: {error}', 'ar': 'تعذّر النشر: {error}'},
    'd_ann_title_en': {'en': 'Title (English)', 'ar': 'العنوان (بالإنجليزية)'},
    'd_ann_msg_en': {'en': 'Message (English)', 'ar': 'الرسالة (بالإنجليزية)'},
    'd_ann_title_ar': {'en': 'Title (Arabic, optional)', 'ar': 'العنوان (بالعربية، اختياري)'},
    'd_ann_msg_ar': {'en': 'Message (Arabic, optional)', 'ar': 'الرسالة (بالعربية، اختياري)'},
    'd_ann_required': {'en': 'Required', 'ar': 'مطلوب'},
    'd_ann_post': {'en': 'Post announcement', 'ar': 'نشر الإعلان'},
    'd_ann_just_now': {'en': 'Just now', 'ar': 'الآن'},
    'd_ann_min_ago': {'en': '{n} min ago', 'ar': 'منذ {n} دقيقة'},
    'd_ann_h_ago': {'en': '{n} h ago', 'ar': 'منذ {n} ساعة'},
    'd_ann_d_ago': {'en': '{n} d ago', 'ar': 'منذ {n} يوم'},

    // ---- Arabic translation pass (E) ----
    'light_mode': {'en': 'Light', 'ar': 'فاتح'},
    'dark_mode': {'en': 'Dark', 'ar': 'داكن'},
    'e_explore_more': {'en': 'Explore More', 'ar': 'اكتشف المزيد'},
    'e_my_business': {'en': 'My Business', 'ar': 'نشاطي التجاري'},
    'e_local_business': {'en': 'Local business', 'ar': 'نشاط تجاري محلي'},
    'e_phone_label': {'en': 'Phone:', 'ar': 'الهاتف:'},
    'e_user': {'en': 'User', 'ar': 'مستخدم'},
    'e_share_message': {
      'en': 'Check out {name}{locationLine} — found it on Explore Oman!',
      'ar': 'اطلع على {name}{locationLine} — وجدته في تطبيق استكشف عُمان!',
    },
    'e_share_in': {'en': ' in {location}', 'ar': ' في {location}'},
    'e_could_not_update_profile': {
      'en': 'Could not update profile: {error}',
      'ar': 'تعذر تحديث الملف الشخصي: {error}',
    },
    'e_profile_updated': {'en': 'Profile updated.', 'ar': 'تم تحديث الملف الشخصي.'},
    'e_profile_updated_check_email': {
      'en': 'Profile updated. Check {email} for a link to confirm your new email address.',
      'ar': 'تم تحديث الملف الشخصي. تحقق من {email} للحصول على رابط لتأكيد عنوان بريدك الإلكتروني الجديد.',
    },
    'e_confirm_your_password': {'en': 'Confirm your password', 'ar': 'أكّد كلمة المرور'},
    'e_reauth_explanation': {
      'en': 'For your security, changing your email requires confirming your current password.',
      'ar': 'لحمايتك، يتطلب تغيير البريد الإلكتروني تأكيد كلمة المرور الحالية.',
    },
    'e_current_password': {'en': 'Current password', 'ar': 'كلمة المرور الحالية'},
    'e_cancel': {'en': 'Cancel', 'ar': 'إلغاء'},
    'e_confirm': {'en': 'Confirm', 'ar': 'تأكيد'},
    'e_enter_your_password': {'en': 'Please enter your password', 'ar': 'يرجى إدخال كلمة المرور'},
    'e_incorrect_password': {'en': 'Incorrect password', 'ar': 'كلمة المرور غير صحيحة'},
    'e_choose_avatar': {'en': 'Choose an avatar', 'ar': 'اختر صورة رمزية'},
    'e_your_details': {'en': 'Your details', 'ar': 'بياناتك'},
    'e_change_email_note': {
      'en': 'Changing your email will send a confirmation link to the new address before it takes effect.',
      'ar': 'سيؤدي تغيير بريدك الإلكتروني إلى إرسال رابط تأكيد إلى العنوان الجديد قبل أن يصبح ساريًا.',
    },
    'e_save_changes': {'en': 'Save Changes', 'ar': 'حفظ التغييرات'},
  };

  static String of(String key) {
    final languageCode = AppSettings.instance.locale.languageCode;
    final entry = _values[key];
    if (entry == null) return key;
    return entry[languageCode] ?? entry['en'] ?? key;
  }
}

/// Shorthand so call sites can just write tr('home') instead of
/// AppStrings.of('home').
String tr(String key) => AppStrings.of(key);