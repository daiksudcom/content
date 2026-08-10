---
type: "Architecture Decision Record"
title: "ADR 0008: resource-scoped cache tag"
description: "cache tagをresource単位で命名し、release時に変更resourceとversionのedge cacheを無効化することを定める。"
resource: "https://github.com/daiksudcom/content/blob/main/docs/adr/0008-resource-scoped-cache-tags.md"
tags: [content, adr, architecture, resource-scoped-cache-tags]
timestamp: 2026-08-10T06:56:15Z
---

# ADR 0008: resource-scoped cache tag

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

Content API は Blog から始まり resource を追加できる。release 後は変更された resource に依存する API、Home、Blog の edge cache だけを一貫して無効化する必要がある。

## 決定

現在値を指す tag を `content-{resource}-current` と命名する。Blog は `content-blog-current`、service version は `content-version-current` とする。将来の projects は `content-projects-current` を使う。複数 resource に依存する response は対応する全 tag を持つ。production では `cache.enabled=true` とし、ブラウザーへ `Cache-Control: public, max-age=0`、Cloudflare へ `Cloudflare-CDN-Cache-Control: public, max-age=300, stale-while-revalidate=3600, stale-if-error=86400` を返す。cache key は Worker version 固有とし、release が変更 resource と version の tag を purge する。

## 検討した選択肢

- service 全体を一つの tag で purge する構成
- URL 単位で全 key を列挙する構成
- resource-scoped tag と複合 response の tag union

## 結果

resource が増えても purge 範囲を独立させられる。MISS、HIT、SWR、stale-if-error は `CF-Cache-Status` と release log で観測できる。

## 関連文書

- [Content cache 仕様](../features/content-cache.feature)
- [Content release 仕様](../features/content-release.feature)
