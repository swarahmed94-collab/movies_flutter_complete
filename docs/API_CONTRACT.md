# REST API contract used

**Base URL** from the user: `https://yts.pw/api` → project default `https://yts.pw/api/v2/`. The named host could not be verified as reachable in the authoring environment. A YTS v2-compatible base URL is mandatory; override with `--dart-define=MOVIES_API_BASE_URL=...` if necessary.

Only the established YTS v2 **GET** operations are called:

1. `list_movies.json`: `limit`, `page`, `sort_by`, `order_by` and, when chosen, `genre`, `query_term`, `minimum_rating`, `quality`. Used for Home sections, Browse and Search. `data.movie_count`, `data.page_number`, `data.limit`, `data.movies` drive pagination.
2. `movie_details.json`: `movie_id`, `with_images=true`, `with_cast=true`. Reads `data.movie` for the details page.
3. `movie_suggestions.json`: `movie_id`. Reads `data.movies` for suggested movies.

Successful envelope: `{"status":"ok", "data": {...}}`. Non-success `status` is mapped to `ApiFailure`; `status_message` is shown when provided. No undocumented REST write operations are made.

Movie fields used where provided by the API: `id`, `title`, `title_english`, `year`, `rating`, `runtime`, `genres`, `small_cover_image`, `medium_cover_image`, `large_cover_image`, `background_image`, `background_image_original`, `summary`, `description_full`, `like_count`, `yt_trailer_code`, `medium_screenshot_image1..3`, `cast[].name`, `cast[].character_name`, `cast[].url_small_image`. Optional fields safely fall back without fictional values.

No Firebase ID token is injected into public YTS requests, preventing inadvertent token disclosure. Dio has request/error interceptors, timeouts and typed failure mapping. Hive stores actual remote JSON, with fresh-cache-first and stale-on-network-error logic. Full movie playback, torrent links, ratings submission and reviews are **not** included because the provided API description does not establish those operations.
