---
type: "Architecture Decision Record"
title: "ADR 0006: 生成 asset の配信"
description: "mediaをcontent hash付きassetへ変換し、Content Workerからimmutable cacheと絶対URLで配信することを定める。"
resource: "https://github.com/daiksudme/content/blob/main/docs/adr/0006-generated-asset-hosting.md"
tags: [content, adr, architecture, generated-asset-hosting]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-13T00:35:00Z
---

# ADR 0006: 生成 asset の配信

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

記事 media と component CSS は MDX build の結果に依存し、trusted HTML fragment から安定して取得できる URL と長期 cache を必要とする。

## 決定

Content build は media を最適化した content-addressed asset として生成し、Content service 自身が immutable cache を使って配信する。API の fragment は利用環境から到達可能な絶対 asset URL を返す。現在の asset path、cache header、origin 変換、crawler 契約は関連する振る舞い仕様を正本とする。

## 検討した選択肢

- source file path のまま配信する構成
- Blog Worker が asset を複製する構成
- Content Worker が hash asset と絶対 URL を所有する構成

## 結果

同じ content address の内容は不変になり、長期 edge/browser cache が安全になる。public HTTPS、Service Binding、preview の各環境で fragment は到達可能な asset URL を返す。

## 関連文書

- [記事メディア仕様](../features/article-media.feature)
- [Content API 共通 protocol 仕様](../features/content-api-protocol.feature)
- [manifest、version、health 仕様](../features/manifest-version-health.feature)
- [ADR 0005](0005-mdx-to-trusted-html.md)
