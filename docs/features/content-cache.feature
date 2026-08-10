# language: ja
@content @cache @isr @cloudflare
機能: resource 単位で Content 応答をキャッシュする
  運用者として
  resource を独立して更新しながら edge 応答を高速化するために
  resource-scoped cache tag を使いたい

  背景:
    前提production Worker で cache.enabled が true である
    かつbrowser TTL は0秒、edge TTLは300秒、SWRは3600秒、stale-if-errorは86400秒である

  シナリオアウトライン: endpoint に cache tag を付ける
    もし"<response>" を生成する
    ならばCache-Tag は "<tag>" を含む

    例:
      | response        | tag                      |
      | Blog 一覧       | content-blog-current     |
      | Blog 記事       | content-blog-current     |
      | Blog manifest   | content-blog-current     |
      | version         | content-version-current  |
      | 将来の projects | content-projects-current |

  シナリオ: 複数 resource から応答を生成する
    前提応答が blog と projects の revision に依存する
    もしcache metadata を生成する
    ならばCache-Tag は "content-blog-current" と "content-projects-current" を含む

  シナリオ: cache miss を生成する
    前提Worker version 固有 cache key に応答がない
    もしAPI を要求する
    ならばWorker が resource response を生成して保存する
    かつCF-Cache-Status で MISS を観測できる

  シナリオ: cache hit を返す
    前提Worker version 固有 cache key に有効な応答がある
    もし同じ endpoint と query を要求する
    ならばCloudflare は Worker 処理を迂回して応答する
    かつCF-Cache-Status で HIT を観測できる

  シナリオ: stale response を更新する
    前提edge TTLを過ぎSWR期間内の応答がある
    もしAPI を要求する
    ならばstale response を直ちに返す
    かつbackground で現在 resource revision の response を保存する

  シナリオ: 更新障害時に stale response を返す
    前提86400秒以内の stale response がある
    かつbackground の再生成が失敗する
    もしAPI を要求する
    ならば利用可能な stale response を返す

  シナリオ: Blog release の cache を purge する
    前提新しい blog resource revision が production に昇格した
    もしrelease workflow が "content-blog-current" を purge する
    ならば次の Blog 要求は新しい revision から response を生成する
    かつversion endpoint の更新では "content-version-current" も purge される
