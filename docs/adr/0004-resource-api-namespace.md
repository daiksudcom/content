---
type: "Architecture Decision Record"
title: "ADR 0004: resource API namespace"
description: "Content APIをresource単位のv1階層へ配置し、将来のresourceを同じnamespaceへ追加することを定める。"
resource: "https://github.com/daiksudme/content/blob/main/docs/adr/0004-resource-api-namespace.md"
tags: [content, adr, architecture, resource-api-namespace]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-13T00:35:00Z
---

# ADR 0004: resource API namespace

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

初期 API は Blog 記事を配信するが、将来は projects など別の Content resource を同じ origin と client から配信する可能性がある。

## 決定

API は `/v1/{resource}` の sibling namespace とし、resource ごとに module、schema、query、error を所有する。service 全体の metadata と稼働確認は resource collection から分離する。将来の resource は既存 resource と同じ階層へ独立して追加し、最初から任意 resource を扱う generic gateway は導入しない。現在の route と HTTP 契約は関連する振る舞い仕様を正本とする。

## 検討した選択肢

- Blog 専用 origin と root endpoint
- 最初から任意 resource を扱う generic gateway
- 安定した resource namespace と resource 固有 module

## 結果

URL と client の拡張位置が明確になる。Blog 実装には不要な抽象化を持ち込まず、将来 resource は独自 schema と revision を追加できる。

## 関連文書

- [Blog 一覧 API 仕様](../features/blog-list-api.feature)
- [Blog 記事 API 仕様](../features/blog-article-api.feature)
- [Content API 共通 protocol 仕様](../features/content-api-protocol.feature)
- [manifest、version、health 仕様](../features/manifest-version-health.feature)
