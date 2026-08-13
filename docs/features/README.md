---
type: "Gherkin Specification Index"
title: "振る舞い仕様"
description: "記事作成、media、Blog API、client package、cache、releaseのGherkin仕様への索引である。"
resource: "https://github.com/daiksudme/content/blob/main/docs/features/README.md"
tags: [content, gherkin, specification, index]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-13T00:35:00Z
---

# 振る舞い仕様

各ファイルでは Gherkin キーワードを英語、シナリオ本文を日本語で記述します。

振る舞い仕様は現在の観測可能かつ検証可能な契約の正本です。設計判断の理由、選択肢、trade-off は関連する ADR を参照します。

- [記事オーサリング](article-authoring.feature)
- [記事メディア](article-media.feature)
- [slug とタグ](slug-and-tag.feature)
- [Blog 一覧 API](blog-list-api.feature)
- [Blog 記事 API](blog-article-api.feature)
- [Content API 共通 protocol](content-api-protocol.feature)
- [manifest、version、health](manifest-version-health.feature)
- [Content client package](content-package.feature)
- [Content cache](content-cache.feature)
- [Content release](content-release.feature)

各ファイルは一つの観測可能な能力を扱い、`@content` と resource・運用別タグで分類します。API シナリオでは要求と応答をデータテーブルまたは doc string で具体化します。
