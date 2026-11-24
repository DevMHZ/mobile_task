# Mobile Task

تطبيق Flutter لتقييم Mobile Developer، بالنسخة الزرقاء من تصميم Figma، مع واجهة عربية وإنجليزية وبيانات منتجات من DummyJSON.
التطبيق يعرض منتجات تجريبية ضمن تخطيط مستوحى من العقارات؛ لا يقدم بيانات عقارات حقيقية.

- المستودع: https://github.com/DevMHZ/mobile_task
- المرجع: [تصميم Figma](https://www.figma.com/design/dXUFyRx7RgaaS0lGWPPFd3/Real-Estate-Mobile-App-Design--Community-?node-id=0-1).
- الواجهات: الرئيسية، الاستكشاف والبحث، التصفية، التفاصيل ومعرض الصور، المفضلة، الملف الشخصي، وإدارة المجموعة ونموذج الإضافة والتعديل.
- الإثبات البصري: [screenshots/](screenshots/)، بأسماء تنتهي بـ `-ar` أو `-en`.
- استخدام الذكاء الاصطناعي: [AI_USAGE.md](AI_USAGE.md).
- نتائج التحقق وحدودها: [VALIDATION.md](VALIDATION.md).

## متطلبات التشغيل

النسخة المتحقق منها هي Flutter `3.47.7` stable وDart `3.13.5`؛ لا يُفترض التوافق مع كل إصدار أحدث دون فحص.
يتطلب Android وجود JDK 17 وAndroid SDK Platform 36 وأدوات البناء التي يطلبها Flutter.
يستخدم المشروع Gradle `9.4.1` وAGP `9.2.1` وKotlin `2.4.0`، مع checksum لتوزيعة Gradle.
الحد الأدنى لإصدار Android هو API 24، والهدف الحالي API 36.
يتطلب iOS وجود macOS وXcode وCocoaPods؛ اختُبرت الواجهة على iOS Simulator 26.5.
أبقِ إعدادَي `android.newDsl=false` و`android.builtInKotlin=false` مع نسخة Flutter الحالية والحزم المستخدمة.
يتطلب جلب البيانات والصور اتصالاً بالإنترنت.

## التثبيت والتشغيل

```bash
git clone https://github.com/DevMHZ/mobile_task.git
cd mobile_task
flutter pub get --enforce-lockfile
flutter gen-l10n
flutter run --dart-define-from-file=env/dev.json
```

لتهيئة iOS عند الحاجة:

```bash
cd ios
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 pod install
cd ..
```

لبناء APK:

```bash
flutter build apk --release
```

الناتج في `build/app/outputs/flutter-apk/app-release.apk`.
بناء Release الحالي موقّع بمفتاح debug المحلي ليكون قابلاً للتثبيت بغرض التقييم.
التوزيع على المتاجر يحتاج إعداد مفتاح توقيع خاص، وهو خارج نطاق المهمة.
شغّل أوامر Flutter للاختبارات والبناء بالتتابع لأن بعضها يعيد توليد ملفات تسجيل plugins.

## إعداد API

العنوان الافتراضي هو `https://dummyjson.com`، ويمكن تمريره من `env/dev.json` أو تغييره دون تعديل الكود:

```bash
flutter run --dart-define=API_BASE_URL=https://dummyjson.com
```

لا يحتاج DummyJSON إلى مفتاح سري لهذا الاستخدام.
تستعمل طبقة API بيانات المنتجات والفئات، وطلبات POST وPATCH وDELETE للعمليات التجريبية.

## البنية وإدارة الحالة

التنظيم حسب الميزة داخل `lib/features/`، مع فصل `data/api` و`data/models` و`data/repo` عن `presentation/cubit` و`presentation/ui`.
يجمع `lib/core/` إعدادات الشبكة والتعريب والثيم والصور والمكونات المشتركة والتنقل.
تستعمل الواجهات Cubit لعرض الحالة وتنفيذ الإجراءات، ولا تستدعي Dio مباشرة.
يجمع GetIt الاعتماديات عند نقطة الدخول، ثم تمرر إلى الواجهات عبر providers.
يحفظ `CatalogRepository` الكتالوج وتعديلات الجلسة، ويطبق `CatalogQuery` البحث والفلترة والفرز محلياً.
تُجلب المنتجات كاملة باستخدام `limit=0` لتعمل الفلاتر على كامل المجموعة، مع تجنب طلب بحث جديد لكل ضغطة.
لكل تبويب Navigator مستقل مع الاحتفاظ بحالة التمرير والبحث أثناء التنقل.

| الحزمة | سبب الاستخدام |
|---|---|
| `flutter_bloc` | Cubit وحالات منفصلة للكتالوج والتفاصيل والتفضيلات |
| `dio` | طلبات HTTP والمهل وتصنيف أخطاء الشبكة |
| `get_it` | تجميع الاعتماديات عند نقطة الدخول |
| `shared_preferences` | حفظ اللغة ومعرّفات المفضلة عبر `SharedPreferencesAsync` |
| `cached_network_image` و`flutter_cache_manager` | تحميل الصور وتخزينها المؤقت ومشاركة مصدر الكاش |
| `photo_view` | تكبير صور المعرض والتنقل بينها |
| `intl` و`flutter_localizations` | الأرقام والعملات والترجمة واتجاه العرض |

سياسة الصور في `ImagePolicy` تحدد حدود فك الصورة حسب القياس وDPR، وتحد التخزين إلى 200 ملف مع مدة احتفاظ للملفات غير المستخدمة تبلغ 14 يوماً.
لا تعني مدة الاحتفاظ أن محتوى المصدر سيبقى صالحاً طوال هذه المدة؛ تُراعى استجابة HTTP وسياسة الكاش.

## العربية والإنجليزية

يمكن تبديل اللغة فوراً من شريط الرئيسية أو قسم اللغة في الملف الشخصي.
تُحفظ اللغة محلياً وتُستعاد عند بدء التطبيق.
تُولّد النصوص من ملفات ARB في `lib/l10n/`، ويحدد `MaterialApp.locale` اتجاه RTL أو LTR عبر Flutter localizations.
تستعمل الواجهة المحاذاة الاتجاهية والأسهم المناسبة، مع تنسيق الأسعار والأعداد عبر أدوات التعريب.
الخط الإنجليزي Rubik والعربي IBM Plex Sans Arabic، وكلاهما مدمج محلياً.
أسماء المنتجات وأوصافها وفئاتها تأتي بالإنجليزية من API، ولا تُقدّم على أنها مترجمة من الخادم.

## الافتراضات والقيود

DummyJSON يحاكي POST وPATCH وDELETE ولا يحفظ التغييرات على الخادم.
تبقى الإضافات والتعديلات والحذف في ذاكرة الجلسة فقط، وتعود بيانات الخادم عند إنهاء العملية وإعادة فتح التطبيق.
اللغة والمفضلة تُحفظان على الجهاز، بينما لا تُحفظ معرّفات المنتجات المحلية المؤقتة بين الجلسات.
تستخدم الإضافات المحلية معرّفات سالبة لتجنب الخلط مع معرّفات الخادم.
حقول نوع العقار وغرف النوم والحمامات والمساحة مشتقة حتمياً من معرّف المنتج لمحاكاة فلاتر تصميم العقارات.
هذه الحقول ليست من DummyJSON، ويظهر تنبيه بذلك في التفاصيل.
لا توجد مصادقة أو حجوزات أو بيانات وكلاء حقيقية ضمن هذه المهمة.
لا يقدم التطبيق كتالوجاً دائماً للعمل دون اتصال؛ يعرض خطأ اتصال قابلاً لإعادة المحاولة عند تعذر الجلب.
لا توجد نتائج benchmark تثبت معدل إطارات محدداً أو مطابقة بصرية كاملة لكل إطار في Figma.

## الفحوصات

```bash
dart format --output=none --set-exit-if-changed lib test integration_test test_driver
flutter analyze --fatal-infos
flutter test
```

رحلة اللقطات والتنقل الحقيقية تتطلب محاكياً أو جهازاً واتصالاً بـ DummyJSON:

```bash
flutter drive --driver=test_driver/integration_driver.dart --target=integration_test/app_flow_test.dart -d DEVICE_ID --dart-define-from-file=env/dev.json
flutter drive --driver=test_driver/integration_driver.dart --target=integration_test/crud_flow_test.dart -d DEVICE_ID --dart-define-from-file=env/dev.json
```

تكتب الرحلة الأولى لقطات الشاشات باللغتين في `screenshots/`.
تتحقق الثانية من تعديل عنصر وحذفه وإضافة عنصر، ومن بقاء التعديل بعد تحديث الكتالوج خلال الجلسة.
لا تستبدل هذه الاختبارات مراجعة بصرية أو تجربة تثبيت APK على جهاز حقيقي.
