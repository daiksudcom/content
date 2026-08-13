# Content

`content.daiksud.me` の resource API、versioned OpenAPI 契約、ブログ記事ソース、生成 asset、Deploy と Release の契約を定義するリポジトリです。

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
| `pnpm lint:commit` | Conventional Commits 形式のメッセージを検証する |
| `pnpm lint:staged` | staged ファイルを整形して lint する |
| `pnpm format` | 対象ファイルを整形する |
| `pnpm format:check` | 整形差分がないことを検証する |
| `pnpm policy:check` | package.json と OpenAPI の version 一致を検証する |
| `pnpm policy:test` | Deploy と version policy の unit test を実行する |
| `pnpm validate` | format、lint、policy、check、build をまとめて検証する |

## 品質ツールの責務

- Biome: JavaScript、TypeScript、JSON、CSS の format と lint
- Prettier: Astro、YAML の format
- rumdl: Markdown、MDX の format と lint
- ESLint: 型情報を使う TypeScript 検査と Astro 固有の lint
- Stylelint: CSS と Astro の style 検査
- Knip: 未使用 dependency、export、file の検査
- Commitlint: commit message と pull request title の Conventional Commits 検査
- Husky と lint-staged: commit 前の staged ファイルに限定した format と lint

## コミット時の検証

`pnpm install` の `prepare` script が Git hook を設定します。pre-commit hook は staged ファイルを種類ごとの formatter と linter へ渡し、整形結果を自動で再 stage します。repository 全体の検証は引き続き `pnpm validate` と CI が担当します。

commit message と pull request title は、scope を任意とする `type(scope): summary` 形式にしてください。たとえば `feat(api): add article endpoint` や `docs: explain local validation` を使用できます。commit-msg hook が各 commit を検証し、CI は pull request title、pull request 内の全 commit、`main` へ push された commit を検証します。fast-forward push では追加された範囲を検証し、直前の revision がない場合や non-fast-forward push では新しい HEAD から到達可能な全履歴を再検証します。履歴の取得や検証に失敗した場合は CI を失敗させます。GitHub 形式の two-parent pull request merge commit 本体だけは検証対象から除きます。

pull request の branch は `feat/<slug>`、`fix/<slug>`、`docs/<slug>` などのtype prefixを使用します。breaking changeは `breaking-change/{feat,perf,fix}/<slug>`、deprecationは `deprecated/{feat,perf,fix}/<slug>`、記事と同居mediaだけの更新は `content/<slug>` を使用します。Dependabot branchだけは例外です。branch名はlabel付けの補助であり、versionへの影響は決めません。

## Version、Deploy、Release

Contentは二つのlayerを同じWorkerから配信し、versioningの扱いを分けます。

- **delivery service layer**（API handler、OpenAPI契約、Worker実装）はSemVerを維持します。`package.json` と [`openapi/content.openapi.json`](openapi/content.openapi.json) の `info.version` は常に一致し、`pnpm policy:check` が検証します。初版は `0.1.0` で、Git tagだけに `v` prefixを付けます。OpenAPI majorごとに `/v1`、`/v2` を並行提供します。
- **content layer**（`blog/**` の記事MDXと記事media）は常に `main` を配信します。release制御を持たず、記事はDeployされた時点で公開されます。

feature flagはこのリポジトリで管理しません。flagの正本は[flags repository](https://github.com/daiksudme/flags)であり、Contentは他のconsumerと同じようにそれを参照します。

PRがmergeされるたびに単一のDeploy workflowが、version検証、tag作成、Worker Deploy、deployment receiptの記録を順に実行します。tag打ちとDeployを分離しないのは、`GITHUB_TOKEN` によるpushが新しいworkflow runを起動しないためです。必要なbumpはPRタイトルのconventional commit型から強制します。

| PRタイトル | 必須bump | 打たれるtag | GitHub Release |
| --- | --- | --- | --- |
| `feat:` / `perf:` | minor | `vX.Y.Z` | 作る |
| `fix:` / `revert:` | patch | `vX.Y.Z` | 作る |
| breaking change | major（`0.x` の間はminor） | `vX.Y.Z` | 作る |
| `docs:` `chore:` `ci:` `test:` `build:` `refactor:` `style:` | なし | `vX.Y.Z+YYYYMMDDHHmmss` | 作らない |

記事だけのPRは `docs(content): ...` です。他のリポジトリにおける `docs:` と完全に同じ扱いで、coreを変えずにDeployされ、build metadata tagを受け取ります。`+YYYYMMDDHHmmss` はmerge commitのcommitter時刻をUTC変換したものなので、再実行しても同じtagへ解決します。Deployの失敗はtagを削除も移動もしません。

現在はプロダクト実装前なので、repository variable `DEPLOY_ENABLED=true` を設定するまでDeployは安全にskipします。有効化にはWorker実装、production Wrangler設定、`production` Environment、Cloudflare credentialsが必要です。手順と必要な変数は [GitHub、Deploy、Release の運用](.github/README.md) を参照してください。

## 仕様書

- [文書の案内](docs/README.md)
- [振る舞い仕様](docs/features/README.md)
- [Architecture Decision Records](docs/adr/README.md)
- [GitHub、Deploy、Release の運用](.github/README.md)

## 関連リポジトリ

- [Home](https://github.com/daiksudme/home)
- [Blog](https://github.com/daiksudme/blog)
- [UI](https://github.com/daiksudme/ui)
- [Flags](https://github.com/daiksudme/flags)
