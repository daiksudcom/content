@content @api @blog @article
Feature: Blog 記事を API で取得する
  API consumer として
  検証済みの本文と metadata を SSR に使用するために
  slug から trusted HTML article を取得したい

  Scenario: 公開記事を取得する
    Given slug "cloudflare-isr" の公開済み記事がある
    When client が GET "/v1/blog/cloudflare-isr" を要求する
    Then HTTP ステータス 200 を受け取る
    And Content-Type は "application/json" である
    And 応答は次の構造を満たす
      """
      {
        "apiVersion": "v1",
        "openapiVersion": "1.2.3",
        "resource": "blog",
        "contentVersion": "v1.2.3+20260813030405",
        "gitSha": "<40-character-sha>",
        "workerVersionId": "<worker-version-id>",
        "resourceRevision": "<blog-revision>",
        "article": {
          "slug": "cloudflare-isr",
          "title": "<title>",
          "description": "<description>",
          "publishedAt": "<RFC3339 Asia/Tokyo instant>",
          "updatedAt": "<RFC3339 instant or null>",
          "tags": ["cloudflare"],
          "cover": "<absolute asset URL or null>",
          "coverAlt": "<alternative text or null>",
          "format": "trusted-html",
          "html": "<compiled HTML fragment>",
          "styles": ["https://content.daiksud.me/_astro/<hash>.css"],
          "rendererVersion": "<renderer-version>",
          "toc": ["<heading entries>"],
          "readingTimeMinutes": 6,
          "previous": "<summary or null>",
          "next": "<summary or null>"
        }
      }
      """

  Scenario: 記事 ETag を再検証する
    Given 記事応答の ETag が "\"blog-article-revision\"" である
    And 同じ slug の記事応答は変更されていない
    When client が同じ slug と `If-None-Match: "blog-article-revision"` で要求する
    Then HTTP ステータス 304 を受け取る
    And 応答 body は空である

  Scenario: 未知の slug を取得する
    When client が GET "/v1/blog/missing-article" を要求する
    Then HTTP ステータス 404 を受け取る
    And Content-Type は "application/problem+json" である
    And problem type は "https://content.daiksud.me/problems/blog-not-found" である
