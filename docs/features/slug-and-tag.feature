# language: ja
@content @blog @routing @validation
機能: 記事 slug とタグ route を一意に決定する
  記事著者として
  恒久的な Blog URL を衝突なく公開するために
  article-name と tag を一つの検証済み namespace で管理したい

  ルール: 公開名は lowercase ASCII kebab である

    シナリオアウトライン: 公開名を検証する
      前提公開名が "<name>" である
      もしContent build が route 名を検証する
      ならばvalidation 結果は "<result>" である

      例:
        | name           | result |
        | cloudflare-isr | 成功   |
        | Cloudflare-ISR | 失敗   |
        | cloudflare_isr | 失敗   |
        | 日本語         | 失敗   |

    シナリオ: 最初の記事へ基本 slug を割り当てる
      前提"blog/2026/08/10/astro-cache/index.mdx" が最古の同名記事である
      もしroute manifest を生成する
      ならば記事 URL は "https://blog.daiksud.com/astro-cache/" である

    シナリオ: 後の記事の article-name が衝突する
      前提2026-08-10 の "astro-cache" が基本 slug を保持している
      かつ"blog/2026/09/12/astro-cache/index.mdx" がある
      もしroute manifest を生成する
      ならば後の記事 URL は "https://blog.daiksud.com/astro-cache-20260912/" である

    シナリオ: tag route を生成する
      前提公開済み記事に tag "cloudflare" がある
      もしroute manifest を生成する
      ならばtag URL は "https://blog.daiksud.com/cloudflare/" である

    シナリオアウトライン: 共有 namespace の衝突を拒否する
      前提"<name>" が "<existing>" として予約されている
      もし"<candidate>" に同じ名前を使用する
      ならばroute manifest の validation は衝突元を示して失敗する

      例:
        | name        | existing     | candidate |
        | cloudflare  | 記事 slug    | tag       |
        | rss.xml     | system route | tag       |
        | sitemap.xml | system route | 記事 slug |
