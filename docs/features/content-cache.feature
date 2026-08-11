@content @cache @isr @cloudflare
Feature: resource 単位で Content 応答をキャッシュする
  運用者として
  resource を独立して更新しながら edge 応答を高速化するために
  resource-scoped cache tag を使いたい

  Background:
    Given production Content API が利用可能である

  Scenario: production の cache policy を取得する
    When API を要求する
    Then Cache-Control は "public, max-age=0" である
    And Cloudflare-CDN-Cache-Control は "public, max-age=300, stale-while-revalidate=3600, stale-if-error=86400" である

  Scenario Outline: endpoint に cache tag を付ける
    When "<response>" を生成する
    Then Cache-Tag は "<tag>" を含む

    Examples:
      | response      | tag                     |
      | Blog 一覧     | content-blog-current    |
      | Blog 記事     | content-blog-current    |
      | Blog manifest | content-blog-current    |
      | version       | content-version-current |

  Scenario: cache miss を生成する
    Given 同じ endpoint、query、resource revision の fresh response が cache にない
    When API を要求する
    Then 現在の resource revision の response を受け取る
    And CF-Cache-Status は "MISS" である
    And 続く同じ endpoint と query の要求で CF-Cache-Status は "HIT" になる

  Scenario: cache hit を返す
    Given 同じ endpoint、query、resource revision の fresh response が cache にある
    When 同じ endpoint と query を要求する
    Then 同じ resource revision の response を受け取る
    And CF-Cache-Status は "HIT" である

  Scenario: stale response を更新する
    Given edge TTLを過ぎSWR期間内の応答がある
    When API を要求する
    Then stale response を直ちに返す
    And 後続の要求では現在の resource revision の response を受け取る
    And CF-Cache-Status は "HIT" になる

  Scenario: 更新障害時に stale response を返す
    Given 86400秒以内の stale response がある
    And background の再生成が失敗する
    When API を要求する
    Then 利用可能な stale response を返す

  Scenario: Blog release の cache を purge する
    Given 新しい blog resource revision が production に昇格した
    When release workflow が "content-blog-current" を purge する
    Then 次の Blog 要求は新しい revision から response を生成する
    And CF-Cache-Status は "MISS" である
    And 続く同じ Blog 要求で CF-Cache-Status は "HIT" になる
    And version endpoint の更新では "content-version-current" も purge される
