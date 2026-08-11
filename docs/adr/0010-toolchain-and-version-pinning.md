---
type: "Architecture Decision Record"
title: "ADR 0010: ツールチェーンとバージョン固定"
description: "ContentのNode.js、pnpm、Astro、Vite+、Wranglerとdependencyを厳密なversionへ固定することを定める。"
resource: "https://github.com/daiksudcom/content/blob/main/docs/adr/0010-toolchain-and-version-pinning.md"
tags: [content, adr, architecture, toolchain, version-pinning]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-11T21:36:04Z
---

# ADR 0010: ツールチェーンとバージョン固定

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

MDX compiler、Astro adapter、API schema、Worker deployment、client package を同じ source から再現可能に生成する必要がある。

## 決定

Node.js 24、pnpm 11、Astro 7、Vite+ を標準とする。Wrangler は `4.107.0` 以上から採用した一つのパッチ版、`@astrojs/cloudflare`、MDX toolchain、Zod を含む dependency も採用パッチ版をマニフェストと lockfile に正確に固定する。Worker と client runtime は Web 標準 API を基準とする。Content repository の変更だけを検証、build、release する workflow を持つ。

## 検討した選択肢

- version range による自動解決
- 四つの repository で一つの lockfile を共有する構成
- repository ごとに toolchain と lockfile を固定する構成

## 結果

Content の release は Home、Blog、UI の build を要求せず、consumer も Content の source build と切り離される。依存更新は明示的なレビュー対象になる。

## 関連文書

- [Content release 仕様](../features/content-release.feature)
- [Content package 仕様](../features/content-package.feature)
- [ADR 0002](0002-astro-cloudflare-content-service.md)
- [ADR 0007](0007-content-client-package.md)
