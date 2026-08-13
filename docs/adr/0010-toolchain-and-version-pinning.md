---
type: "Architecture Decision Record"
title: "ADR 0010: ツールチェーンとバージョン固定"
description: "ContentのNode.js、pnpm、Astro、品質ツールとdependencyを厳密なversionへ固定することを定める。"
resource: "https://github.com/daiksudme/content/blob/main/docs/adr/0010-toolchain-and-version-pinning.md"
tags: [content, adr, architecture, toolchain, version-pinning]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-13T00:35:00Z
---

# ADR 0010: ツールチェーンとバージョン固定

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

Content serviceとOpenAPI契約の実装を進める前に、開発者とCIが同じ結果を再現できる基盤を確立する必要がある。format、lint、型検査、buildの責務が重複すると、修正の競合や環境ごとの差異が発生する。依存更新も暗黙に取り込まず、変更内容をreview可能にする必要がある。

## 決定

Node.js は `24.16.0` 以上、pnpm は `11.0.0` 以上を標準とし、実行する pnpm を `11.21.0` に指定する。Astro は `7.2.0` とし、すべての直接 dependency を `package.json` に厳密な version で記録し、推移 dependency の解決結果を repository 固有の lockfile に固定する。将来導入する Wrangler は `4.107.0` 以上から採用した一つの patch version とし、`@astrojs/cloudflare`、MDX toolchain、Zod を含む実装 dependency も採用した exact version に固定する。

開発コマンドは pnpm script から Astro と各品質ツールを直接実行する。Biome は JavaScript、TypeScript、JSON、CSS、Prettier は Astro と YAML、rumdl は Markdown と MDX、ESLint は型情報を使う TypeScript と Astro の意味的検査、Stylelint は CSS と Astro、Knip は未使用 dependency、export、file を担当する。

CI は pull request と `main` への push で frozen install、format 検査、lint、Astro check、build を順に実行する。dependency と GitHub Actions の更新は Dependabot が週次で提案し、version 変更をレビュー対象にする。

## 検討した選択肢

- version range による自動解決
- 統合 tool runner を介して各コマンドを実行する構成
- 四つの repository で一つの lockfile を共有する構成
- repository ごとに toolchain と lockfile を固定する構成

## 結果

開発者と CI は同じ pnpm script と lockfile を使い、個々の品質ツールの担当範囲を判断できる。Content の検証は他 repository の build を要求せず、依存更新は manifest と lockfile の明示的な差分としてレビューされる。Astro application、Cloudflare adapter、deployment、release の設定は、対応する実装を追加するときにこの基盤へ組み込む。

## 関連文書

- [Content release 仕様](../features/content-release.feature)
- [OpenAPI 契約仕様](../features/content-openapi.feature)
- [ADR 0002](0002-astro-cloudflare-content-service.md)
- [ADR 0007](0007-content-client-package.md)
