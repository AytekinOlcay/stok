export type VideoSource = {
  type: "youtube" | "vimeo" | "instagram" | "tiktok" | "other";
  videoId: string | null;
  embedUrl: string | null; // null = no embed available
  thumbnailUrl: string | null;
  originalUrl: string;
};

export function parseVideoUrl(url: string): VideoSource {
  const trimmed = url.trim();

  // ── YouTube ─────────────────────────────────────────────────────
  // Handles: youtu.be/{id}  |  youtube.com/watch?v={id}
  //          youtube.com/shorts/{id}  |  youtube.com/embed/{id}
  const ytMatch = trimmed.match(
    /(?:youtu\.be\/|youtube\.com\/(?:watch\?v=|shorts\/|embed\/))([a-zA-Z0-9_-]{11})/
  );
  if (ytMatch) {
    const id = ytMatch[1];
    return {
      type: "youtube",
      videoId: id,
      embedUrl: `https://www.youtube.com/embed/${id}?rel=0&modestbranding=1`,
      thumbnailUrl: `https://img.youtube.com/vi/${id}/hqdefault.jpg`,
      originalUrl: trimmed,
    };
  }

  // ── Vimeo ────────────────────────────────────────────────────────
  // Handles: vimeo.com/{id}  |  vimeo.com/video/{id}
  const vimeoMatch = trimmed.match(/vimeo\.com\/(?:video\/)?(\d+)/);
  if (vimeoMatch) {
    const id = vimeoMatch[1];
    return {
      type: "vimeo",
      videoId: id,
      embedUrl: `https://player.vimeo.com/video/${id}?dnt=1`,
      thumbnailUrl: null, // Vimeo thumbnail requires a separate API call
      originalUrl: trimmed,
    };
  }

  // ── Instagram ────────────────────────────────────────────────────
  // Handles: instagram.com/reel/{code}/  |  instagram.com/p/{code}/
  if (trimmed.includes("instagram.com")) {
    return {
      type: "instagram",
      videoId: null,
      embedUrl: null, // Instagram blocks WebView embeds
      thumbnailUrl: null,
      originalUrl: trimmed,
    };
  }

  // ── TikTok ───────────────────────────────────────────────────────
  const tiktokMatch = trimmed.match(/tiktok\.com\/@[^/]+\/video\/(\d+)/);
  if (tiktokMatch) {
    return {
      type: "tiktok",
      videoId: tiktokMatch[1],
      embedUrl: null, // TikTok embed unreliable on mobile
      thumbnailUrl: null,
      originalUrl: trimmed,
    };
  }

  // ── Unknown ──────────────────────────────────────────────────────
  return {
    type: "other",
    videoId: null,
    embedUrl: null,
    thumbnailUrl: null,
    originalUrl: trimmed,
  };
}
