# language: ja
@content @api @blog @article
機能: Blog 記事を API で取得する
  API consumer として
  検証済みの本文と metadata を SSR に使用するために
  slug から trusted HTML article を取得したい

  シナリオ: 公開記事を取得する
    前提slug "cloudflare-isr" の公開済み記事がある
    もしclient が GET "/v1/blog/cloudflare-isr" を要求する
    ならばHTTP ステータス 200 を受け取る
    かつContent-Type は "application/json" である
    かつ応答は次の構造を満たす
      """
      {
        "apiVersion": "v1",
        "resource": "blog",
        "contentVersion": "v2026.08.10+1",
        "gitSha": "<40-character-sha>",
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
          "styles": ["https://content.daiksud.com/_astro/<hash>.css"],
          "rendererVersion": "<renderer-version>",
          "toc": ["<heading entries>"],
          "readingTimeMinutes": 6,
          "previous": "<summary or null>",
          "next": "<summary or null>"
        }
      }
      """
    かつ応答は "Access-Control-Allow-Origin: *" を持つ
    かつ応答は "X-Robots-Tag: noindex" を持つ

  シナリオ: 記事 ETag を再検証する
    前提記事応答の ETag が "\"blog-article-revision\"" である
    もしclient が同じ slug と `If-None-Match: "blog-article-revision"` で要求する
    ならばresourceRevision と request 条件が同じ場合は HTTP ステータス 304 である
    かつ応答 body は空である

  シナリオ: HEAD で記事 metadata を取得する
    もしclient が HEAD "/v1/blog/cloudflare-isr" を要求する
    ならばGET と同じ status、ETag、cache、CORS header を受け取る
    かつ応答 body は空である

  シナリオ: 未知の slug を取得する
    もしclient が GET "/v1/blog/missing-article" を要求する
    ならばHTTP ステータス 404 を受け取る
    かつContent-Type は "application/problem+json" である
    かつproblem type は "https://content.daiksud.com/problems/blog-not-found" である
