@content @blog @media @asset
Feature: 記事のメディアを生成 asset として配信する
  記事著者と API consumer として
  source では記事の近くに asset を置き、配信時は不変 URL を利用するために
  相対参照を最適化済み絶対 URL へ変換したい

  Rule: source media は記事ディレクトリ内に置く

    Scenario: 記事から画像を参照する
      Given 記事が "blog/2026/08/10/cloudflare-isr/index.mdx" にある
      And 画像が "blog/2026/08/10/cloudflare-isr/media/diagram.png" にある
      When MDX が画像を "./media/diagram.png" として参照する
      Then Content build はその画像を記事の source asset として解決して成功する

  Rule: build は配信 asset を content-addressed URL にする

    Scenario: 画像を最適化する
      Given 有効な source 画像が記事から参照されている
      When production Content build を実行する
      Then 最適化済み asset は "/_astro/<hash>.<ext>" に生成される
      And asset 応答は "Cache-Control: public, max-age=31536000, immutable" を持つ

    Scenario: public API 応答の asset URL を絶対化する
      Given trusted HTML fragment に "/_astro/abc123.webp" がある
      When "https://content.daiksud.me/v1/blog/cloudflare-isr" が要求される
      Then fragment の URL は "https://content.daiksud.me/_astro/abc123.webp" になる

    Scenario: Service Binding 応答の asset URL を絶対化する
      Given Blog Worker が Service Binding request の URL を "https://content.daiksud.me/v1/blog/cloudflare-isr" にする
      When Content Worker が記事を返す
      Then fragment の asset URL は "https://content.daiksud.me" origin を使う

    Scenario: preview 応答の asset URL を絶対化する
      Given preview request の origin が "https://content-preview.example.workers.dev" である
      When Content Worker が記事を返す
      Then fragment の asset URL は "https://content-preview.example.workers.dev" origin を使う
