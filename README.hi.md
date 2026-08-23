# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Português](./README.pt.md) · [Español](./README.es.md) · [日本語](./README.ja.md) · [Deutsch](./README.de.md) · [Français](./README.fr.md) · [Русский](./README.ru.md) · [한국어](./README.ko.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](./CHANGELOG.md)
[![100%25 AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**बिना git के GitHub पर फ़ाइलें प्रकाशित करें — token-कुशल, गोपनीयता-सुरक्षित, multi-agent।**

`gh-publisher` एक agent skill है जो `gh` CLI + GitHub REST API (Contents / Git Database) का उपयोग करके किसी स्थानीय निर्देशिका को GitHub repository में प्रकाशित करता है — git की आवश्यकता नहीं। यह एक पुन: प्रयोज्य script के साथ empty-repo initialization और batch commits को संभालता है, ताकि agents पूरे API flow को फिर से बनाने के बजाय एक ही command में push कर सकें।

## यह ख़ास क्यों है

- **🚀 Git-free push** — बिना git वाली मशीनों पर काम करता है; empty repositories को स्वचालित रूप से initialize करता है।
- **⚡ Token-efficient** — एक `scripts/push.ps1` command scan → init → batch commit → masked output (सिर्फ़ एक `PUSHED N files -> URL` पंक्ति) करता है, दर्जनों हाथ से बनाए गए API calls के बजाय।
- **🔒 गोपनीयता और account सुरक्षा** — tokens केवल `gh` keyring में रहते हैं (chat/logs/files में कभी नहीं); push से पहले files की secret scan होती है (`github_pat_`, `ghp_`, `sk-`, private keys…); output masked होता है।
- **🔌 Multi-agent अनुकूलनीय** — `pwsh` script Windows/macOS/Linux पर चलता है; DSH / Codex / Claude Code mappings दस्तावेज़ित हैं; कोई hardcoded platform tool names नहीं।
- **🧩 Auto empty-repo init** — empty repos का पता लगाता है और batch commit से पहले Contents API के ज़रिए पहली file डाल देता है।

## यह कैसे काम करता है

1. `pwsh scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "…"`
2. Secret scan → किसी भी key/token pattern पर रुक जाना (जब तक `-ForceSecret` न हो)।
3. empty repo का पता लगाएं → ज़रूरत हो तो पहली file डालें (Contents API)।
4. सभी files का batch commit करें (Git Database API: blobs → tree → commit → ref)।
5. `PUSHED N files -> https://github.com/owner/repo` प्रिंट करें — और कुछ नहीं।

## इंस्टॉल

```
~/.dsh/skills/gh-publisher/    # global
.dsh/skills/gh-publisher/      # per project
```

इसे *"push this to GitHub"*, *"publish this skill to a repo"* जैसे वाक्यांशों से ट्रिगर करें — या **set-skill** के `/skill` menu item ⑤ से।

## दस्तावेज़

- `references/security.md` — गोपनीयता और account सुरक्षा
- `references/platform-adapter.md` — DSH / Codex / Claude Code mapping

## सहयोगी skills

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — इस skill को `/skill` menu item ⑤ के रूप में सूचीबद्ध करता है।
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — इसके द्वारा बनाए गए multi-agent workflows को इसी से प्रकाशित करें।

## आवश्यकताएँ

- `gh` CLI (`gh auth login` से logged in) + `pwsh` (PowerShell Core, cross-platform)।

## अस्वीकरण

> **यह skill 100% AI-निर्मित है।** Issues अपरिहार्य हैं — discussion और pull requests का स्वागत है। लेखक वास्तविक उपयोग के आधार पर इस पर लगातार सुधार करते हैं।

## लाइसेंस

[MIT](./LICENSE)
