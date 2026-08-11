---
type: "Architecture Decision Record"
title: "ADR 0009: Content version と release"
description: "Contentを暦日tagでversioningし、検証、deploy、rollback、cache purgeを直列workflowで管理することを定める。"
resource: "https://github.com/daiksudcom/content/blob/main/docs/adr/0009-content-versioning-and-release.md"
tags: [content, adr, architecture, content-versioning, release]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-11T21:36:04Z
---

# ADR 0009: Content version と release

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

配信内容は source commit、Worker version、API metadata、resource revision、git tag、cache purge を一つの release identity で追跡できる必要がある。同日に複数回の release も発生する。

## 決定

Content は Asia/Tokyo の暦日に基づく release identity と、同日 release を順序付ける単調な suffix を採用する。GitHub Actions concurrency で release workflow を直列化し、source SHA、Worker version、resource revision、保護された annotated tag を一つの identity として追跡する。preview と production の段階的な検証、失敗時の rollback、成功後の targeted cache invalidation を一つの rollout として扱い、公開済み tag の変更と削除は GitHub ruleset で防ぐ。現在の version 形式、release 手順、failure handling、tag protection は関連する振る舞い仕様を正本とする。

## 検討した選択肢

- SemVer を記事 release に使う方式
- commit SHA だけを公開 identity にする方式
- 暦日 version と同日 build suffix を使う方式

## 結果

人が読める release 日と同日の順序を保ちながら、payload から正確な SHA と resource revision を追跡できる。`@daiksudcom/content` package の SemVer は client 契約の release identity として独立して維持される。

## 関連文書

- [Content release 仕様](../features/content-release.feature)
- [manifest、version、health 仕様](../features/manifest-version-health.feature)
