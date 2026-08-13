---
type: "Architecture Decision Record"
title: "ADR 0007: OpenAPIを正本とするContent API契約"
description: "独立したclient packageを廃止し、SemVerでversioningしたOpenAPI documentを公開契約の正本にする。"
resource: "https://github.com/daiksudme/content/blob/main/docs/adr/0007-content-client-package.md"
tags: [content, adr, architecture, openapi]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-13T04:12:33Z
---

# ADR 0007: OpenAPIを正本とするContent API契約

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

HomeとBlogは、HTTPSとCloudflare Service Bindingという異なるtransportを使用しても、同じAPI schema、problem response、version契約を利用する必要がある。独立した`@daiksudme/content` packageを公開すると、API、package、consumer adoptionの三つのversionを同期する運用が増える。

## 決定

`openapi/content.openapi.json`をContentの公開HTTP契約の正本とし、`info.version`をrepositoryのSemVer coreと一致させる。独立したContent client packageは公開しない。HomeとBlogはOpenAPIからconsumerを生成するか、同じdocumentに適合するFetch-compatible consumerを実装し、runtime responseをconsumer境界で検証する。

OpenAPIの互換性はCIで直前のcore契約と比較する。breaking changeはmajor、後方互換なoperation・schema追加とdeprecationはminor、契約上のbug fixはpatchを要求する。description、summary、title、exampleだけの変更はcoreを変更しない。

## 検討した選択肢

- GitHub Packagesへ独立versionのtyped clientを公開する構成
- consumerごとに契約なしのfetch wrapperを書く構成
- SemVer OpenAPIを共有し、consumer lifecycleを各repositoryが所有する構成

## 結果

API contractとrepository versionが一つになり、package publicationは不要になる。consumerは採用時期を独立して選べる一方、code generation、transport adapter、runtime validationを各repositoryで管理する。

## 関連文書

- [OpenAPI契約仕様](../features/content-openapi.feature)
- [resource API namespace](0004-resource-api-namespace.md)
- [HomeのContent access ADR](https://github.com/daiksudme/home/blob/main/docs/adr/0003-content-api-access.md)
- [BlogのContent access ADR](https://github.com/daiksudme/blog/blob/main/docs/adr/0003-content-api-access.md)
