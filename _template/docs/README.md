# Documentation

Human-facing docs for this skill repo. **Not** part of the installable package under `skills/`.

## Layout

```text
docs/
├── README.md          # this index
├── screenshots/       # curated gallery for README (optional)
├── architecture/      # design / roadmap (optional)
└── research/          # external research notes (optional)
```

## Separation

| Tree | Holds |
| --- | --- |
| `docs/` | Guides + curated screenshots |
| `tests/` | Offline CI + live **specs** (prompts, fixtures) |
| `artifacts/` | **Generated** outputs from live runs |

Do **not** put raw live benchmark images under `docs/`. See incubator
`schema/skill-repo.md` § docs / tests / artifacts.
