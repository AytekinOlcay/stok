"use client";

import "@uiw/react-md-editor/markdown-editor.css";
import "@uiw/react-markdown-preview/markdown.css";
import dynamic from "next/dynamic";
import { useState } from "react";

const MDEditor = dynamic(() => import("@uiw/react-md-editor"), { ssr: false });

interface Props {
  name: string;
  defaultValue?: string;
  placeholder?: string;
  height?: number;
}

export function MarkdownEditor({
  name,
  defaultValue = "",
  placeholder = "Açıklama yazın...",
  height = 280,
}: Props) {
  const [value, setValue] = useState(defaultValue);

  return (
    <div data-color-mode="light">
      <MDEditor
        value={value}
        onChange={(v) => setValue(v ?? "")}
        preview="edit"
        height={height}
        textareaProps={{ placeholder }}
        visibleDragbar={false}
      />
      {/* Hidden input so the FormData picks it up like a normal textarea */}
      <input type="hidden" name={name} value={value} />
    </div>
  );
}
