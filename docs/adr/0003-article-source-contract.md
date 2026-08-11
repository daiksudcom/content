---
type: "Architecture Decision Record"
title: "ADR 0003: 記事 source 契約"
description: "記事を日付付きpathとstrict frontmatter schemaで管理し、mediaを記事と同じ階層から参照することを定める。"
resource: "https://github.com/daiksudcom/content/blob/main/docs/adr/0003-article-source-contract.md"
tags: [content, adr, architecture, article-source-contract]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-11T21:36:04Z
---

# ADR 0003: 記事 source 契約

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

記事の公開日、slug、metadata、media を source だけから決定し、誤った記事を build 前に拒否できる規約が必要である。

## 決定

日付階層を持つ記事単位の source directory を採用し、公開日と記事 identity を path から導出する。media は記事と同居させ、metadata は公開前に strict schema で検証し、MDX component は明示された依存だけを解決する。現在の path、命名、schema、validation 規則は関連する振る舞い仕様を正本とする。

## 検討した選択肢

- frontmatter の publish date を source of truth にする構成
- 一つの flat directory に記事を置く構成
- 日付 path と strict metadata schema を組み合わせる構成

## 結果

filesystem から公開順と記事 identity を再現できる。記事と media は移動・レビュー単位が一致し、source 単位の diagnostic が可能になる。

## 関連文書

- [記事オーサリング仕様](../features/article-authoring.feature)
- [記事メディア仕様](../features/article-media.feature)
- [slug とタグ仕様](../features/slug-and-tag.feature)
