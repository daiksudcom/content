---
type: "Architecture Decision Record"
title: "ADR 0008: resource-scoped cache tag"
description: "cache tagをresource単位で命名し、release時に変更resourceとversionのedge cacheを無効化することを定める。"
resource: "https://github.com/daiksudcom/content/blob/main/docs/adr/0008-resource-scoped-cache-tags.md"
tags: [content, adr, architecture, resource-scoped-cache-tags]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-11T21:36:04Z
---

# ADR 0008: resource-scoped cache tag

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

Content API は Blog から始まり resource を追加できる。release 後は変更された resource に依存する API、Home、Blog の edge cache だけを一貫して無効化する必要がある。

## 決定

現在値を指す cache alias を resource 単位の `content-{resource}-current` として定義し、複数 resource に依存する response は対応する alias の union を持つ。browser revalidation と edge の stale-while-revalidate、stale-if-error を分離し、cache key は Worker version 間で共有しない。release は変更 resource と service version に対応する alias だけを invalidation する。現在の tag 名、TTL、header、cache state、purge 契約は関連する振る舞い仕様を正本とする。

## 検討した選択肢

- service 全体を一つの tag で purge する構成
- URL 単位で全 key を列挙する構成
- resource-scoped tag と複合 response の tag union

## 結果

resource が増えても purge 範囲を独立させられる。cache state と release invalidation は運用上観測可能になる。

## 関連文書

- [Content cache 仕様](../features/content-cache.feature)
- [Content release 仕様](../features/content-release.feature)
