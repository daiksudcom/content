# language: ja
@content @package @api
機能: 型付き Content client から resource API を利用する
  Home と Blog の開発者として
  通信経路にかかわらず同じ検証済み schema を扱うために
  `@daiksudcom/content` client を利用したい

  背景:
    前提consumer は GitHub Packages の厳密な SemVer の "@daiksudcom/content" を導入している

  シナリオ: HTTPS transport で client を作る
    前提HTTPS transport の base URL が "https://content.daiksud.com" である
    もし`createContentClient({ transport })` を呼び出す
    ならば次の operation を利用できる
      | operation                 | result type    |
      | client.blog.list(options) | BlogPage       |
      | client.blog.get(slug)     | BlogArticle    |
      | client.blog.manifest()    | BlogManifest   |
      | client.version()          | ContentVersion |

  シナリオ: Service Binding transport で client を作る
    前提transport は Cloudflare Service Binding の Fetcher を持つ
    もし`createContentClient({ transport })` を呼び出す
    ならばBlog operation は Fetcher を通じて Content Worker を要求する
    かつpublic HTTPS transport と同じ return type と problem contract を返す

  シナリオ: 公開 type を利用する
    もしTypeScript consumer が package の型を import する
    ならば`BlogArticleSummary`、`BlogArticle`、`BlogPage`、`ContentVersion` を利用できる

  シナリオ: API 応答を検証する
    前提Content API の応答が期待 schema と一致しない
    もしclient が Zod schema で応答を parse する
    ならばoperation は resource、endpoint、validation issue を持つ typed error を返す

  シナリオ: problem response を受け取る
    前提Content API が "application/problem+json" を返す
    もしclient operation が応答を処理する
    ならばtype、title、status、detail、instance を保持する Content problem を返す

  シナリオ: Home と Blog が異なる package version を利用する
    前提Home は "@daiksudcom/content@1.2.0" を指定している
    かつBlog は "@daiksudcom/content@1.3.1" を指定している
    もしBlog だけが依存を更新する
    ならばHome の解決 version は "1.2.0" のままである
