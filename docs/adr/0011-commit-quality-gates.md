---
type: "Architecture Decision Record"
title: "ADR 0011: コミット品質ゲート"
description: "Contentのstagedファイル、commit message、pull request titleをlocal hookとCIで検証することを定める。"
resource: "https://github.com/daiksudcom/content/blob/main/docs/adr/0011-commit-quality-gates.md"
tags: [content, adr, architecture, git-hooks, conventional-commits]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-12T22:52:26Z
---

# ADR 0011: コミット品質ゲート

## ステータス

承認済み

## 日付

2026-08-13

## コンテキスト

repository 全体の format、lint、型検査、build は CI で再現できるが、commit 直前の短い feedback loop と、変更履歴を一貫して検索できる commit message 規約がない。local hook だけでは `--no-verify` や外部 automation からの変更を検証できず、pull request の squash merge で履歴に残る title も規約から外れる可能性がある。

## 決定

Commitlint と `@commitlint/config-conventional` を使用し、commit message と pull request title に Conventional Commits を適用する。独自の type や scope の制限は加えない。Husky の commit-msg hook で各 commit message を検証し、pre-commit hook では lint-staged を通じて staged ファイルだけを担当 formatter で整形してから linter で検証する。整形結果の再 stage は lint-staged に委ねる。

CI は pull request title と base から head までの全 commit をそれぞれ検証し、title の編集時にも再実行する。`main` への fast-forward push では直前の revision から新しい HEAD までの追加範囲を検証する。直前の revision が all-zero、解決不能、または新しい HEAD の ancestor でない場合は non-fast-forward push として扱い、新しい HEAD から到達可能な全履歴を再検証する。commit の列挙、message の取得、または commitlint に失敗した場合は fail closed とする。GitHub 形式の件名と two-parent topology を持つ pull request merge commit 本体だけは、検証済み title を含む merge metadata として除外する。Dependabot が作成する title と commit message には dependency 種別に応じた Conventional Commits の prefix を付ける。

## 検討した選択肢

- local hook だけで commit message を検証する構成
- CI だけで file と commit message を検証する構成
- pull request title だけを検証し、個々の commit は許容する構成
- staged file、個々の commit、pull request title を段階ごとに検証する構成

## 結果

開発者は commit 前に対象ファイルの format と lint の結果を受け取り、履歴と pull request title は同じ規約に揃う。pre-commit は高速性を保つため staged ファイルのみを対象とし、Knip、Astro check、build を含む repository 全体の検証は従来どおり CI と `pnpm validate` が担当する。hook は必要に応じて回避できるが、CI の再検証により共有前に規約外の履歴を検出できる。force push を含む non-fast-forward push は全履歴の検証コストを負う一方、書き換えられた過去の commit を検証対象から外さない。merge を強制的に阻止する場合は、この CI を repository ruleset の required check に設定する。

## 関連文書

- [ADR 0010](0010-toolchain-and-version-pinning.md)
