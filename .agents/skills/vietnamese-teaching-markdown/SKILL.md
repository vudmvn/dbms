---
name: vietnamese-teaching-markdown
description: "Use when you provide a URL to a technical article, especially about DBMS, programming, data, or AI, and want a Vietnamese Markdown teaching note with cleaned content, relevant downloaded images, learning objectives, CLO table, summary, key terms, 8 quiz questions, exercises, and answer key."
argument-hint: URL bài viết kỹ thuật cần chuyển thành Markdown giảng dạy
user-invocable: true
disable-model-invocation: false
---

# Vietnamese Teaching Markdown

## When to Use
- The input is a URL to a technical article or reference page.
- The source topic is likely DBMS, databases, programming, data, AI, or related technical material.
- The goal is to turn the source into a Vietnamese teaching note in Markdown; perform a faithful translation into Vietnamese — do not summarize or omit content.

## What This Skill Produces
Create a clean Vietnamese Markdown file that is suitable for teaching and self-study. The file should include:
- A clear title and short introduction
- Learning Objectives
- Learning Outcomes in a CLO table
- A concise Summary
- Key Terms
- A structured explanation of the article's main ideas
- Relevant images downloaded from the source or directly related teaching visuals, when available and useful
- Quiz after each major subsection or concept block
- 8 multiple-choice quiz questions, each with 4 answer choices
- 3 to 5 exercises or practice tasks
- Answer key for the quiz placed at the end of the file

## Workflow
1. Read the main content from the provided URL.
2. Ignore page chrome and noise such as ads, nav menus, footers, cookie banners, popups, share widgets, recommended articles, unrelated sidebars, and comment sections.
3. Identify the article's core topic, major sections, key definitions, processes, examples, and any important constraints or caveats.
4. Perform a faithful translation of the source into Vietnamese without summarizing or omitting content. Preserve the original structure, headings, examples, and technical details; remove only ads, navigation, unrelated UI, and obvious noise.
5. Identify any images in the source that support teaching content, download only the relevant ones, and ignore decorative visuals, ads, logos, UI screenshots, and unrelated thumbnails.
6. If no suitable teaching image exists, skip images rather than forcing unrelated visuals.
7. Place each downloaded image at the most relevant point in the Markdown, close to the section it explains, and center it using HTML so it renders consistently.
8. Add clear alt text or a short caption in Vietnamese near the image.
9. Organize the Markdown with instructional structure, including headings and short explanatory paragraphs or bullets where helpful.
10. Add a Learning Objectives section that states what the learner should be able to do after reading.
11. Add a Learning Outcomes section as a CLO table with at least these columns:
   - CLO
   - Outcome
   - Cognitive level
   - Evidence or assessment
12. After each major subsection or concept block, add a Quiz of 1 to 3 multiple-choice questions focused only on that subsection.
13. Each Quiz question must have 4 answer choices.
14. Place each subsection Quiz immediately after the subsection it assesses, before moving to the next section.
15. Add a Summary section that compresses the main ideas into a short review.
16. Add a Key Terms section with important terms, acronyms, and concise Vietnamese explanations.
17. Add 8 multiple-choice questions that assess understanding of the article, each with 4 answer choices.
18. Add 3 to 5 exercises that range from recall to application.
19. Put the quiz answer key at the very end of the file.

## Output Rules
- Write in Vietnamese.
- Use Markdown headings and tables clearly.
- Center downloaded visuals in the Markdown output using HTML wrappers such as `<p align="center">` or equivalent, and keep image links relative to the Markdown file whenever possible.
- Keep the tone suitable for teaching and revision.
- Prefer concise but accurate explanations.
- Do not include unrelated content from the source page.
- If the topic is DBMS, save the file under `docs/dbms/`.
- If the topic is DBMS, use a lowercase filename with no accents and hyphens between words.
- If images are downloaded, store them in a nearby assets folder using lowercase, no-accent, hyphenated filenames.
- Render inserted images centered, with concise Vietnamese alt text and an optional short caption near the image.
- If the topic is not DBMS, choose a suitable docs location and follow the same lowercase, no-accent, hyphenated filename convention.

## Quality Checks
- The article's main point is preserved accurately.
- Advertising and irrelevant page elements are removed.
- Downloaded images are relevant, readable, and inserted near the teaching point they support.
- Each major subsection has a Quiz directly after it.
- The teaching note reads naturally in Vietnamese.
- Learning Objectives and CLO outcomes are aligned with the content.
- The quiz questions are answerable from the note.
- The answer key matches the quiz and is located at the end.

## Suggested Markdown Structure
1. Title
2. Introduction
3. Learning Objectives
4. Main Content
5. Learning Outcomes (CLO table)
6. Images (if useful)
7. Quiz
8. Summary
9. Key Terms
10. Quiz (8 questions)
11. Exercises
12. Answer Key
