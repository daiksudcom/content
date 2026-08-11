---
type: "Architecture Decision Record"
title: "ADR 0002: Astro と Cloudflare による Content service"
description: "Astro 7とCloudflare WorkerでContent serviceを構成し、Service BindingとHTTPSを共通Fetch契約で扱うことを定める。"
resource: "https://github.com/daiksudcom/content/blob/main/docs/adr/0002-astro-cloudflare-content-service.md"
tags: [content, adr, architecture, astro, cloudflare, content-service]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-11T21:36:04Z
---

# ADR 0002: Astro と Cloudflare による Content service

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

Content は build-time MDX pipeline、HTTP resource API、Cloudflare Service Binding、生成 asset 配信を一つの deployable service として扱う必要がある。

## 決定

Astro 7、`@astrojs/cloudflare`、`output: server` を採用し、`content.daiksud.com` の Cloudflare Worker としてデプロイする。API handler と transport は Fetch、Request、Response、URL、Streams などの Web 標準 API を契約にする。Home と Blog からの本番要求は Service Binding、preview と外部 client は HTTPS を使う。

## 検討した選択肢

- 静的 object storage と別 API service
- 汎用 Node.js server
- Astro Cloudflare adapter による単一 Worker service

## 結果

Astro build が生成した asset と API を同じ version で公開できる。Service Binding と HTTPS は同じ fetch interface に収束する。

## 関連文書

- [Blog 記事 API 仕様](../features/blog-article-api.feature)
- [記事メディア仕様](../features/article-media.feature)
- [Content package 仕様](../features/content-package.feature)
- [ADR 0006](0006-generated-asset-hosting.md)
