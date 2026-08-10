@content @api @manifest @version @health
Feature: Content の route、version、稼働状態を取得する
  consumer と運用者として
  配信中の resource と revision を識別するために
  manifest、version、health endpoint を利用したい

  Scenario: Blog manifest を取得する
    When client が GET "/v1/blog/manifest" を要求する
    Then HTTP ステータス 200 を受け取る
    And 応答は次の内容を持つ
      | field            | value                  |
      | apiVersion       | v1                     |
      | resource         | blog                   |
      | contentVersion   | vYYYY.MM.DD[+build]    |
      | gitSha           |    40文字の commit SHA |
      | resourceRevision | blog resource revision |
      | routes.articles  | slug の集合            |
      | routes.tags      | tag の集合             |
      | rendererVersion  | renderer version       |
    And cache tag は "content-blog-current" である

  Scenario: 配信 version を取得する
    When client が GET "/v1/version" を要求する
    Then 応答は apiVersion、contentVersion、gitSha、resourceRevisions を持つ
    And cache tag は "content-version-current" である
    And ETag は配信 version revision から決定される

  Scenario: health check を取得する
    When monitor が GET "/healthz" を要求する
    Then HTTP ステータス 200 を受け取る
    And 応答は `{"status":"ok"}` を含む
    And 応答は現在の contentVersion と gitSha を含む
    And Cache-Control は "no-store" である

  Scenario: API の crawler header を確認する
    When crawler が GET "/v1/version" を要求する
    Then 応答は "X-Robots-Tag: noindex" を持つ

  Scenario: robots 方針を取得する
    When crawler が GET "/robots.txt" を要求する
    Then "/v1/" は crawl 対象外として記述される
    And "/_astro/" は asset 取得可能として記述される
