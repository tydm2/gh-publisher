# gh-publisher feedback log (runtime memory)

> Maintained per the set-skill protocol: distilled requirements only, read fully on iterate/audit, max ~120 chars each; `#` prefix = hard constraint; duplicates update, not stack.

## Active requirements

(none)

## Consumed requirements

- [2026-08-24] object:gh-publisher | intent:iterate | essence:six friction points from real pushes (gh not on PATH, execution-policy block, size==0 false-empty on README-only repos, silent repo-missing failure, manual GH_CONFIG_DIR, swallowed API errors) | expectation:v1.1.0 auto-detects gh/config, documents -ExecutionPolicy Bypass, detects empty via git refs, hints gh repo create, surfaces API stderr; self-check section in SKILL/README | context:iteration driven by real usage (pushing office-studio/office-imagegen-skill) | priority:high [consumed by v1.1.0]
