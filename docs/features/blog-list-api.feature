# language: ja
@content @api @blog
機能: Blog 記事一覧を API で取得する
  API consumer として
  公開記事を安定した順序でページ取得するために
  `/v1/blog` の typed resource response を利用したい

  背景:
    前提public Content API の origin は "https://content.daiksud.com" である
    かつ記事一覧は公開日時の降順、同日時では slug の昇順で安定している

  シナリオ: 最初の12件を取得する
    前提公開済み記事が20件ある
    もしclient が次を要求する
      | method | GET      |
      | path   | /v1/blog |
    ならばHTTP ステータス 200 を受け取る
    かつ応答は次の resource envelope を満たす
      """
      {
        "apiVersion": "v1",
        "resource": "blog",
        "contentVersion": "v2026.08.10",
        "gitSha": "<40-character-sha>",
        "resourceRevision": "<blog-revision>",
        "page": {
          "items": ["<12 BlogArticleSummary values>"],
          "nextCursor": "<opaque-cursor>"
        }
      }
      """
    かつ応答は "Access-Control-Allow-Origin: *" を持つ

  シナリオ: cursor で続きを取得する
    前提最初の応答が opaque cursor "next-token" を返している
    もしclient が "/v1/blog?limit=12&cursor=next-token" を要求する
    ならば前の page と重複しない次の項目を最大12件受け取る
    かつ終端では nextCursor は null である

  シナリオ: tag で絞り込む
    前提"astro" tag の公開済み記事がある
    もしclient が "/v1/blog?limit=12&tag=astro" を要求する
    ならばpage.items の全記事が "astro" tag を持つ
    かつnextCursor は tag filter を保持する opaque value である

  シナリオアウトライン: limit を適用する
    もしclient が "/v1/blog?limit=<limit>" を要求する
    ならばHTTP ステータスは <status> である
    かつ成功時の最大 items 数は <count> である

    例:
      | limit | status | count |
      |     1 |    200 |     1 |
      |    12 |    200 |    12 |
      |   100 |    200 |   100 |
      |     0 |    400 |     0 |
      |   101 |    400 |     0 |

  シナリオ: limit を省略する
    もしclient が "/v1/blog" を要求する
    ならばpage.items は最大12件である

  シナリオ: ETag で一覧を再検証する
    前提同じ query の応答 ETag が "\"blog-list-revision\"" である
    もしclient が `If-None-Match: "blog-list-revision"` を付けて要求する
    ならばresourceRevision と query が同じ場合は HTTP ステータス 304 である
    かつ応答 body は空である

  シナリオ: HEAD で metadata を取得する
    もしclient が HEAD で "/v1/blog?limit=12" を要求する
    ならばGET と同じ status、cache、ETag、CORS header を受け取る
    かつ応答 body は空である

  シナリオ: CORS preflight を取得する
    もしclient が OPTIONS で "/v1/blog" を要求する
    ならばGET、HEAD、OPTIONS を許可する CORS header を受け取る
    かつ"Access-Control-Allow-Origin: *" を受け取る

  シナリオ: 無効な cursor を拒否する
    もしclient が "/v1/blog?cursor=invalid" を要求する
    ならばHTTP ステータス 400 を受け取る
    かつContent-Type は "application/problem+json" である
    かつ応答は次の problem fields を持つ
      | field    | value                                               |
      | type     | https://content.daiksud.com/problems/invalid-cursor |
      | title    | Invalid cursor                                      |
      | status   |                                                 400 |
      | detail   | cursor is invalid for the requested blog collection |
      | instance | /v1/blog?cursor=invalid                             |

  シナリオ: 許可外 method を拒否する
    もしclient が POST で "/v1/blog" を要求する
    ならばHTTP ステータス 405 の problem response を受け取る
    かつAllow header は "GET, HEAD, OPTIONS" である
