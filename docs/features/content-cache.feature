@content @cache @isr @cloudflare
Feature: resource 単位で Content 応答をキャッシュする
  運用者として
  resource を独立して更新しながら edge 応答を高速化するために
  resource-scoped cache tag を使いたい

  Background:
    Given production Worker で cache.enabled が true である
    And browser TTL は0秒、edge TTLは300秒、SWRは3600秒、stale-if-errorは86400秒である

  Scenario Outline: endpoint に cache tag を付ける
    When "<response>" を生成する
    Then Cache-Tag は "<tag>" を含む

    Examples:
      | response        | tag                      |
      | Blog 一覧       | content-blog-current     |
      | Blog 記事       | content-blog-current     |
      | Blog manifest   | content-blog-current     |
      | version         | content-version-current  |
      | 将来の projects | content-projects-current |

  Scenario: 複数 resource から応答を生成する
    Given 応答が blog と projects の revision に依存する
    When cache metadata を生成する
    Then Cache-Tag は "content-blog-current" と "content-projects-current" を含む

  Scenario: cache miss を生成する
    Given Worker version 固有 cache key に応答がない
    When API を要求する
    Then Worker が resource response を生成して保存する
    And CF-Cache-Status で MISS を観測できる

  Scenario: cache hit を返す
    Given Worker version 固有 cache key に有効な応答がある
    When 同じ endpoint と query を要求する
    Then Cloudflare は Worker 処理を迂回して応答する
    And CF-Cache-Status で HIT を観測できる

  Scenario: stale response を更新する
    Given edge TTLを過ぎSWR期間内の応答がある
    When API を要求する
    Then stale response を直ちに返す
    And background で現在 resource revision の response を保存する

  Scenario: 更新障害時に stale response を返す
    Given 86400秒以内の stale response がある
    And background の再生成が失敗する
    When API を要求する
    Then 利用可能な stale response を返す

  Scenario: Blog release の cache を purge する
    Given 新しい blog resource revision が production に昇格した
    When release workflow が "content-blog-current" を purge する
    Then 次の Blog 要求は新しい revision から response を生成する
    And version endpoint の更新では "content-version-current" も purge される
