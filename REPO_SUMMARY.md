# Repository Summary

Last reviewed: 2026-07-03

This file is a quick map of the repository so future updates do not need to
rescan the whole folder before making small changes.

## Purpose

This repository hosts DBMS and MySQL learning materials as a GitHub Pages site.

Published site:

- https://vudmvn.github.io/dbms-course

## Site Architecture

- GitHub Pages is built with Jekyll.
- `_config.yml` controls the site metadata, URL, base path, Markdown behavior,
  included content folders, and excluded temporary/build files.
- `index.md` is the homepage and table of contents for the course.
- Content Markdown files are stored under topic folders, usually with local
  `images/` subfolders beside each lesson.
- GitHub Actions builds the site into `_site` and deploys it to Pages.

Important Jekyll settings:

- `url`: `https://vudmvn.github.io`
- `baseurl`: `/dbms-course`
- `markdown`: `kramdown`
- `permalink`: `pretty`
- Explicitly included folders: `DBMS_Basic`, `lectures`
- Course content is organized under `lectures/` (`lectures/introduction/`, `lectures/entity-relationship-model/`, `lectures/relational-model-and-functional-dependencies/`, `lectures/normalization/`, and `lectures/MySQL/`) and covered by the Pages workflow trigger paths (`lectures/**`).
- Excluded temporary/build files include `TEMP_MARKDOWN_INPUT.md`, `node_modules`,
  and common LaTeX/log output files.

## Top-Level Structure

- `.github/workflows/pages.yml`
  - GitHub Actions workflow for building and deploying GitHub Pages.
  - Runs on push to `master` or `main` when relevant site files change.
  - Can also be run manually with `workflow_dispatch`.

- `assets/`
  - Shared site assets.
  - `assets/files/` contains course files such as the syllabus PDF.
  - `assets/images/` contains shared images such as book covers.

- `lectures/`
  - Contains all lecture modules:
    - `lectures/introduction/`: Core DBMS introduction lessons.
    - `lectures/entity-relationship-model/`: Conceptual modeling lessons and ER labs.
    - `lectures/relational-model-and-functional-dependencies/`: Relational schema, ER-to-relational mapping, keys, functional dependency, attribute closure, and schema design lessons.
    - `lectures/normalization/`: Normal forms overview plus 1NF, 2NF, 3NF, and 4NF lessons.
    - `lectures/MySQL/`: MySQL lessons and how-to guides organized by topic folder (`mysql-server`, `database-administration`, `data-definition`, `querying-data`, `index-optimization`, `data-modification-transactions`, and `programmability`).
- `_config.yml`
  - Jekyll/GitHub Pages configuration.

- `index.md`
  - Homepage and manual navigation index.
  - Supports a Vietnamese/English language switcher on the same page.
  - When adding a new published lesson, add its link here.

- `DEPLOYMENT_RULES.md`
  - Human-readable deployment notes and update process.

- `REPO_SUMMARY.md`
  - This quick repository map and maintenance note file.

- `TEMP_MARKDOWN_INPUT.md`
  - Temporary Markdown input file.
  - Currently contains temporary lesson input metadata and is
    excluded from the published site.

## Content Inventory

Current homepage sections:

- Course syllabus
  - `assets/files/Syllabus_Database_VNUIS.pdf`

- Reference books
  - Shared cover images in `assets/images/`

- Introduction
  - `introduction/01-introduction-to-dbms/introduction-to-dbms.md`
    - Slides: `gioi_thieu_csdl_vi_beamer.pdf`
    - Slides: `gioi_thieu_csdl_en_beamer.pdf`
    - Web: `introduction.html`
  - `introduction/02-dbms-system-architecture/dbms-system-architecture.md`
    - Slides: `kien_truc_dbms_vi.pdf`
    - Slides: `kien_truc_dbms_en.pdf`
  - `introduction/03-three-schema-architecture/three-schema-architecture.md`
    - Slides: `data_independence_beamer_pdflatex.pdf`
    - Slides: `data_independence_beamer_english_pdflatex.pdf`
  - `introduction/04-choosing-the-right-dbms/choose-right-dbms.md`
    - Slides: `choose-right-dbms-vi.pdf`
    - Slides: `choose-right-dbms-en.pdf`

- Entity Relationship Model
  - `entity-relationship-model/data-modeling/data-modeling.md`
  - `entity-relationship-model/er-model/er-model.md`
    - Slides: `er-model-vi.pdf`
    - Slides: `er-model-en.pdf`
    - Source: `er-model-vi.tex`
    - Source: `er-model-en.tex`

- ER Model Labs
  - `entity-relationship-model/lab-er-model-1.md`
    - Shown on the homepage as "Lab 1: ER model basics".
    - Duration: 60m.
    - Difficulty: Beginner.

- MySQL Server
  - `MySQL/mysql-server/gioi-thieu-mysql/gioi-thieu-mysql.md`
  - `MySQL/mysql-server/huong_dan_cai_dat_mysql_windows/huong_dan_cai_dat_mysql_windows.md`
  - `MySQL/mysql-server/huong_dan_cai_dat_mysql_workbench_windows/huong_dan_cai_dat_mysql_workbench_windows.md`
  - `MySQL/mysql-server/huong_dan_ket_noi_mysql_command_options/huong_dan_ket_noi_mysql_command_options.md`
  - `MySQL/mysql-server/huong_dan_ket_noi_mysql_vscode/huong_dan_ket_noi_mysql_vscode.md`
  - `MySQL/mysql-server/mysql-sample-database/mysql-sample-database.md`
  - `MySQL/mysql-server/load-sample-database/load-sample-database.md`
  - `MySQL/mysql-server/storage-engine/storage-engine.md`
  - `MySQL/mysql-server/start-stop-MySQL/start-stop-MySQL.md`

- MySQL Database Administration
  - `MySQL/database-administration/database/create-use-drop-database.md`
  - `MySQL/database-administration/show-command.md`
  - `MySQL/database-administration/user-administration.md`
  - `MySQL/database-administration/security/encryption-decryption.md`

- MySQL SQL Statements
  - `MySQL/data-definition/`
  - `MySQL/querying-data/`
  - `MySQL/index-optimization/`
  - `MySQL/data-modification-transactions/`
  - `MySQL/programmability/`
## Canonical Lessons and Duplicate Reduction

Some older focused lessons remain in the repository for source preservation, but the homepage links to broader canonical lessons to reduce duplicated navigation content.

- `MySQL/database-administration/database/create-use-drop-database.md` is the canonical lesson for creating, selecting, and dropping databases.
  - Supersedes the separate `create-database`, `select-database`, and `drop-database` lessons in the homepage navigation.
- `MySQL/data-definition/create-table-statement.md` and `MySQL/data-definition/table/tables.md` are the canonical lessons for `CREATE TABLE`, constraints, and table lifecycle topics.
  - Supersedes the separate basic `sql-create-table` homepage entry.
- `MySQL/data-modification-transactions/modifying-data.md` is the canonical lesson for INSERT, UPDATE, DELETE, and advanced modification topics.
  - Supersedes the separate `insert-update-delete` homepage entry.
## Deployment Flow

Current working branch and push target:

- Local branch: `deploy-dbms-pages`
- Tracking branch: `course/main`
- GitHub Pages repo remote: `course` -> `https://github.com/vudmvn/dbms-course.git`
- Source/development remote: `origin` -> `https://github.com/vudmvn/dbms.git`
- Because the local branch name differs from `main`, push with:

```powershell
git push course HEAD:main
```

Recommended commit/push process:

1. Check scope first:

```powershell
git status -sb
git diff -- <paths>
```

2. Stage only intended files. Do not stage `TEMP_MARKDOWN_INPUT.md` unless
   explicitly requested. For ER model lessons, keep `.webp` files for Markdown
   pages and matching `.png` files for LaTeX/PDF builds when both are referenced.

```powershell
git add -- <intended-files>
```

3. Commit with a short message:

```powershell
git commit -m "Short change summary"
```

4. Push to the Pages repository:

```powershell
git push course HEAD:main
```

5. Confirm the workflow:

```powershell
gh run list --repo vudmvn/dbms-course --limit 5
```

6. Check the public page and any images directly with `Invoke-WebRequest`.

General content flow:

1. Add or edit Markdown content under `lectures/` (e.g. `lectures/introduction/`, `lectures/entity-relationship-model/`, `lectures/relational-model-and-functional-dependencies/`, `lectures/normalization/`, or `lectures/MySQL/`).
2. Add any lesson images inside that lesson folder, usually under `images/`.
3. Update `index.md` if the lesson should appear on the homepage.
4. Commit and push to `course/main`.
5. GitHub Actions workflow `Deploy GitHub Pages` builds with Jekyll and deploys.

Workflow trigger paths:

- `lectures/**`
- `index.md`
- `_config.yml`
- `DEPLOYMENT_RULES.md`
- `.github/workflows/pages.yml`

## Update Notes

- 2026-06-04: Refreshed `entity-relationship-model/er-model/` attribute and relationship
  image references against the GeeksforGeeks source, then regenerated the
  Vietnamese and English ER model PDFs.
- 2026-06-04: Expanded `MySQL/mysql-server/storage-engine/` into a full lecture, kept its
  `images/` placeholder, and linked it from the bilingual homepage.
- 2026-06-04: Added `entity-relationship-model/lab-er-model-1.md` and a bilingual Labs
  section in `index.md`.
- 2026-06-04: Refreshed the repository summary against current `index.md`,
  `_config.yml`, workflow paths, branch, and remotes.
- 2026-06-01: Added bilingual PDF slides and Beamer source files for
  `introduction/data-independence/`, and linked the slides from `index.md`.
- 2026-06-01: Expanded `entity-relationship-model/er-model/` with ER diagram illustrations
  for entities, attributes, relationships, cardinality, participation, and ER
  diagram construction steps.
- 2026-06-01: Added Vietnamese and English ER model Beamer slides/PDFs, linked
  them from `index.md`, and refreshed ER cardinality/participation images to
  match the GeeksforGeeks source page.
- 2026-06-01: Added `MySQL/mysql-server/mysql-sample-database/` with the classicmodels
  sample database lesson and local ER diagram image.
- 2026-05-31: Added `entity-relationship-model/`, `relational-model-and-functional-dependencies/`, and `normalization/` lessons and renamed the folder from
  `Data Modeling` to avoid space-encoded URLs.
- 2026-05-31: Added `entity-relationship-model/**`, `relational-model-and-functional-dependencies/**`, `normalization/**` to the Pages workflow trigger paths so
  edits in that folder rebuild GitHub Pages.
- 2026-05-31: Documented the practical commit/push flow for the
  `deploy-dbms-pages` branch and `course/main` remote.
- 2026-05-28: Added this repository summary file.
- 2026-05-28: Updated `index.md` with a Vietnamese/English language switcher.
- 2026-05-27: Deployment rules note says the latest deploy activation was on this date.
- Current git status during review was clean before editing this file.

## Maintenance Notes

- Keep lesson links in `index.md` relative to the repository root.
- Because `_config.yml` uses `baseurl: /dbms-course`, avoid hard-coding root-relative
  links like `/assets/...` unless they are passed through Jekyll URL filters.
- For lesson pages using `permalink`, prefer a permalink that matches the lesson
  folder, for example `permalink: /entity-relationship-model/er-model/`. This lets local
  image links such as `images/example.png` work both locally and on GitHub Pages.
- If a page is served at a nested pretty URL such as
  `/folder/lesson/lesson/`, relative image links like `images/x.png` will point
  to the wrong folder on the website. Either add an appropriate `permalink` or
  adjust image paths deliberately.
- Markdown files do not need YAML front matter because `jekyll-optional-front-matter`
  is enabled.
- If adding a new top-level publishable content folder, update
  `.github/workflows/pages.yml` trigger paths. Add it to `_config.yml` under
  `include` only when Jekyll needs explicit inclusion for that path.
- Avoid relying on `TEMP_MARKDOWN_INPUT.md` for published content; it is excluded.
- PowerShell currently prints a local profile warning about missing
  `D:\Anaconda\Scripts\conda.exe`; command results are still usable despite that
  warning.
