---
type: "Architecture Decision Record"
title: "ADR 0008: resource-scoped cache tag"
description: "cache tagをresource単位で命名し、Deploy時に変更resourceとversionのedge cacheを無効化することを定める。"
resource: "https://github.com/daiksudme/content/blob/main/docs/adr/0008-resource-scoped-cache-tags.md"
tags: [content, adr, architecture, resource-scoped-cache-tags]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-13T00:35:00Z
---

# ADR 0008: resource-scoped cache tag

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

Content APIはBlogから始まりresourceを追加できる。Deploy後は変更されたresourceに依存するAPI、Home、Blogのedge cacheだけを一貫して無効化する必要がある。

## 決定

現在値を指すcache aliasをresource単位の`content-{resource}-current`として定義し、複数resourceに依存するresponseは対応するaliasのunionを持つ。browser revalidationとedgeのstale-while-revalidate、stale-if-errorを分離し、cache keyはWorker versionまたはresource revisionが異なる場合に共有しない。Deployが本番Worker versionを切り替えた後、変更resourceとservice versionのaliasだけをinvalidationする。

## 検討した選択肢

- service 全体を一つの tag で purge する構成
- URL 単位で全 key を列挙する構成
- resource-scoped tag と複合 response の tag union

## 結果

resourceが増えてもpurge範囲を独立させられる。cache stateとdeployment invalidationは運用上観測可能になる。

## 関連文書

- [Content cache 仕様](../features/content-cache.feature)
- [Content release 仕様](../features/content-release.feature)
