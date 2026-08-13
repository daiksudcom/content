@content @openapi @api @version
Feature: SemVer OpenAPI契約からContent APIを利用する
  HomeとBlogの開発者として
  transportにかかわらず同じversioned contractを利用するために
  Content repositoryのOpenAPI documentを正本にしたい

  Background:
    Given repository versionの正本はpackage.jsonである
    And OpenAPI documentは"openapi/content.openapi.json"にある

  Scenario: repositoryとOpenAPIのcore versionを一致させる
    Given package.jsonのversionは"0.1.0"である
    When OpenAPI contractを検証する
    Then info.versionは"0.1.0"である
    And info.versionはv prefixとbuild metadataを持たない

  Scenario: HTTPSとService Bindingで同じ契約を使う
    Given consumerはOpenAPI contractに適合するFetch-compatible transportを実装している
    When transportをHTTPSからCloudflare Service Bindingへ交換する
    Then request、success response、problem responseのschemaは変わらない
    And consumerはruntime responseを同じschemaで検証する

  Scenario Outline: OpenAPI wire contractの変更をversionへ反映する
    Given 直前のcore OpenAPI contractが公開されている
    And 差分種別は"<change>"である
    When pull request policyを検証する
    Then 必要なSemVer tierは"<tier>"である
    And そのtierはpull requestのタイトルで宣言する

    Examples:
      | change                       | tier  |
      | breaking                     | major |
      | backward-compatible addition | minor |
      | deprecation                  | minor |
      | compatible contract fix      | patch |

  Scenario: 文書だけを更新する
    Given OpenAPI差分はdescription、summary、title、exampleだけである
    When pull request policyを検証する
    Then repository SemVer coreは変わらない
    And GitHub Releaseは作成されない
    And 変更はbuild metadata tagとしてDeployされる

  Scenario: 新しいAPI majorへ移行する
    Given OpenAPI 1.xは"/v1"で公開されている
    When breaking contractをOpenAPI 2.0.0としてReleaseする
    Then 新しいcontractは"/v2"で公開される
    And "/v1"はconsumer移行中も並行提供される
    And "/v1"の廃止はdeprecationを経た別Releaseで行われる
