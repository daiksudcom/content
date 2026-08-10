---
type: "Architecture Decision Record"
title: "ADR 0004: resource API namespace"
description: "Content APIをresource単位のv1階層へ配置し、将来のresourceを同じnamespaceへ追加することを定める。"
resource: "https://github.com/daiksudcom/content/blob/main/docs/adr/0004-resource-api-namespace.md"
tags: [content, adr, architecture, resource-api-namespace]
timestamp: 2026-08-10T06:56:15Z
---

# ADR 0004: resource API namespace

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

初期 API は Blog 記事を配信するが、将来は projects など別の Content resource を同じ origin と client から配信する可能性がある。

## 決定

API を `/v1/{resource}` の sibling namespace とする。最初の resource は `/v1/blog`、`/v1/blog/{slug}`、`/v1/blog/manifest` である。service metadata は `/v1/version`、稼働確認は `/healthz` とする。将来の resource は `/v1/projects` と `client.projects` のように同階層へ追加する。初期の内部 module、schema、query、error は Blog resource に特化させる。public read method は GET、HEAD、OPTIONS、CORS は `Access-Control-Allow-Origin: *`、error media type は `application/problem+json` とする。

## 検討した選択肢

- Blog 専用 origin と root endpoint
- 最初から任意 resource を扱う generic gateway
- 安定した resource namespace と resource 固有 module

## 結果

URL と client の拡張位置が明確になる。Blog 実装には不要な抽象化を持ち込まず、将来 resource は独自 schema と revision を追加できる。

## 関連文書

- [Blog 一覧 API 仕様](../features/blog-list-api.feature)
- [manifest、version、health 仕様](../features/manifest-version-health.feature)
