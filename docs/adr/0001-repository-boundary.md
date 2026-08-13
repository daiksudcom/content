---
type: "Architecture Decision Record"
title: "ADR 0001: Content のリポジトリ境界"
description: "記事source、生成asset、API、OpenAPI契約、Content versionをContent repositoryで一体管理することを定める。"
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

記事 source、MDX build、生成 asset、resource API、OpenAPI契約、Content versionは同じschemaとrevisionに基づく。一方、HomeとBlogは独立した表示・デプロイ単位である。

## 決定

`content` リポジトリは `content.daiksud.me`、rootの`blog/` source、生成asset、Content version、versioned OpenAPI documentを所有する。HomeとBlogは公開API契約からconsumerを生成または実装し、HTTPSとService Bindingのどちらでも同じHTTP契約を検証する。Content client packageは公開しない。

## 検討した選択肢

- 記事を Blog リポジトリに置く構成
- API、記事、OpenAPI契約を別々のリポジトリに分ける構成
- schema と release を Content 境界で一体管理する構成

## 結果

一つのrevisionからAPI payload、asset、OpenAPI契約を検証できる。HomeとBlogはAPI majorを独立した時期に採用できる。

## 関連文書

- [記事オーサリング仕様](../features/article-authoring.feature)
- [記事メディア仕様](../features/article-media.feature)
- [OpenAPI 契約仕様](../features/content-openapi.feature)
- [Content release 仕様](../features/content-release.feature)
- [Home](https://github.com/daiksudme/home)
- [Blog](https://github.com/daiksudme/blog)
