# ADR 0007: Content client package

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

Home と Blog は transport が異なっても同じ API schema、型、problem response、validation を使用する必要がある。

## 決定

GitHub Packages に `@daiksudcom/content` を SemVer で公開する。入口は `createContentClient({ transport })` とし、`client.blog.list(options)`、`client.blog.get(slug)`、`client.blog.manifest()`、`client.version()` を提供する。`BlogArticleSummary`、`BlogArticle`、`BlogPage`、`ContentVersion` を public type とする。HTTPS transport と Cloudflare Service Binding transport を実装し、全 response を Zod schema で検証する。

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
