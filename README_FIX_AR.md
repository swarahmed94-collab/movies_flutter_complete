# Movies Trailer — Repair Patch

التقرير السابق أظهر أخطاء في `patch_templates/trailer_player_screen.dart` لأنها نسخة من ملف الشاشة خارج `lib/`، بالإضافة إلى اختبار Flutter قديم يشير إلى `MyApp` بدل التطبيق الحالي.

**التصحيح ده لا يعدل Firebase، ولا API، ولا أي SVG، ولا Movie Details UI، ولا Podfile/Signing.**

## التركيب من VS Code Terminal

افتح مجلد `movies_flutter_complete` (لازم يكون فيه `pubspec.yaml`) ثم:

```bash
unzip -o ~/Downloads/Movies_Trailer_Repair.zip -d .
python3 tools/repair_movies_trailer.py --dry-run
python3 tools/repair_movies_trailer.py
flutter pub get
flutter analyze
```

الإصلاح هيعمل الآتي عند الحاجة:

1. يشيل نسخة القالب المكررة `patch_templates/trailer_player_screen.dart` من جذر المشروع بعد أخذ نسخة احتياطية نصية.
2. يتأكد إن `lib/features/movies/presentation/screens/trailer_player_screen.dart` موجود. لو مش موجود، ينشئه في مكانه الصحيح.
3. يتأكد إن زر Watch الأصلي بيفتح شاشة التريلر. لو كودك مختلف، هيوقف بدل ما يستبدل شغلك.
4. يغيّر `autoPlay: true` إلى `autoPlay: false` داخل المشغّل المضاف سابقًا، فالمستخدم يضغط Play داخل المشغّل، وده أنسب للـ iPhone.
5. يصلح اختبار `test/widget_test.dart` القديم فقط لو لقى استدعاء `MyApp()`، ويستبدله باختبار فعلي لكيان Movie.

**بعد نجاح `flutter analyze`:** اقفل التطبيق بالكامل، وصل الآيفون بالكابل أول مرة لو الوايرلس مش مستقر، ثم:

```bash
flutter devices
flutter run -d 00008140-00063DA92252801C
```

اختبر زر Watch: المفروض تظهر شاشة تشغيل التريلر داخل التطبيق. اضغط Play من المشغّل؛ زر `Find Full Movie on YouTube` يفتح **نتائج البحث** على YouTube وليس فيلمًا مضمون التوفر.

لو Flutter Analyze ما زال يظهر **errors**، ابعت نصها. لو التطبيق يفتح لكن الفيديو شاشة سوداء/الزر الخارجي لا يعمل، ابعت **رسالة الـDebug Console أثناء الضغط**: تقرير analyze لا يستطيع تشخيص خطأ تشغيل فيديو أو اتصال شبكة بمفرده.

### ملاحظات

- لا تعيد تشغيل `scripts/apply_movies_trailer_only.py` القديم بعد التصحيح؛ كان يحتوي قالب Dart داخل جذر المشروع.
- `youtube_player_iframe: 5.2.2` مثبت بالفعل طبقًا للـlog؛ لا حاجة لإعادة إضافته.
- `flutter analyze` قد يذكر info/warning غير مانعة. المهم ألا توجد `error`.
- لم أستطع تشغيل Xcode أو iPhone هنا؛ تم اختبار خطوات التصحيح على نسخة مشروع Movies الأصلية، ونسخة تمثيلية من الـPatch السابق فقط.
