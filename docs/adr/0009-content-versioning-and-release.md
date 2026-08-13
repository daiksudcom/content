---
type: "Architecture Decision Record"
title: "ADR 0009: Contentの二層versioningとDeploy"
description: "delivery service layerだけをSemVerでversioningし、記事layerは常にmainを配信して、mergeごとのDeployでtagを確定する。"
resource: "https://github.com/daiksudme/content/blob/main/docs/adr/0009-content-versioning-and-release.md"
tags: [content, adr, architecture, versioning, deployment, release]
status: stable
generated:
  by: "codex/gpt-5.6-sol"
  at: 2026-08-13T04:12:33Z
---

# ADR 0009: Contentの二層versioningとDeploy

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

Contentは稼働code、OpenAPI契約、記事と生成assetを同じWorkerから配信する。しかしこの二つは性質が異なる。API handlerとOpenAPI契約はconsumerとの公開契約であり互換性を表現する必要がある一方、記事は公開契約ではなく、著者が書いた時点の`main`が唯一の正しい状態である。

当初は記事revisionを外部のactive manifestで隔離し、記事だけの更新にも独自のrelease制御を与えていた。これはContentだけが他のrepositoryと異なるrelease手順を持つ原因になり、記事公開を二段階操作にして、実体のないpackage script契約を残した。CalVerではAPI compatibilityを表現できず、client packageとの独立versionも廃止された。

## 決定

Contentを二つのlayerに分け、versioningの扱いを分離する。

**delivery service layer**（API handler、OpenAPI契約、Worker実装）はSemVerを維持する。`package.json#version`をSemVer coreの正本とし、OpenAPI `info.version`を同じ`X.Y.Z`へ一致させる。初版は`0.1.0`、`v`はGit tagだけのprefix、`0.x`中のbreaking changeはminorとし、安定宣言で`1.0.0`へ進む。feature flagはこのrepositoryで管理せず、flags repositoryを正本として他のconsumerと同じ方法で参照する。

**content layer**（`blog/**`の記事MDXと記事media）は常に`main`を配信する。release制御を一切持たず、manifestによる公開gatingも行わない。記事はDeployされた時点で公開される。

PRがmergeされるたびに必ずDeployする。version bumpはPRタイトルのconventional commit型から強制する。squash mergeによりタイトルがcommit件名として履歴に残るためである。`feat:`と`perf:`はminor、`fix:`と`revert:`はpatch、breaking changeはmajor（`0.x`ではminor）、`docs:` `chore:` `ci:` `test:` `build:` `refactor:` `style:`はversionを変更してはならない。

記事だけのPRは`docs(content): ...`とする。SemVer coreを変えず、それでもDeployされ、他のrepositoryにおける`docs:`と完全に同じ`vX.Y.Z+YYYYMMDDHHmmss` tagを受け取る。**これはContent固有の規則ではない。**

`+YYYYMMDDHHmmss`はmerge commitのcommitter時刻をUTCへ変換したものとする。実行時刻ではなくcommitの属性であるため、再実行しても同じtagへ解決する。build metadata tagはGitHub Releaseを作らない。

tag打ちとDeployは単一のworkflowに置く。`GITHUB_TOKEN`によるpushは新しいworkflow runを起動せず、分離するとPATが必要になるためである。Deployのリトライは外部要因（5xx、429、タイムアウト、接続リセット、DNS解決失敗）に限り最大3回とし、内部要因（build失敗、test失敗、401/403、429以外の4xx）は即座に失敗させる。リトライはtagを打ち直さない。Deployの失敗はtagを削除も移動もしない。

不変条件は「最新tag == 本番バージョン」であり、`drift-check.mjs`が検証する。最新tagはSemVer precedenceとcommit topologyで判定し、**辞書順では判定しない。**

## 検討した選択肢

- APIと記事の両方にCalVerを使う方式
- API SemVerと記事CalVerを別々のcore versionとして持つ方式
- 記事revisionを外部のmanifest flagで隔離し、manual Release workflowで公開する方式
- 記事だけのDeployにContent固有のtag規則（同一UTC秒では最新のみtag）を与える方式
- delivery service layerだけをSemVerでversioningし、記事は常にmainを配信する方式

## 結果

API consumerはSemVerとURL majorからcompatibilityを判断でき、記事著者はPRをmergeするだけで記事を公開できる。Contentのrelease手順は他のrepositoryと同一になり、記事専用のsmokeとcache purge契約は不要になった。機能の公開制御はflags repositoryへ移り、Contentはflagのconsumerに徹する。

build metadata同士にはSemVer上の順序がないため、toolingはGit tagの辞書順比較をdeployment順序の正本にしてはならない。

## 関連文書

- [Content deliveryとDeploy仕様](../features/content-release.feature)
- [OpenAPI契約仕様](../features/content-openapi.feature)
- [manifest、version、health仕様](../features/manifest-version-health.feature)
- [GitHub、Deploy、Release の運用](../../.github/README.md)
