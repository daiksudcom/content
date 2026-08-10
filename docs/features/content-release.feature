# language: ja
@content @release @version @cloudflare
機能: Content version を安全に production へリリースする
  Content 保守者として
  git tag、Worker version、resource revision、cache を一致させるために
  日付 version の候補を検証して段階的に昇格したい

  背景:
    前提release の日付 timezone は "Asia/Tokyo" である
    かつversion は正規表現 "^v\\d{4}\\.\\d{2}\\.\\d{2}(?:\\+[1-9]\\d*)?$" に一致する
    かつ同じ release branch の workflow は concurrency lock で直列化される

  シナリオアウトライン: 同日の version 候補を決める
    前提日付が "2026-08-10" である
    かつ同日の既存 tag 数は <count> である
    もしrelease candidate を既存 tag から計算する
    ならばcandidate は "<version>" である

    例:
      | count | version       |
      |     0 | v2026.08.10   |
      |     1 | v2026.08.10+1 |
      |     2 | v2026.08.10+2 |

  シナリオ: candidate を production へ昇格する
    前提candidate version と source git SHA が確定している
    もしrelease workflow を実行する
    ならば次の順序ですべて成功する
      | order | action                                                      |
      |     1 | version、git SHA、resourceRevision を成果物へ埋め込む       |
      |     2 | source、route、schema、package、build を検証する            |
      |     3 | Wrangler version upload を実行する                          |
      |     4 | preview deployment で API と asset の smoke test を実行する |
      |     5 | uploaded Worker version を production へ promote する       |
      |     6 | production API と asset の smoke test を実行する            |
      |     7 | 同じ SHA へ annotated git tag を push する                  |
      |     8 | 変更 resource と version の cache tag を purge する         |

  シナリオ: production smoke test が失敗する
    前提一つ前の production Worker version が記録されている
    かつ新しい version の production smoke test が失敗した
    もしworkflow が失敗を処理する
    ならばproduction traffic を一つ前の Worker version へ戻す
    かつannotated git tag は作成されない
    かつcache purge は実行されない

  シナリオ: annotated tag の push が失敗する
    前提新しい Worker version の production smoke test は成功した
    かつannotated git tag の push が失敗した
    もしworkflow が失敗を処理する
    ならばproduction traffic を一つ前の Worker version へ戻す
    かつ新しい version の cache purge は実行されない

  シナリオ: 公開済み version tag を保護する
    前提version tag に GitHub ruleset が適用されている
    もし公開済み tag の更新または削除が要求される
    ならばruleset は変更を拒否する
