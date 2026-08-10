# language: ja
@content @blog @media @asset
機能: 記事のメディアを生成 asset として配信する
  記事著者と API consumer として
  source では記事の近くに asset を置き、配信時は不変 URL を利用するために
  相対参照を最適化済み絶対 URL へ変換したい

  ルール: source media は記事ディレクトリ内に置く

    シナリオ: 記事から画像を参照する
      前提記事が "blog/2026/08/10/cloudflare-isr/index.mdx" にある
      かつ画像が "blog/2026/08/10/cloudflare-isr/media/diagram.png" にある
      もしMDX が画像を "./media/diagram.png" として参照する
      ならばContent build はその画像を記事の source asset として解決する

  ルール: build は配信 asset を content-addressed URL にする

    シナリオ: 画像を最適化する
      前提有効な source 画像が記事から参照されている
      もしproduction Content build を実行する
      ならば最適化済み asset は "/_astro/<hash>.<ext>" に生成される
      かつasset 応答は "Cache-Control: public, max-age=31536000, immutable" を持つ

    シナリオ: public API 応答の asset URL を絶対化する
      前提trusted HTML fragment に "/_astro/abc123.webp" がある
      もし"https://content.daiksud.com/v1/blog/cloudflare-isr" が要求される
      ならばfragment の URL は "https://content.daiksud.com/_astro/abc123.webp" になる

    シナリオ: Service Binding 応答の asset URL を絶対化する
      前提Blog Worker が Service Binding request の URL を "https://content.daiksud.com/v1/blog/cloudflare-isr" にする
      もしContent Worker が記事を返す
      ならばfragment の asset URL は "https://content.daiksud.com" origin を使う

    シナリオ: preview 応答の asset URL を絶対化する
      前提preview request の origin が "https://content-preview.example.workers.dev" である
      もしContent Worker が記事を返す
      ならばfragment の asset URL は "https://content-preview.example.workers.dev" origin を使う
