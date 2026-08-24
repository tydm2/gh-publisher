# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Español](./README.es.md) · [Français](./README.fr.md) · [العربية](./README.ar.md) · [বাংলা](./README.bn.md) · [Português](./README.pt.md) · [Русский](./README.ru.md) · [日本語](./README.ja.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)](./CHANGELOG.md)
[![100% AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**نشر الملفات إلى GitHub بدون git — موفّر للرموز، آمن للخصوصية، متعدد الوكلاء، متعدد اللغات.**

`gh-publisher` هي مهارة وكيل تنشر مجلدًا محليًا إلى مستودع GitHub باستخدام `gh` CLI + GitHub REST API (Contents / Git Database) — بدون الحاجة إلى git. تتعامل مع تهيئة المستودع الفارغ والالتزامات الدفعية عبر سكربت واحد قابل لإعادة الاستخدام، بحيث يدفع الوكلاء بأمر واحد بدلًا من إعادة اشتقاق تدفق API بالكامل. كما تنشر **10 من أكثر اللغات استخدامًا على GitHub** (ترجمات README) بينما تبقى النسخة المحلية بلغتك المفضلة.

## لماذا تتميز

- **🚀 دفع بدون git** — يعمل على أجهزة لا تحتوي على git؛ ويهيّئ المستودعات الفارغة تلقائيًا.
- **⚡ موفّر للرموز** — أمر واحد عبر `scripts/push.ps1` ينفّذ الفحص ← التهيئة ← الالتزام الدفعي ← إخراج محجوب (سطر واحد `PUSHED N files -> URL`)، بدلًا من عشرات استدعاءات API اليدوية.
- **🔒 الخصوصية وأمان الحساب** — تبقى الرموز فقط في keyring الخاص بـ `gh` (لا تظهر أبدًا في المحادثة/السجلات/الملفات)؛ تُفحص الملفات بحثًا عن الأسرار قبل الدفع (`github_pat_`, `ghp_`, `sk-`, المفاتيح الخاصة…)؛ ويكون الإخراج محجوبًا.
- **🔌 قابل للتكيف مع وكلاء متعددين** — يعمل سكربت `pwsh` على Windows/macOS/Linux؛ مع توثيق تعيينات DSH / Codex / Claude Code؛ ودون أسماء أدوات منصة مكتوبة بشكل ثابت.
- **🧩 تهيئة تلقائية للمستودع الفارغ** — يكتشف المستودعات الفارغة ويزرع أول ملف عبر Contents API قبل الالتزام الدفعي.
- **🌍 نشر متعدد اللغات** — تبقى النسخة المحلية بلغتك المختارة (الافتراضية: الصينية)؛ وتشحن الإصدارات ترجمات README لأكثر 10 لغات استخدامًا على GitHub (en, zh-CN, hi, es, fr, ar, bn, pt, ru, ja). راجع `references/i18n.md`.

## كيف تعمل

1. `pwsh -ExecutionPolicy Bypass -File scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "msg" [-GhPath <path-to-gh.exe>] [-Languages en,zh-CN,hi,es,fr,ar,bn,pt,ru,ja]`
2. يحدد موقع ملف `gh` الثنائي تلقائيًا (`-GhPath` ← PATH ← مسارات التثبيت الشائعة) ويكتشف `GH_CONFIG_DIR` تلقائيًا — دون تعديل يدوي لـ PATH أو الإعدادات.
3. فحص الأسرار ← إيقاف عند أي نمط مفتاح/رمز (ما لم يُمرَّر `-ForceSecret`).
4. كشف المستودع الفارغ عبر فحص مرجع الفرع (404 = فارغ) ← زرع أول ملف (Contents API) عند الحاجة.
5. الالتزام الدفعي لجميع الملفات (Git Database API: blobs ← tree ← commit ← ref).
6. طباعة `PUSHED N files -> https://github.com/owner/repo` — ولا شيء آخر. عند غياب المستودع ← طباعة تلميح `gh repo create`.
7. فحص `-Languages` اختياري: يتحقق من وجود كل ملف لغة (مثل `README.hi.md`) قبل الدفع ويحذّر إذا كان أي منها مفقودًا.

## النشر متعدد اللغات (اللغة المحلية + 10 لغات إصدار)

- **النسخة المحلية**: تبقى بلغتك المهيأة (zh أو en) — عبر `config.local.json` في مجلد المهارة المثبَّت (الافتراضي `zh`). قل *"change local default language to English"* للتبديل؛ ويُحدَّث ملف SKILL.md المحلي ليطابق ذلك.
- **الإصدار**: يبقى `SKILL.md` بالإنجليزية (اللغة الأساسية العامة على GitHub)، بينما يُنشر `README.<lang>.md` لأكثر 10 لغات استخدامًا. راجع `references/i18n.md` لقائمة اللغات وقواعد الترجمة وملاحظات عقد الاستدعاء (تحتفظ جميع نسخ اللغات بنفس `name`).

## الفحص الذاتي للبيئة (مرة واحدة قبل أول دفع)

- `Get-Command gh` (أو دع السكربت يكتشف مسارات التثبيت تلقائيًا)؛ إذا لم يوجد: `winget install GitHub.cli`.
- `gh auth status` يعرض حسابًا مسجل الدخول (الرمز محجوب على هيئة `github_pat_***…`).
- `gh api repos/{owner}/{repo}` أو `gh repo list` يعيد بيانات.

## التثبيت

```
~/.dsh/skills/gh-publisher/    # global
.dsh/skills/gh-publisher/      # per project
```

فعّلها بعبارات مثل *"push this to GitHub"*, *"publish this skill to a repo"* — أو عبر عنصر القائمة ⑤ في `/skill` الخاص بـ **set-skill**.

## التوثيق

- `references/security.md` — الخصوصية وأمان الحساب
- `references/platform-adapter.md` — تعيين DSH / Codex / Claude Code
- `references/i18n.md` — بروتوكول النشر متعدد اللغات (10 لغات)

## المهارات المصاحبة

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — تُدرج هذه المهارة كعنصر قائمة ⑤ في `/skill`.
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — انشر سير العمل متعدد الوكلاء الذي يولّده باستخدام هذه المهارة.

## المتطلبات

- `gh` CLI (سُجّل الدخول عبر `gh auth login`) + `pwsh` (PowerShell Core، متعدد المنصات).

## إخلاء المسؤولية

> **هذه المهارة مصنوعة بالكامل بواسطة الذكاء الاصطناعي.** المشاكل أمر لا مفر منه — نرحب بالنقاش وطلبات السحب (pull requests). يكرر المؤلف التطوير عليها بناءً على الاستخدام الفعلي.

## الترخيص

[MIT](./LICENSE)
