---
type: "Architecture Decision Record"
title: "ADR 0007: Content client package"
description: "交換可能なtransportとZod検証を備える型付きContent clientをGitHub Packagesで公開することを定める。"
resource: "https://github.com/daiksudcom/content/blob/main/docs/adr/0007-content-client-package.md"
tags: [content, adr, architecture, content-client-package]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-11T21:36:04Z
---

# ADR 0007: Content client package

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

Home と Blog は transport が異なっても同じ API schema、型、problem response、validation を使用する必要がある。

## 決定

GitHub Packages に independently versioned な typed Content client package を公開する。Fetch-compatible transport を注入できる resource client とし、HTTPS と Cloudflare Service Binding を同じ interface で扱う。全 response は Zod schema で runtime validation する。現在の package 名、operation、public type、typed error は関連する振る舞い仕様を正本とする。

## 検討した選択肢

- consumer ごとの fetch wrapper
- OpenAPI から毎回 client を生成する構成
- 手書きの resource client と交換可能な transport

## 結果

runtime response と TypeScript type のずれを consumer 境界で検出できる。Home と Blog は厳密な package version を別々に選択し、互換性を個別に検証できる。

## 関連文書

- [Content package 仕様](../features/content-package.feature)
- [Home の Content access ADR](https://github.com/daiksudcom/home/blob/main/docs/adr/0003-content-api-access.md)
- [Blog の Content access ADR](https://github.com/daiksudcom/blog/blob/main/docs/adr/0003-content-api-access.md)
