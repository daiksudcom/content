# language: ja
@content @api @manifest @version @health
機能: Content の route、version、稼働状態を取得する
  consumer と運用者として
  配信中の resource と revision を識別するために
  manifest、version、health endpoint を利用したい

  シナリオ: Blog manifest を取得する
    もしclient が GET "/v1/blog/manifest" を要求する
    ならばHTTP ステータス 200 を受け取る
    かつ応答は次の内容を持つ
      | field            | value                  |
      | apiVersion       | v1                     |
      | resource         | blog                   |
      | contentVersion   | vYYYY.MM.DD[+build]    |
      | gitSha           |    40文字の commit SHA |
      | resourceRevision | blog resource revision |
      | routes.articles  | slug の集合            |
      | routes.tags      | tag の集合             |
      | rendererVersion  | renderer version       |
    かつcache tag は "content-blog-current" である

  シナリオ: 配信 version を取得する
    もしclient が GET "/v1/version" を要求する
    ならば応答は apiVersion、contentVersion、gitSha、resourceRevisions を持つ
    かつcache tag は "content-version-current" である
    かつETag は配信 version revision から決定される

  シナリオ: health check を取得する
    もしmonitor が GET "/healthz" を要求する
    ならばHTTP ステータス 200 を受け取る
    かつ応答は `{"status":"ok"}` を含む
    かつ応答は現在の contentVersion と gitSha を含む
    かつCache-Control は "no-store" である

  シナリオ: API の crawler header を確認する
    もしcrawler が GET "/v1/version" を要求する
    ならば応答は "X-Robots-Tag: noindex" を持つ

  シナリオ: robots 方針を取得する
    もしcrawler が GET "/robots.txt" を要求する
    ならば"/v1/" は crawl 対象外として記述される
    かつ"/_astro/" は asset 取得可能として記述される
