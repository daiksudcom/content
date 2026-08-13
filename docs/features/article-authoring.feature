@content @blog @authoring @mdx
Feature: 規約に従ってブログ記事を作成する
  記事著者として
  `blog/YYYY/MM/DD/article-name/index.mdx` から公開日と slug を再現可能に導出するために
  厳格な MDX 契約で記事を書きたい

  Background:
    Given Content の日付判定 timezone は "Asia/Tokyo" である

  Rule: 記事は日付と article-name を持つディレクトリへ置く

    Scenario: 有効な記事を検証する
      Given 記事が "blog/2026/08/10/cloudflare-isr/index.mdx" にある
      And frontmatter は次の内容である
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
      When Content build が記事を検証する
      Then 公開日は "2026-08-10" として path から導出される
      And article-name は "cloudflare-isr" である
      And 記事は公開候補に含まれる

    Scenario: tags を省略する
      Given 有効な記事の frontmatter に tags がない
      When Content build が記事を読み込む
      Then tags は空の配列になる

    Scenario: 記事で Astro コンポーネントを使う
      Given MDX 冒頭に次の import がある
        """
        import { Callout } from '@daiksudme/ui/components/Callout';
        """
      When 本文が Callout を使用する
      Then Content build は明示された public export を解決する

  Rule: source schema に一致する記事だけを公開候補にする

    Scenario Outline: 無効な記事を拒否する
      Given 記事に "<condition>" がある
      When Content build が記事を検証する
      Then validation は失敗する
      And error は対象の path と "<field>" を示す

      Examples:
        | condition                           | field       |
        | title がない                        | title       |
        | description がない                  | description |
        | 定義されていない frontmatter がある | frontmatter |
        | path の日付が publishDate と異なる  | publishDate |
        | cover があり coverAlt がない        | coverAlt    |
        | updatedAt が公開日より前である      | updatedAt   |

    Scenario: 未来日付の記事をstagingする
      Given pathの日付とpublishDateが一致する未来の記事がある
      When Content buildが記事を検証する
      Then validationは成功する
      And 公開日を迎えるまでpublic routeの一覧と記事から除外される
