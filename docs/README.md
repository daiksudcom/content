---
type: "Documentation Index"
title: "文書"
description: "Content source、OpenAPI、cache、Deploy、Releaseに関する振る舞い仕様と設計判断への入口を提供する。"
resource: "https://github.com/daiksudme/content/blob/main/docs/README.md"
tags: [content, documentation, index]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-13T00:35:00Z
---

# 文書

このディレクトリはContent source、API、OpenAPI contract、cache、Deploy、Releaseの受け入れ基準と技術判断を管理します。

## 文書の責務

- [振る舞い仕様](features/README.md)は、現在有効な観測可能かつ検証可能な契約の正本です。path、schema、route、header、status、数値、error、release 手順を Gherkin で定義します。
- [Architecture Decision Records](adr/README.md)は、設計判断の context、理由、選択肢、trade-off、結果を記録します。具体的な契約を繰り返さず、対応する振る舞い仕様を参照します。

観測可能な契約について両者の記述が異なる場合は、振る舞い仕様を現在の仕様として扱います。
