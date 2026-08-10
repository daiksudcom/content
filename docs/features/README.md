---
type: "Gherkin Specification Index"
title: "振る舞い仕様"
description: "記事作成、media、Blog API、client package、cache、releaseのGherkin仕様への索引である。"
resource: "https://github.com/daiksudcom/content/blob/main/docs/features/README.md"
tags: [content, gherkin, specification, index]
timestamp: 2026-08-10T06:56:15Z
---

# 振る舞い仕様

- [記事オーサリング](article-authoring.feature)
- [記事メディア](article-media.feature)
- [slug とタグ](slug-and-tag.feature)
- [Blog 一覧 API](blog-list-api.feature)
- [Blog 記事 API](blog-article-api.feature)
- [manifest、version、health](manifest-version-health.feature)
- [Content client package](content-package.feature)
- [Content cache](content-cache.feature)
- [Content release](content-release.feature)

各ファイルは一つの観測可能な能力を扱い、`@content` と resource・運用別タグで分類します。API シナリオでは要求と応答をデータテーブルまたは doc string で具体化します。
