---
type: "Architecture Decision Record"
title: "ADR 0003: 記事 source 契約"
description: "記事を日付付きpathとstrict frontmatter schemaで管理し、mediaを記事と同じ階層から参照することを定める。"
resource: "https://github.com/daiksudcom/content/blob/main/docs/adr/0003-article-source-contract.md"
tags: [content, adr, architecture, article-source-contract]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-10T07:07:01Z
---

# ADR 0003: 記事 source 契約

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

記事の公開日、slug、metadata、media を source だけから決定し、誤った記事を build 前に拒否できる規約が必要である。

## 決定

記事を `blog/YYYY/MM/DD/article-name/index.mdx`、media を同階層の `media/` に置き、MDX から `./media/...` で参照する。公開日は path を Asia/Tokyo の暦日として導出する。article-name は lowercase ASCII kebab とする。frontmatter は `title`、`description`、`tags`（省略時 `[]`）、任意の `updatedAt`、`cover`、`coverAlt` からなる strict schema で検証し、未知 field と未来日の path を error にする。MDX の Astro component はすべて明示 import する。

## 検討した選択肢

- frontmatter の publish date を source of truth にする構成
- 一つの flat directory に記事を置く構成
- 日付 path と strict metadata schema を組み合わせる構成

## 結果

filesystem から公開順と記事 identity を再現できる。記事と media は移動・レビュー単位が一致し、schema error は該当 path と field を示す。

## 関連文書

- [記事オーサリング仕様](../features/article-authoring.feature)
- [記事メディア仕様](../features/article-media.feature)
