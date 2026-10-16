# DevSync

**Secure AI Project Collaborator**

DevSync is a mobile platform that helps developers find collaborators and projects for open-source work. It uses AI to match users to projects based on their GitHub activity, declared skills, and experience level, then gives them the tools to form a team, assign roles, chat, and manage tasks in one place.

> **Status:** Work in progress. This README is a temporary version and will be updated as the project develops.

---

## Table of Contents

- [The Problem](#the-problem)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [Project Timeline](#project-timeline)
- [Team](#team)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
- [Contributing](#contributing)

---

## The Problem

- Developers, especially students and juniors, struggle to find open-source projects that match their real skills.
- Project owners struggle to find contributors with the right skill mix, and often miss critical roles in their team.
- Existing platforms offer manual search and no explanation of why a project or person is a good fit.

## Key Features

| Module                         | Features                                                                                                 |
| ------------------------------ | -------------------------------------------------------------------------------------------------------- |
| **Authentication and Profile** | Sign in with Google or Email, GitHub/Behance links, GitHub data import                                   |
| **Discovery and AI Matching**  | Project discovery, AI recommendations, explanation of every match, cross-skill match, skill gap analysis |
| **Project Management**         | Create projects with difficulty and type, task management                                                |
| **Project AI Assistance**      | AI project setup, AI role generator, missing role alert                                                  |
| **Collaboration**              | Collaboration requests, team invites, shared links, push notifications (FCM)                             |
| **Communication**              | 1-1 chat, team chat, workspace, community                                                                |
| **Release and Quality**        | Free and Pro flavors, code obfuscation, Android App Bundle, runtime permissions                          |

## Tech Stack

| Layer             | Technology                                                           |
| ----------------- | -------------------------------------------------------------------- |
| **Client**        | Flutter, layered architecture, BLoC/Cubit                            |
| **Backend**       | Firebase Auth, Firestore, Cloud Functions, Firebase Cloud Messaging  |
| **External APIs** | GitHub REST API                                                      |
| **AI**            | LLM-based matching and explanation with engineered prompts           |
| **Release**       | Flavors (free, pro), Dart code obfuscation, Android App Bundle (AAB) |
| **Tooling**       | Git and GitHub, GitHub Projects, Figma                               |

## Project Timeline

| Phase                                                              | Deadline    |
| ------------------------------------------------------------------ | ----------- |
| Planning and Management, Literature Review, Requirements Gathering | 16 Oct 2026 |
| System Analysis and Design                                         | 6 Nov 2026  |
| Implementation                                                     | 30 Nov 2026 |
| Final Presentation, Testing and Reports                            | 4 Dec 2026  |

## Team

| Member               | Role                                                    |
| -------------------- | ------------------------------------------------------- |
| **Mohraeel George**  | Project Manager, Flutter Lead, architecture and release |
| **Fatma Abdelfatah** | Firebase and backend                                    |
| **Alaa Salah**       | AI and prompts                                          |
| **Malak Abdelhakim** | UI/UX design                                            |
| **Fatma Elsayed**    | Notifications and Cloud Functions                       |
| **Rana Hany**        | Testing and QA                                          |

## Repository Structure

```
DevSync/
├── docs/            # Project documents, diagrams, UI/UX, presentation, references
├── app/             # Flutter application
└── assets/          # Logo, branding, screenshots
```

## Getting Started

Setup instructions will be added once the project skeleton is ready.

Prerequisites (planned):

- Flutter SDK
- Android Studio
- A Firebase project (configuration files are not committed to this repository)

## Contributing

- `main` holds release-ready code and `develop` is the integration branch.
- All work happens on `feature/<module>-<name>` branches.
- No direct pushes to `main` or `develop`; every change goes through a pull request with at least one review.
- Never commit secrets such as `google-services.json`, keystores, or API keys.

---

_Graduation project, DEPI, 2026._
