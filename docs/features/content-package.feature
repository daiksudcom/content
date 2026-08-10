@content @package @api
Feature: 型付き Content client から resource API を利用する
  Home と Blog の開発者として
  通信経路にかかわらず同じ検証済み schema を扱うために
  `@daiksudcom/content` client を利用したい

  Background:
    Given consumer は GitHub Packages の厳密な SemVer の "@daiksudcom/content" を導入している

  Scenario: HTTPS transport で client を作る
    Given HTTPS transport の base URL が "https://content.daiksud.com" である
    When `createContentClient({ transport })` を呼び出す
    Then 次の operation を利用できる
      | operation                 | result type    |
      | client.blog.list(options) | BlogPage       |
      | client.blog.get(slug)     | BlogArticle    |
      | client.blog.manifest()    | BlogManifest   |
      | client.version()          | ContentVersion |

  Scenario: Service Binding transport で client を作る
    Given transport は Cloudflare Service Binding の Fetcher を持つ
    When `createContentClient({ transport })` を呼び出す
    Then Blog operation は Fetcher を通じて Content Worker を要求する
    And public HTTPS transport と同じ return type と problem contract を返す

  Scenario: 公開 type を利用する
    When TypeScript consumer が package の型を import する
    Then `BlogArticleSummary`、`BlogArticle`、`BlogPage`、`ContentVersion` を利用できる

  Scenario: API 応答を検証する
    Given Content API の応答が期待 schema と一致しない
    When client が Zod schema で応答を parse する
    Then operation は resource、endpoint、validation issue を持つ typed error を返す

  Scenario: problem response を受け取る
    Given Content API が "application/problem+json" を返す
    When client operation が応答を処理する
    Then type、title、status、detail、instance を保持する Content problem を返す

  Scenario: Home と Blog が異なる package version を利用する
    Given Home は "@daiksudcom/content@1.2.0" を指定している
    And Blog は "@daiksudcom/content@1.3.1" を指定している
    When Blog だけが依存を更新する
    Then Home の解決 version は "1.2.0" のままである
