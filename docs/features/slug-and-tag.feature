@content @blog @routing @validation
Feature: 記事 slug とタグ route を一意に決定する
  記事著者として
  恒久的な Blog URL を衝突なく公開するために
  article-name と tag を一つの検証済み namespace で管理したい

  Rule: 公開名は lowercase ASCII kebab である

    Scenario Outline: 公開名を検証する
      Given 公開名が "<name>" である
      When Content build が route 名を検証する
      Then validation 結果は "<result>" である

      Examples:
        | name           | result |
        | cloudflare-isr | 成功   |
        | Cloudflare-ISR | 失敗   |
        | cloudflare_isr | 失敗   |
        | 日本語         | 失敗   |

    Scenario: 最初の記事へ基本 slug を割り当てる
      Given "blog/2026/08/10/astro-cache/index.mdx" が最古の同名記事である
      When Content build が公開 route を生成する
      Then 記事 URL は "https://blog.daiksud.com/astro-cache/" である

    Scenario: 後の記事の article-name が衝突する
      Given 2026-08-10 の "astro-cache" が基本 slug を保持している
      And "blog/2026/09/12/astro-cache/index.mdx" がある
      When Content build が公開 route を生成する
      Then 後の記事 URL は "https://blog.daiksud.com/astro-cache-20260912/" である

    Scenario: tag route を生成する
      Given 公開済み記事に tag "cloudflare" がある
      When Content build が公開 route を生成する
      Then tag URL は "https://blog.daiksud.com/cloudflare/" である

    Scenario Outline: 共有 namespace の衝突を拒否する
      Given "<name>" が "<existing>" として予約されている
      When "<candidate>" に同じ名前を使用する
      Then Content build の route validation は衝突元を示して失敗する

      Examples:
        | name        | existing     | candidate |
        | cloudflare  | 記事 slug    | tag       |
        | rss.xml     | system route | tag       |
        | sitemap.xml | system route | 記事 slug |
