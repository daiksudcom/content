---
type: "Architecture Decision Record"
title: "ADR 0001: Content のリポジトリ境界"
description: "記事source、生成asset、API、Content version、client packageをContent repositoryで一体管理することを定める。"
resource: "https://github.com/daiksudme/content/blob/main/docs/adr/0001-repository-boundary.md"
tags: [content, adr, architecture, repository-boundary]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-13T00:35:00Z
---

# ADR 0001: Content のリポジトリ境界

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

記事 source、MDX build、生成 asset、resource API、型付き client、Content release は同じ schema と revision に基づく。一方、Home と Blog は独立した表示・デプロイ単位である。

## 決定

`content` リポジトリは `content.daiksud.me`、root の `blog/` source、生成 asset、Content version、`@daiksudme/content` client package を所有する。Home と Blog は API と package の公開契約だけに依存する。

## 検討した選択肢

- 記事を Blog リポジトリに置く構成
- API、記事、client package を別々のリポジトリに分ける構成
- schema と release を Content 境界で一体管理する構成

## 結果

一つの revision から API payload、asset、client schema を検証できる。Home と Blog は公開された client version を互いに独立して採用できる。

## 関連文書

- [記事オーサリング仕様](../features/article-authoring.feature)
- [記事メディア仕様](../features/article-media.feature)
- [Content package 仕様](../features/content-package.feature)
- [Content release 仕様](../features/content-release.feature)
- [Home](https://github.com/daiksudme/home)
- [Blog](https://github.com/daiksudme/blog)
