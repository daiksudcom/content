---
type: "Architecture Decision Record"
title: "ADR 0005: MDX から trusted HTML への変換"
description: "Content buildでMDXとAstro componentをtrusted HTML fragmentへ変換してAPI配信することを定める。"
resource: "https://github.com/daiksudcom/content/blob/main/docs/adr/0005-mdx-to-trusted-html.md"
tags: [content, adr, architecture, mdx, trusted-html]
timestamp: 2026-08-10T06:56:15Z
---

# ADR 0005: MDX から trusted HTML への変換

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

Home と Blog の SSR が記事ごとに MDX compiler と UI component graph を持つと、描画差と依存の結合が生じる。記事 HTML は Content revision として一度検証される必要がある。

## 決定

Content build で MDX と明示 import された Astro component を静的 HTML fragment へコンパイルする。API は `format: "trusted-html"`、`html`、`styles`、`rendererVersion` を返す。同じ build で heading TOC、日本語読了時間、公開順に基づく前後記事を生成する。trusted の境界は repository review、strict source validation、固定 UI package、build pipeline とする。

## 検討した選択肢

- API が raw MDX を返し consumer がコンパイルする構成
- portable AST を API 契約にする構成
- Content build が trusted HTML を所有する構成

## 結果

Home と Blog は同じ renderer output を SSR できる。renderer の変更は rendererVersion と resourceRevision を更新し、Content release と cache purge の対象になる。

## 関連文書

- [Blog 記事 API 仕様](../features/blog-article-api.feature)
- [UI MDX component 仕様](https://github.com/daiksudcom/ui/blob/main/docs/features/mdx-component.feature)
