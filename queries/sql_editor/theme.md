# Theme Reference — SQL Dev Tool
> Read by the Code Agent. Lists every `.palette(.token)` and icon name available.

---

## Layout Model

This app uses a **hybrid theme**:
- **Editor pane** is always dark (`editor_*` tokens), regardless of light/dark mode.
- **Chrome** (top bar, sidebar, results panel) is **light in Light mode**, dark in Dark mode (`chrome_*` tokens).
- Default mode: **Light**.

---

## Palette Tokens — `.palette(.token_name)`

### Accent / Interactive
| Token | Light | Dark | Use |
|---|---|---|---|
| `tint` | `#2563EB` | `#3B82F6` | Primary blue — active tabs, Submit/Run btn, focus states, selected sidebar items |
| `tint_subtle` | `#DBEAFE` | `#1E3A5F` | Low-opacity blue surface — selected rows, hover backgrounds |
| `tint_foreground` | `#FFFFFF` | `#FFFFFF` | Text/icons rendered on top of `tint` backgrounds |

### Editor Pane (always dark — same values in both modes)
| Token | Value | Use |
|---|---|---|
| `editor_bg` | `#1E1E2E` | Main SQL editor background |
| `editor_gutter_bg` | `#181825` | Gutter strip — slightly darker than editor_bg |
| `editor_gutter_fg` | `#585B70` | Line number text — muted |
| `editor_cursor` | `#89DCEB` | Text cursor / caret |
| `editor_selection` | `#313244` | Selected text highlight |

### Chrome (top bar, sidebar, results panel)
| Token | Light | Dark | Use |
|---|---|---|---|
| `chrome_bg` | `#F8FAFC` | `#0F1117` | Panel/sidebar/topbar background |
| `chrome_border` | `#E2E8F0` | `#1E2130` | Dividers between panes, panel outlines |
| `chrome_surface` | `#F1F5F9` | `#161B27` | Inset cards, table headers, toolbar strips |

### Text
| Token | Light | Dark | Use |
|---|---|---|---|
| `text_primary` | `#0F172A` | `#E2E8F0` | Main UI labels, button text, sidebar item names |
| `text_secondary` | `#475569` | `#94A3B8` | Metadata, row counts, column types |
| `text_muted` | `#94A3B8` | `#475569` | Placeholders, disabled states, hints |
| `text_on_dark` | `#CDD6F4` | `#CDD6F4` | Text inside the dark editor pane |

### SQL Syntax Highlighting
All syntax tokens apply inside the editor pane. Font: **IBM Plex Mono** (monospace).
| Token | Color | Language element |
|---|---|---|
| `syntax_keyword` | `#3B82F6` Blue | `SELECT`, `FROM`, `WHERE`, `JOIN`, `INSERT`, `UPDATE`, `DELETE`, `WITH`, `AS`, `ON`, `GROUP BY`, `ORDER BY`, `LIMIT` |
| `syntax_string` | `#2DD4BF` Teal | String literals `'...'`, quoted identifiers |
| `syntax_number` | `#F59E0B` Amber | Numeric literals, float/int values |
| `syntax_type` | `#A78BFA` Violet | Data types — `INT`, `VARCHAR`, `BOOLEAN`, `TIMESTAMP`, `UUID`, `JSONB` |
| `syntax_comment` | `#6B7280` Gray | `-- line comments`, `/* block comments */` — render italic |
| `syntax_operator` | `#CBD5E1` Slate | `=`, `>`, `<`, `!=`, `+`, `-`, `*`, `AND`, `OR`, `NOT`, `IN`, `LIKE` |
| `syntax_function` | `#22D3EE` Cyan | Built-ins — `COUNT()`, `MAX()`, `COALESCE()`, `NOW()`, `CAST()`, `ROW_NUMBER()` |
| `syntax_punctuation` | `#94A3B8` | `(`, `)`, `,`, `;`, `.` |

### Tab Bar
| Token | Use |
|---|---|
| `tab_active_bg` | Active tab fill |
| `tab_active_fg` | Active tab label text |
| `tab_active_accent` | Active tab underline indicator (blue) |
| `tab_inactive_fg` | Inactive tab label — muted |
| `tab_hover_bg` | Tab hover state background |

### Results Table
| Token | Use |
|---|---|
| `table_header_bg` | Column header row background |
| `table_header_fg` | Column header label text |
| `table_row_even` | Even row background (subtle alternation) |
| `table_row_odd` | Odd row background |
| `table_row_selected` | Focused / selected row — blue tinted |
| `table_border` | Cell and row divider lines |
| `table_null_fg` | NULL value display — distinct muted color |

### Status
| Token | Color | Use |
|---|---|---|
| `status_success` | Green | Row count, "Query OK", affected rows |
| `status_error` | Red | Syntax errors, connection failures, runtime errors |
| `status_warning` | Yellow-orange | Slow query, large result set, deprecation |
| `status_success_bg` | Tinted green surface | Success message background |
| `status_error_bg` | Tinted red surface | Error banner background |
| `status_warning_bg` | Tinted amber surface | Warning banner background |

### History Sidebar
| Token | Use |
|---|---|
| `history_bg` | History list panel background |
| `history_item_fg` | Default history entry text |
| `history_selected_bg` | Selected entry — blue-tinted highlight |
| `history_selected_fg` | Selected entry text — blue accent |
| `history_timestamp` | Relative timestamp metadata |

### Misc
| Token | Use |
|---|---|
| `scrollbar_thumb` | Scrollbar drag handle |
| `scrollbar_track` | Scrollbar track background |
| `focus_ring` | Keyboard navigation focus outline (blue) |

---

## Icon Tokens — `Icon(.token_name)`

### Query Actions
| Token | Icon | Use |
|---|---|---|
| `run` | ▶ play-fill | Execute current query |
| `run_all` | ⏭ skip-end-fill | Run all queries in editor |
| `stop` | ■ stop-fill | Cancel running query |
| `format_sql` | ✨ magic | Auto-format / beautify SQL |
| `explain` | 🔍 diagram-3 | Show EXPLAIN / query plan |

### Editor Controls
| Token | Icon | Use |
|---|---|---|
| `new_tab` | + plus-lg | Open new editor tab |
| `close_tab` | × x-lg | Close current tab |
| `save` | 💾 floppy | Save query to file |
| `undo` | ↩ arrow-counterclockwise | Undo last edit |
| `redo` | ↪ arrow-clockwise | Redo |
| `copy` | copy | Copy selection to clipboard |
| `wrap_toggle` | text-wrap | Toggle word wrap |

### Sidebar / Schema Tree
| Token | Icon | Use |
|---|---|---|
| `database` | database | Database root node |
| `table` | table | Table entry |
| `view` | eye | View / virtual table |
| `schema` | diagram-2 | Schema group folder |
| `column` | layout-three-columns | Column entry |
| `key_col` | key | Primary key column indicator |
| `index_icon` | lightning | Index node |
| `stored_proc` | braces | Stored procedure / function |
| `expand` | › chevron-right | Tree node expand arrow |
| `collapse` | ⌄ chevron-down | Tree node collapse arrow |
| `refresh` | ↻ arrow-repeat | Refresh schema / reconnect |
| `connect` | plug | Connect to database |
| `disconnect` | plug-fill | Disconnect from database |

### Results Panel
| Token | Icon | Use |
|---|---|---|
| `export_results` | ↓ download | Export results as CSV/JSON |
| `copy_results` | clipboard-data | Copy results to clipboard |
| `filter` | funnel | Filter result rows |
| `sort_asc` | sort-up | Sort column ascending |
| `sort_desc` | sort-down | Sort column descending |
| `row_count` | # hash | Row count badge |
| `maximize_pane` | arrows-fullscreen | Maximize results pane |
| `split_view` | layout-split | Split editor / results view |

### Status / Feedback
| Token | Icon | Use |
|---|---|---|
| `success` | ✓ check-circle-fill | Query success — color: `status_success` |
| `error_icon` | ✗ x-circle-fill | Query error — color: `status_error` |
| `warning` | ⚠ exclamation-triangle-fill | Warning — color: `status_warning` |
| `info` | ℹ info-circle | Info / hint message |
| `loading` | ⧗ hourglass-split | Query running spinner |

### History
| Token | Icon | Use |
|---|---|---|
| `history` | clock-history | History panel toggle |
| `history_pin` | pin-angle | Pin history entry |
| `history_delete` | trash3 | Delete history entry |
| `history_rerun` | arrow-return-left | Re-run query from history |

### Settings / App Shell
| Token | Icon | Use |
|---|---|---|
| `settings` | gear | Settings panel |
| `theme_toggle` | circle-half | Toggle light/dark mode |
| `keyboard` | keyboard | Keyboard shortcuts reference |
| `search` | search | Global search |
| `help` | question-circle | Help / documentation |

---

## Typography Quick Reference

| Surface | Font | Notes |
|---|---|---|
| SQL editor | IBM Plex Mono | All code, SQL text |
| Results table cells | IBM Plex Mono | Data values, NULL |
| Line numbers | IBM Plex Mono | `editor_gutter_fg` color |
| UI labels, buttons | `system-ui` sans-serif | Sidebar, toolbar, tab labels |
| Timestamps, metadata | `system-ui` sans-serif | `text_secondary` / `history_timestamp` |

---

## Common Compositions

```zig
// Run button — blue, prominent
Icon(.run).font(16, 600, .palette(.tint)).end();

// Stop button — error red
Icon(.stop).fontSize(16).fontColor(.palette(.status_error)).end();

// Success row count
Icon(.success).fontSize(13).fontColor(.palette(.status_success)).end();

// Sidebar table node
Icon(.table).fontSize(13).fontColor(.palette(.text_secondary)).end();

// Active tab accent underline — use tab_active_accent
// Inactive tab label — use tab_inactive_fg

// NULL value in results
Text("NULL").fontColor(.palette(.table_null_fg)).font("IBM Plex Mono", 12).end();

// History selected entry background
View().bgColor(.palette(.history_selected_bg)).end();
```
