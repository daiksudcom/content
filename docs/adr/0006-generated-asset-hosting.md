# ADR 0006: 生成 asset の配信

## ステータス

承認済み

## 日付

2026-08-10

## コンテキスト

記事 media と component CSS は MDX build の結果に依存し、trusted HTML fragment から安定して取得できる URL と長期 cache を必要とする。

## 決定

Content build が media を最適化して content hash を付け、Content Worker が `/_astro/<hash>.*` から配信する。asset は `Cache-Control: public, max-age=31536000, immutable` を持つ。API は fragment 内の asset path を request origin の絶対 URL に変換する。本番 Service Binding request は `https://content.daiksud.com`、preview request は preview origin を URL authority とする。`/robots.txt` は `/v1/` を crawl 対象外、`/_astro/` を取得可能として示し、API 応答は `X-Robots-Tag: noindex` を持つ。

## 検討した選択肢

- source file path のまま配信する構成
- Blog Worker が asset を複製する構成
- Content Worker が hash asset と絶対 URL を所有する構成

## 結果

同じ hash URL の内容は不変になり、長期 edge/browser cache が安全になる。public HTTPS、Service Binding、preview の各環境で fragment は到達可能な asset URL を返す。

## 関連文書

- [記事メディア仕様](../features/article-media.feature)
- [ADR 0005](0005-mdx-to-trusted-html.md)
