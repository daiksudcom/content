---
type: "Architecture Decision Record"
title: "ADR 0009: Content version と release"
description: "Contentを暦日tagでversioningし、検証、deploy、rollback、cache purgeを直列workflowで管理することを定める。"
resource: "https://github.com/daiksudcom/content/blob/main/docs/adr/0009-content-versioning-and-release.md"
tags: [content, adr, architecture, content-versioning, release]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-10T07:07:01Z
---

# ADR 0009: Content version と release

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

配信内容は source commit、Worker version、API metadata、resource revision、git tag、cache purge を一つの release identity で追跡できる必要がある。同日に複数回の release も発生する。

## 決定

Content release tag を Asia/Tokyo の日付に基づく `vYYYY.MM.DD[+build]` とし、`^v\d{4}\.\d{2}\.\d{2}(?:\+[1-9]\d*)?$` で検証する。同日最初は `v2026.08.10`、次は `v2026.08.10+1`、続いて `+2` と増やす。workflow を concurrency lock で直列化し、既存 tag から candidate を求める。version、SHA、resource revision を埋め込み、検証、Wrangler version upload、preview smoke、production promote、production smoke、annotated tag push、resource cache purge の順で実行する。production smoke または tag push の失敗時は直前の Worker version へ戻す。version tag の更新と削除は GitHub ruleset で保護する。

## 検討した選択肢

- SemVer を記事 release に使う方式
- commit SHA だけを公開 identity にする方式
- 暦日 version と同日 build suffix を使う方式

## 結果

人が読める release 日と同日の順序を保ちながら、payload から正確な SHA と resource revision を追跡できる。`@daiksudcom/content` package の SemVer は client 契約の release identity として独立して維持される。

## 関連文書

- [Content release 仕様](../features/content-release.feature)
- [manifest、version、health 仕様](../features/manifest-version-health.feature)
