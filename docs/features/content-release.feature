@content @release @version @cloudflare
Feature: Content version を安全に production へリリースする
  Content 保守者として
  git tag、Worker version、resource revision、cache を一致させるために
  日付 version の候補を検証して段階的に昇格したい

  Background:
    Given release の日付 timezone は "Asia/Tokyo" である
    And version は正規表現 "^v\\d{4}\\.\\d{2}\\.\\d{2}(?:\\+[1-9]\\d*)?$" に一致する
    And 同じ release branch の workflow は concurrency lock で直列化される

  Scenario Outline: 同日の version 候補を決める
    Given 日付が "2026-08-10" である
    And 同日の既存 tag 数は <count> である
    When release candidate を既存 tag から計算する
    Then candidate は "<version>" である

    Examples:
      | count | version       |
      |     0 | v2026.08.10   |
      |     1 | v2026.08.10+1 |
      |     2 | v2026.08.10+2 |

  Scenario: candidate を production へ昇格する
    Given candidate version と source git SHA が確定している
    When release workflow を実行する
    Then 次の順序ですべて成功する
      | order | action                                                      |
      |     1 | version、git SHA、resourceRevision を成果物へ埋め込む       |
      |     2 | source、route、schema、package、build を検証する            |
      |     3 | Wrangler version upload を実行する                          |
      |     4 | preview deployment で API と asset の smoke test を実行する |
      |     5 | uploaded Worker version を production へ promote する       |
      |     6 | production API と asset の smoke test を実行する            |
      |     7 | 同じ SHA へ annotated git tag を push する                  |
      |     8 | 変更 resource と version の cache tag を purge する         |

  Scenario: production smoke test が失敗する
    Given 一つ前の production Worker version が記録されている
    And 新しい version の production smoke test が失敗した
    When workflow が失敗を処理する
    Then production traffic を一つ前の Worker version へ戻す
    And annotated git tag は作成されない
    And cache purge は実行されない

  Scenario: annotated tag の push が失敗する
    Given 新しい Worker version の production smoke test は成功した
    And annotated git tag の push が失敗した
    When workflow が失敗を処理する
    Then production traffic を一つ前の Worker version へ戻す
    And 新しい version の cache purge は実行されない

  Scenario: 公開済み version tag を保護する
    Given version tag に GitHub ruleset が適用されている
    When 公開済み tag の更新または削除が要求される
    Then ruleset は変更を拒否する
