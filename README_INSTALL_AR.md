# Movies – Navigation & Movie Details Icon Precision Patch (UI ONLY)

هذا التصحيح مخصص لاختلاف شكل الأيقونات وارتفاع الـBottom Navigation، وليس تحديثًا للمشروع كاملًا.

## التغييرات

- `home.svg`, `search.svg`, `browse.svg`, `profile.svg`: رسومات SVG ناعمة بدلاً من مسارات تتبّع بكسلات متكسّرة.
- `back.svg`: سهم شيفرون `‹` بدون الخط الأفقي الزائد، قريب من شكل التصميم.
- `bookmark.svg`: علامة حفظ ممتلئة بحواف ناعمة، وفق مرجع Movie Details.
- `lib/features/navigation/presentation/screens/app_shell.dart`: رفع قيود المساحة في الهيكل القديم إن وُجد، وخفض الـNavigation ليظهر قرب أسفل الشاشة، مع الحفاظ على عرض التبويبات ووظائفها.

**ملاحظة دقة:** هذه مسارات Vector أعيد رسمها من لقطات Figma والصور المصدّرة، وليست صادرات SVG أصلية من طبقات Figma لأن الوصول للطبقات غير متاح. تحافظ على وضوحها مهما تغيّر حجم الشاشة، لكن قد تبقى فروق طفيفة عن متجهات التصميم الأصلية.

## التركيب

1. احفظ نسخة احتياطية من مشروعك.
2. احفظ `Movies_Navigation_Icons_Precision_Patch.zip` في مجلد Downloads.
3. افتح Terminal في المجلد الرئيسي `movies_flutter_complete` (حيث يوجد pubspec.yaml).
4. نفّذ:

```bash
unzip -o ~/Downloads/Movies_Navigation_Icons_Precision_Patch.zip -d .
python3 scripts/apply_precise_nav_patch.py --dry-run
python3 scripts/apply_precise_nav_patch.py
```

التصحيح يأخذ نسخة احتياطية تلقائية قبل تعديل الملفات في `.movies_ui_backups/nav_icons_...`.

5. أوقف تطبيق Flutter ثم أعد تشغيله تشغيلًا كاملًا. **Hot Reload وحده قد لا يُظهر تحديث الـassets بشكل موثوق.**

```bash
flutter pub get
flutter run -d 00008140-00063DA92252801C
```

إذا فشل `dry-run`، لا تتابع أمر التطبيق. أرسل ناتج الخطأ فقط؛ البرنامج مصمم ليتوقف بدل استبدال ملفاتك الحديثة بشكل خاطئ.

## ما لم يتغير

Firebase Auth، Firestore، YTS API، Cubits، قواعد التخزين، ميزة تشغيل التريلر، Podfile، Apple Signing، و `firebase_options.dart`. **كود Movie Details نفسه لا يُستبدل**؛ التغيير هو محتوى أيقونات `back.svg` و`bookmark.svg` التي يقرأها بالفعل.

## التحقق على iPhone

- Home: أيقونات ناعمة غير مبكسلة، شريط التنقل أسفل أقرب للتصميم، جميع الأزرار قابلة للضغط.
- Search/Browse/Profile: انتقل بين التبويبات وتأكد أن آخر محتوى غير مخفي خلف البار.
- Movie Details: سهم رجوع بدون الخط الأفقي، وBookmark ممتلئ قابل للحفظ/الإزالة.

مُختبر نصيًا على إصدارات كود سابقة فقط؛ **لم يتم تشغيل Flutter/Xcode على هاتف فعلي في بيئة إعداد التحديث**.
