# MarkdownArea

A live-rendering Markdown editor control for Xojo desktop apps, written in pure Xojo code. It needs no plugins, HTMLViewer or WebView.

![MarkdownArea rendering headings, inline styles and a table](Screenshots/markdownarea.png)

## What it's for

`MarkdownArea` is a drop-in replacement for a `DesktopTextArea` when your users write Markdown: notes, documentation, comments, README files, issue text and so on.

It works like editors such as Typora or Obsidian's live preview. The text stays plain Markdown, but every line is shown rendered **as you type**. Only the line with the caret shows its raw Markdown, so you can always see and edit the syntax you're working on. Move the caret away and the line renders again.

The `Text` property always holds the raw, unchanged Markdown, so you can save and load it like any other string.

![Lists, task lists, block quote, rule and code block](Screenshots/markdownarea-2.png)

## Features

### Markdown rendering

- **Headings**: `#` to `######`, each scaled to its own size
- **Inline styles**: `**bold**`, `*italic*`, `***bold italic***`, `__bold__`, `_italic_`, `~~strikethrough~~` and `` `inline code` ``
- **Links**: `[text](url)` drawn as underlined links. Cmd+click (macOS) or Ctrl+click (Windows/Linux) opens them. Web, `mailto:` and `tel:` links, as well as local file paths, are supported.
- **Images**: `![alt](source)` displayed inline, scaled to the editor width. Sources can be
  - `http://` / `https://` URLs, downloaded asynchronously
  - `data:` URIs
  - local files, absolute or relative to `BaseFolder`
  - anything your app supplies itself through the `ImageRequested` event, e.g. from a database or the app's resources
- **Tables**: GitHub-style pipe tables with a header row, `:---` / `:---:` / `---:` column alignment, striped rows and text that wraps inside its cell so the table always fits the editor width
- **Lists**: bulleted (`-`, `*`, `+`) and numbered lists
- **Task lists**: `- [ ]` / `- [x]` drawn as checkboxes, with completed tasks dimmed
- **Block quotes**: `>`
- **Horizontal rules**: `---`
- **Fenced code blocks**: shown in a monospaced font on a shaded background

### Editing

- Full caret and selection handling with the keyboard and the mouse, including word-wise movement, Home/End, Page Up/Down, double-click to select a word and triple-click to select a line
- Undo/Redo with up to 200 steps, typing grouped into sensible steps
- Cut, Copy, Paste and Select All through the standard Edit menu, keyboard shortcuts and a built-in context menu
- Shortcuts: **Cmd/Ctrl+B** bold, **Cmd/Ctrl+I** italic, **Cmd/Ctrl+K** link
- A **floating formatting toolbar** that appears when the mouse comes near the top edge. It has bold, italic, strikethrough, inline code, H1–H3, bulleted/numbered/task lists, quote, link, code block, table and horizontal rule. Buttons that don't fit a narrow editor are left out automatically.
- Optional read-only mode and an option to show the raw, unrendered Markdown

### Look & platform

- Light and **dark mode** support with matching colors for code, tables, quotes, links and selection
- HiDPI / Retina ready
- Built-in mouse-wheel scrolling and a slim scroll bar
- Toolbar and context menu strings are dynamic constants, ready for localization
- Native double-click timing on macOS and Windows

## Requirements

- Xojo 2021r3 or newer (the project is saved with Xojo 2026r3)
- Desktop projects on macOS, Windows or Linux

## Installation

1. Copy `MarkdownArea.xojo_code` into your project (drag it into the Xojo navigator).
2. Drag a `DesktopCanvas` onto a window and set its **Super** to `MarkdownArea`.
3. Set the `Text` property, or let your users start typing.

The included demo project (`MarkdownArea.xojo_project`) shows a window with sample content for every supported element.

## Usage

```xojo
// Load Markdown
MarkdownArea1.Text = "# Hello" + EndOfLine + "This is **Markdown**."

// Save Markdown
Var markdown As String = MarkdownArea1.Text

// Resolve relative image paths against the document's folder
MarkdownArea1.BaseFolder = documentFile.Parent

// Append text at the end of the document
MarkdownArea1.AddText(EndOfLine + "- [ ] New task")
```

### Handling links yourself

```xojo
Function LinkClicked(url As String) As Boolean
  If url.BeginsWith("app://") Then
    HandleInternalLink(url)
    Return True // MarkdownArea won't open the link itself
  End If
  Return False
End Function
```

### Supplying images from your app

```xojo
Function ImageRequested(source As String) As Picture
  If source.BeginsWith("db:") Then
    Return LoadPictureFromDatabase(source.Middle(3))
  End If
  Return Nil // let MarkdownArea load it
End Function
```

## API overview

### Properties

| Property | Type | Description |
|:--|:--|:--|
| `Text` | String | The raw, unrendered Markdown text |
| `RenderMarkdown` | Boolean | When `False`, the text is shown as raw Markdown |
| `ReadOnly` | Boolean | Prevents editing; selection and copying still work |
| `HasToolbar` | Boolean | Shows the formatting toolbar when the mouse comes near the top edge |
| `ToolbarRevealDistance` | Integer | Distance in points from the top edge within which the toolbar appears |
| `BaseFolder` | FolderItem | Folder that relative image and link paths are resolved against |
| `TableAlignment` | TableAlignments | Places tables narrower than the editor on the left, center or right |
| `FontName`, `FontSize` | String, Single | Base font. `System` / `0` use the system defaults |
| `LineSpacing` | Double | Line height as a factor of the font's text height (default `1.3`) |
| `TextColor`, `BackgroundColor`, `HasBackgroundColor` | Color, Color, Boolean | Colors; defaults follow light/dark mode |
| `HasBorder` | Boolean | Draws a border and focus ring |
| `SelectionStart`, `SelectionLength`, `SelectedText` | Integer, Integer, String | Selection, in characters of the raw text |
| `VerticalScrollPosition` | Integer | Scroll position in points from the top of the document |

### Methods

`AddText(value)`, `Copy`, `Cut`, `Paste`, `SelectAll`, `Undo`, `Redo`

### Events

| Event | Description |
|:--|:--|
| `TextChanged` | The text was changed |
| `SelectionChanged` | The caret or selection moved |
| `LinkClicked(url) As Boolean` | A link was Cmd/Ctrl-clicked. Return `True` to handle it yourself |
| `ImageRequested(source) As Picture` | Supply the picture for an image source, or return `Nil` to let MarkdownArea load it |

The usual `DesktopCanvas` events (`Opening`, `Closing`, `KeyDown`, mouse events, `Paint`, `FocusReceived`/`FocusLost`, `ConstructContextualMenu`, …) are passed through as well.

## Author

Sascha Schneppmueller
