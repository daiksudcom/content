@content @deployment @release @version @cloudflare
Feature: mergeごとにContentをDeployし、tagで配信revisionを記録する
  Content保守者として
  delivery serviceのcontract変更と記事更新を同じ手順で本番へ届けるために
  tag打ちとDeployを単一のworkflowで決定的に実行したい

  Background:
    Given delivery service layerのSemVer coreはpackage.jsonを正本とする
    And OpenAPI info.versionはpackage.jsonのversionと一致する
    And 記事は常にmainを配信し release制御を持たない
    And 初回core versionは"0.1.0"である
    And Git tagは更新と削除を禁止されている

  Rule: PRのmergeは必ずDeployされる

    Scenario: exact main revisionをproductionへDeployする
      Given mainに新しいcommitがある
      When Deploy workflowを実行する
      Then 次の順序ですべて成功する
        | order | action                                            |
        |     1 | revisionがmainに含まれることを検証する            |
        |     2 | source、OpenAPI、policy、buildを検証する          |
        |     3 | このrevisionのtagを解決して作成する               |
        |     4 | immutable Worker versionをuploadする              |
        |     5 | uploaded versionをpreview smokeする               |
        |     6 | 同じversionをproductionへ昇格する                 |
        |     7 | production APIとassetをsmokeする                  |
        |     8 | source SHAとtagをDeploymentへ記録する             |
        |     9 | 最新tagが本番versionと一致することを検証する      |

    Scenario: mainが短時間に複数回更新される
      Given 一つのproduction Deployが実行中である
      And 一つのmain revisionがpendingである
      When さらに新しいmain revisionが到着する
      Then 実行中のDeployはcancelされない
      And 古いpending revisionはskipされる
      And 最新pending revisionだけが残る

  Rule: PRタイトルの型が必要なversion bumpを決める

    Scenario Outline: conventional commit型からtagを決める
      Given 直前のcore versionは"<previous>"である
      And PRタイトルの型は"<title>"である
      When pull request policyを検証する
      Then 必要なcore versionは"<next>"である
      And 打たれるtagは"<tag>"である
      And GitHub Releaseの作成は"<release>"である

      Examples:
        | previous | title      | next  | tag                     | release |
        | 0.1.0    | feat:      | 0.2.0 | v0.2.0                  | する    |
        | 0.1.0    | perf:      | 0.2.0 | v0.2.0                  | する    |
        | 0.1.0    | fix:       | 0.1.1 | v0.1.1                  | する    |
        | 0.1.0    | revert:    | 0.1.1 | v0.1.1                  | する    |
        | 0.1.0    | feat!:     | 0.2.0 | v0.2.0                  | する    |
        | 1.4.2    | feat!:     | 2.0.0 | v2.0.0                  | する    |
        | 1.2.3    | docs:      | 1.2.3 | v1.2.3+YYYYMMDDHHmmss   | しない  |
        | 1.2.3    | chore:     | 1.2.3 | v1.2.3+YYYYMMDDHHmmss   | しない  |

    Scenario: version bumpのないfeature PRを拒否する
      Given 直前のcore versionは"0.1.0"である
      And PRタイトルは"feat: add a blog endpoint"である
      And package.jsonのversionは"0.1.0"のままである
      When pull request policyを検証する
      Then 検証は失敗する
      And errorは必要なversion"0.2.0"を示す

    Scenario: package.jsonとOpenAPIのversionが食い違う
      Given package.jsonのversionは"0.2.0"である
      And OpenAPI info.versionは"0.1.0"である
      When repository policyを検証する
      Then 検証は失敗する
      And revisionはmergeもDeployもされない

  Rule: 記事だけの更新は他repositoryのdocs変更と同じ扱いになる

    Scenario: 記事と記事mediaだけを更新する
      Given core versionは"1.2.3"である
      And PRタイトルは"docs(content): publish the ISR article"である
      And merge commitのcommitter時刻はUTCの"2026-08-13T03:04:05Z"である
      When Deploy workflowを実行する
      Then package.jsonとOpenAPI info.versionは"1.2.3"のままである
      And 同じSHAへannotated tag "v1.2.3+20260813030405"を作る
      And GitHub Releaseは作成しない
      And 記事はDeploy完了時点でpublic routeから取得できる

    Scenario: APIと記事を同時に変更する
      Given 一つのpull requestがOpenAPI contractと記事を変更する
      And PRタイトルの型は"feat:"である
      When Deploy workflowを実行する
      Then core tag "vX.Y.Z"だけを作る
      And build metadata tagは作らない

  Rule: 再実行は同じtagへ収束する

    Scenario: 中断したDeployを再実行する
      Given あるrevisionのtagは作成済みでDeployは未完了である
      When 同じrevisionへworkflow_dispatchで再実行する
      Then build識別子はcommitter時刻から同じ値に解決される
      And 既存tagと同じ名前になるためtagを作り直さない
      And Deployだけを続行する

    Scenario: 既存tagが別のrevisionを指している
      Given 解決したtagが別のcommitを指している
      When Deploy workflowがtagを作ろうとする
      Then workflowは失敗する
      And tagは移動も削除もされない

    Scenario Outline: 失敗の原因で再試行を分岐する
      Given Deploy中に"<cause>"が発生する
      When workflowが失敗を処理する
      Then 再試行は"<retry>"である

      Examples:
        | cause                          | retry        |
        | Cloudflare APIの503            | 最大3回      |
        | 429 Too Many Requests          | 最大3回      |
        | 接続タイムアウト               | 最大3回      |
        | DNS解決失敗                    | 最大3回      |
        | build失敗                      | しない       |
        | test失敗                       | しない       |
        | 401または403                   | しない       |
        | 429以外の4xx                   | しない       |

    Scenario: production smokeが失敗する
      Given 直前のWorker versionが100%で稼働していた
      And 新しいWorker versionのproduction smokeが失敗する
      When workflowが失敗を処理する
      Then production trafficを直前Worker versionへ戻す
      And 作成済みtagは削除も移動もされない
      And 次のdrift checkが最新tagと本番versionの乖離を報告する

  Scenario: 最新tagと本番versionの一致を検証する
    Given "v1.2.3"と"v1.2.3+20260813030405"はSemVer上で同じprecedenceである
    When 最新tagを判定する
    Then 辞書順比較を使用しない
    And SemVer precedenceとcommit topologyを使用する
    And 判定した最新tagをGitHub Deploymentのreceiptと比較する
