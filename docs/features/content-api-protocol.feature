@content @api @protocol
Feature: Content API の共通 HTTP 契約を利用する
  API consumer として
  resource にかかわらず同じ method、header、error 契約を利用するために
  versioned API endpoint の共通 protocol を検証したい

  Background:
    Given public Content API の origin は "https://content.daiksud.me" である

  Scenario Outline: public read endpoint を取得する
    Given "<path>" に公開済みの対象がある
    When client が GET "<path>" を要求する
    Then HTTP ステータス 200 を受け取る
    And 応答は "Access-Control-Allow-Origin: *" を持つ
    And 応答は "X-Robots-Tag: noindex" を持つ

    Examples:
      | path                    |
      | /v1/blog?limit=12       |
      | /v1/blog/cloudflare-isr |
      | /v1/blog/manifest       |
      | /v1/version             |

  Scenario Outline: HEAD で metadata を取得する
    Given "<path>" に公開済みの対象がある
    When client が HEAD "<path>" を要求する
    Then GET と同じ status、cache、ETag、CORS、crawler header を受け取る
    And 応答 body は空である

    Examples:
      | path                    |
      | /v1/blog?limit=12       |
      | /v1/blog/cloudflare-isr |
      | /v1/blog/manifest       |
      | /v1/version             |

  Scenario Outline: CORS preflight を取得する
    When client が OPTIONS "<path>" を要求する
    Then GET、HEAD、OPTIONS を許可する CORS header を受け取る
    And "Access-Control-Allow-Origin: *" を受け取る

    Examples:
      | path                    |
      | /v1/blog                |
      | /v1/blog/cloudflare-isr |
      | /v1/blog/manifest       |
      | /v1/version             |

  Scenario Outline: 許可外 method を拒否する
    When client が POST "<path>" を要求する
    Then HTTP ステータス 405 を受け取る
    And Content-Type は "application/problem+json" である
    And Allow header は "GET, HEAD, OPTIONS" である
    And 応答は "Access-Control-Allow-Origin: *" を持つ
    And 応答は "X-Robots-Tag: noindex" を持つ

    Examples:
      | path                    |
      | /v1/blog                |
      | /v1/blog/cloudflare-isr |
      | /v1/blog/manifest       |
      | /v1/version             |

  Scenario Outline: problem response に共通 header を付ける
    When client が GET "<path>" を要求する
    Then HTTP ステータス <status> を受け取る
    And Content-Type は "application/problem+json" である
    And 応答は "Access-Control-Allow-Origin: *" を持つ
    And 応答は "X-Robots-Tag: noindex" を持つ

    Examples:
      | path                     | status |
      | /v1/blog?cursor=invalid  |    400 |
      | /v1/blog/missing-article |    404 |
