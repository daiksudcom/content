@content @api @blog
Feature: Blog 記事一覧を API で取得する
  API consumer として
  公開記事を安定した順序でページ取得するために
  `/v1/blog` の typed resource response を利用したい

  Background:
    Given public Content API の origin は "https://content.daiksud.com" である
    And 記事一覧は公開日時の降順、同日時では slug の昇順で安定している

  Scenario: 最初の12件を取得する
    Given 公開済み記事が20件ある
    When client が次を要求する
      | method | GET      |
      | path   | /v1/blog |
    Then HTTP ステータス 200 を受け取る
    And 応答は次の resource envelope を満たす
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
    And 応答は "Access-Control-Allow-Origin: *" を持つ

  Scenario: cursor で続きを取得する
    Given 最初の応答が opaque cursor "next-token" を返している
    When client が "/v1/blog?limit=12&cursor=next-token" を要求する
    Then 前の page と重複しない次の項目を最大12件受け取る
    And 終端では nextCursor は null である

  Scenario: tag で絞り込む
    Given "astro" tag の公開済み記事がある
    When client が "/v1/blog?limit=12&tag=astro" を要求する
    Then page.items の全記事が "astro" tag を持つ
    And nextCursor は tag filter を保持する opaque value である

  Scenario Outline: limit を適用する
    When client が "/v1/blog?limit=<limit>" を要求する
    Then HTTP ステータスは <status> である
    And 成功時の最大 items 数は <count> である

    Examples:
      | limit | status | count |
      |     1 |    200 |     1 |
      |    12 |    200 |    12 |
      |   100 |    200 |   100 |
      |     0 |    400 |     0 |
      |   101 |    400 |     0 |

  Scenario: limit を省略する
    When client が "/v1/blog" を要求する
    Then page.items は最大12件である

  Scenario: ETag で一覧を再検証する
    Given 同じ query の応答 ETag が "\"blog-list-revision\"" である
    When client が `If-None-Match: "blog-list-revision"` を付けて要求する
    Then resourceRevision と query が同じ場合は HTTP ステータス 304 である
    And 応答 body は空である

  Scenario: HEAD で metadata を取得する
    When client が HEAD で "/v1/blog?limit=12" を要求する
    Then GET と同じ status、cache、ETag、CORS header を受け取る
    And 応答 body は空である

  Scenario: CORS preflight を取得する
    When client が OPTIONS で "/v1/blog" を要求する
    Then GET、HEAD、OPTIONS を許可する CORS header を受け取る
    And "Access-Control-Allow-Origin: *" を受け取る

  Scenario: 無効な cursor を拒否する
    When client が "/v1/blog?cursor=invalid" を要求する
    Then HTTP ステータス 400 を受け取る
    And Content-Type は "application/problem+json" である
    And 応答は次の problem fields を持つ
      | field    | value                                               |
      | type     | https://content.daiksud.com/problems/invalid-cursor |
      | title    | Invalid cursor                                      |
      | status   |                                                 400 |
      | detail   | cursor is invalid for the requested blog collection |
      | instance | /v1/blog?cursor=invalid                             |

  Scenario: 許可外 method を拒否する
    When client が POST で "/v1/blog" を要求する
    Then HTTP ステータス 405 の problem response を受け取る
    And Allow header は "GET, HEAD, OPTIONS" である
