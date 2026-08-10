# language: ja
@content @blog @authoring @mdx
機能: 規約に従ってブログ記事を作成する
  記事著者として
  source path から公開日と slug を再現可能に導出するために
  厳格な MDX 契約で記事を書きたい

  背景:
    前提Content の日付判定 timezone は "Asia/Tokyo" である

  ルール: 記事は日付と article-name を持つディレクトリへ置く

    シナリオ: 有効な記事を検証する
      前提記事が "blog/2026/08/10/cloudflare-isr/index.mdx" にある
      かつfrontmatter は次の内容である
        """
        title: Cloudflare で ISR を構成する
        description: Workers Caching を使った再生成の設計
        tags:
          - astro
          - cloudflare
        updatedAt: 2026-08-10T12:30:00+09:00
        cover: ./media/cover.webp
        coverAlt: Cloudflare edge cache の概念図
        """
      もしContent build が記事を検証する
      ならば公開日は "2026-08-10" として path から導出される
      かつarticle-name は "cloudflare-isr" である
      かつfrontmatter と本文が build input に含まれる

    シナリオ: tags を省略する
      前提有効な記事の frontmatter に tags がない
      もしContent build が記事を読み込む
      ならばtags は空の配列になる

    シナリオ: 記事で Astro コンポーネントを使う
      前提MDX 冒頭に次の import がある
        """
        import { Callout } from '@daiksudcom/ui/components/Callout';
        """
      もし本文が Callout を使用する
      ならばContent build は明示された public export を解決する

  ルール: source schema に一致する記事だけを公開候補にする

    シナリオアウトライン: 無効な記事を拒否する
      前提記事に "<condition>" がある
      もしContent build が記事を検証する
      ならばvalidation は失敗する
      かつerror は対象の path と "<field>" を示す

      例:
        | condition                           | field       |
        | title がない                        | title       |
        | description がない                  | description |
        | 定義されていない frontmatter がある | frontmatter |
        | path の日付が未来である             | publishDate |
        | cover があり coverAlt がない        | coverAlt    |
        | updatedAt が公開日より前である      | updatedAt   |
