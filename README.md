# Content

`content.daiksud.com` の resource API、ブログ記事ソースと生成 asset、Content release、および GitHub Packages の `@daiksudcom/content` client 契約を定義するリポジトリです。

## 現在の状態

プロダクト実装開始前の基準として、観測可能な振る舞いを Gherkin、技術的な決定を Architecture Decision Records（ADR）で確定しています。Astro 開発用の共通ツールチェーンと CI は利用できます。

## 開発環境

- Node.js 24.16.0 以上
- pnpm 11.0.0 以上（このリポジトリでは pnpm 11.21.0 を指定）

```sh
corepack enable
pnpm install --frozen-lockfile
```

直接依存は `package.json` で厳密に固定し、推移依存を含む解決結果は `pnpm-lock.yaml` で管理します。

## コマンド

| コマンド | 用途 |
| --- | --- |
| `pnpm dev` | Astro の開発サーバーを起動する |
| `pnpm build` | production build を生成する |
| `pnpm preview` | production build をローカルで確認する |
| `pnpm check` | Astro と TypeScript の診断を実行する |
| `pnpm lint` | 全 linter と未使用コード検査を実行する |
| `pnpm format` | 対象ファイルを整形する |
| `pnpm format:check` | 整形差分がないことを検証する |
| `pnpm validate` | format、lint、check、build をまとめて検証する |

## 品質ツールの責務

- Biome: JavaScript、TypeScript、JSON、CSS の format と lint
- Prettier: Astro、YAML の format
- rumdl: Markdown、MDX の format と lint
- ESLint: 型情報を使う TypeScript 検査と Astro 固有の lint
- Stylelint: CSS と Astro の style 検査
- Knip: 未使用 dependency、export、file の検査

## 仕様書

- [文書の案内](docs/README.md)
- [振る舞い仕様](docs/features/README.md)
- [Architecture Decision Records](docs/adr/README.md)

## 関連リポジトリ

- [Home](https://github.com/daiksudcom/home)
- [Blog](https://github.com/daiksudcom/blog)
- [UI](https://github.com/daiksudcom/ui)
