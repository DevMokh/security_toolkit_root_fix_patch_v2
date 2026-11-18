إصلاح خطأ Expected to find project root in current working directory

سبب الخطأ: flutter pub get كان يعمل في مجلد لا يحتوي pubspec.yaml.
هذه الحزمة تجعل GitHub Actions يحدد مجلد Flutter تلقائياً، حتى لو كان المشروع داخل مجلد فرعي، ثم تمرر مسار المشروع صراحةً إلى سكربت إصلاح Android.

طريقة الاستخدام:
1. فك ضغط الحزمة.
2. انسخ مجلد .github ومجلد scripts إلى جذر مستودع GitHub (نفس مستوى مجلد التطبيق، وليس داخله).
3. وافق على استبدال .github/workflows/build.yml إذا سأل IDE.
4. احفظ وارفع الملفات وشغّل Actions.
5. راقب الخطوات: Locate Flutter project root ثم Regenerate Android host with V2 embedding ثم Verify Android V2 embedding ثم Get dependencies.

لا تحذف pubspec.yaml أو lib. الحزمة لا تحتوي على كود التطبيق؛ هي إصلاح للـworkflow والـbootstrap فقط.
