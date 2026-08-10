---
type: "Documentation Index"
title: "文書"
description: "Content source、API、client package、cache、releaseに関する振る舞い仕様と設計判断への入口を提供する。"
resource: "https://github.com/daiksudcom/content/blob/main/docs/README.md"
tags: [content, documentation, index]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-10T07:12:38Z
---

# 文書

このディレクトリは Content source、API、client package、cache、release の受け入れ基準と技術判断を管理します。

- [振る舞い仕様](features/README.md): 著者、API consumer、運用者から観測できる契約を、キーワードを英語、シナリオ本文を日本語とする Gherkin で定義します。
- [Architecture Decision Records](adr/README.md): 実装と運用を拘束する設計判断を記録します。

API は `blog` を最初の resource とし、同じ `/v1/{resource}` 階層へ resource を追加できる契約を持ちます。
