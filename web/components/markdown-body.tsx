"use client";

import "@uiw/react-markdown-preview/markdown.css";
import dynamic from "next/dynamic";

const MDPreview = dynamic(() => import("@uiw/react-markdown-preview"), {
  ssr: false,
  loading: () => <div className="animate-pulse h-4 bg-muted rounded w-3/4" />,
});

interface Props {
  source: string;
  className?: string;
}

export function MarkdownBody({ source, className }: Props) {
  if (!source) return null;
  return (
    <div data-color-mode="light" className={className}>
      <MDPreview source={source} />
    </div>
  );
}
