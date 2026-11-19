# Arrow Escape — Visual Design System (DESIGN.md)
**Project ID:** 12382636482874179328  
**Design System Asset:** assets/12463757339717558344  
**Theme:** Neo-Minimalist Dark Slate with Vibrant Neon Accents  

---

## 1. Brand Identity & Aesthetic Philosophy
- **Style:** Neo-Minimalist Dark, tactile, responsive puzzle game.
- **Visual Personality:** Premium, calm, focused, modern, non-distracting.
- **Iconography Policy:** Strictly 100% custom SVG vector icons. Default OS/browser emojis are strictly prohibited across all screens and UI states.

---

## 2. Color Palette & Design Tokens

### 2.1 Core Surface Colors
| Token Name | Hex Code | Purpose |
| :--- | :--- | :--- |
| `surface-background` | `#09090B` / `#0B0F19` | Deepest obsidian slate background (reduces OLED battery usage and eye fatigue) |
| `surface-card` | `#111827` / `#0F172A` | Glassmorphic dark card layer |
| `surface-card-subtle` | `rgba(255, 255, 255, 0.05)` | Translucent hover and inner tile borders |
| `surface-border` | `#1E293B` | Structural boundary lines and dividing borders |

### 2.2 Brand & Accent Colors
| Token Name | Hex Code | Role |
| :--- | :--- | :--- |
| `brand-primary` | `#6366F1` | Electric Indigo — Primary Action CTA, Hero branding |
| `brand-primary-hover`| `#4F46E5` | Deep Indigo — Pressed button state |
| `accent-secondary` | `#10B981` | Emerald Green — Active status pills, safe moves, accuracy badges |
| `accent-gold` | `#F59E0B` | Warm Amber Gold — Coins, 3-Star ratings, active hints |
| `accent-warning` | `#F43F5E` | Rose Crimson — Heart loss, out of moves, critical alert |
| `accent-cyan` | `#06B6D4` | High-tech Cyan — Level numbers, chapter badges, trail effects |

---

## 3. Typography Scale
- **Headline Font:** `Plus Jakarta Sans` (Bold, ExtraBold, Geometric, Letter-spacing: `-0.02em` to `+0.05em`)
- **Body Font:** `Inter` (Regular, Medium, SemiBold, high readability on small mobile screens)

| Level | Size | Weight | Line Height | Usage |
| :--- | :--- | :--- | :--- | :--- |
| `display-lg` | 32px | 800 (Bold) | 1.2 | Hero title ("ARROW ESCAPE", "VICTORY!") |
| `display-md` | 24px | 700 (Bold) | 1.25 | Stage headers ("STAGE 42", "GAME MODES") |
| `heading-sm` | 18px | 600 (SemiBold)| 1.3 | Card titles, mode cards |
| `body-md` | 14px | 500 (Medium) | 1.4 | Descriptions, button labels |
| `caption-sm` | 11px | 600 (SemiBold)| 1.2 | Badge tags, subtext, timers |

---

## 4. UI Components & Geometries

### 4.1 Corner Roundness (`ROUND_TWELVE` standard)
- **Standard Button & Card Radius:** `12px` to `16px` (`rounded-xl` / `rounded-2xl`).
- **Interactive Floating Pills & Badges:** `9999px` (`rounded-full`).
- **Arrow Puzzle Tiles:** `14px` squircle with `2px` tactile bevel and inner gradient.

### 4.2 Interactive Button System
1. **Primary Hero CTA:**
   - Background: Gradient `linear-gradient(135deg, #6366F1, #4F46E5)`
   - Glow Shadow: `0 0 20px rgba(99, 102, 241, 0.4)`
   - Padding: `16px 24px`, Text: Bold Uppercase with forward vector arrow.
2. **Secondary Rewarded CTA:**
   - Background: Glassmorphic dark slate with glowing Amber border (`#F59E0B`)
   - Purpose: "Watch Ad for +1 Life", "2X Rewards".
3. **Tertiary Icon Buttons:**
   - Circular glassmorphic disc (`48px x 48px`), border `1px solid rgba(255,255,255,0.1)`.

---

## 5. Screen Manifest & Generated Design Assets

| # | Screen Name | HTML File | PNG Screenshot | Stitch Screen ID |
| :--- | :--- | :--- | :--- | :--- |
| 1 | **Home Screen** | `home_screen.html` | `home_screen.png` | `54eb0d59eda941afafb5cdaf1b5580ea` |
| 2 | **Main Gameplay Screen** | `gameplay_screen.html` | `gameplay_screen.png` | `7bd52fc52b2e4ea4b7b76f427c250918` |
| 3 | **Level Completed Screen** | `level_completed_screen.html` | `level_completed_screen.png` | `138717dc8c8648a9b532af7b338e3ed0` |
| 4 | **Level Failed / Recovery** | `level_failed_screen.html` | `level_failed_screen.png` | `29d39bee526248dc8502b1377188606d` |
| 5 | **Game Modes & Difficulty** | `game_modes_screen.html` | `game_modes_screen.png` | `247c1c28e1964ce6a27c9803b42f4bf6` |
| 6 | **Level Selection Map** | `level_selection_screen.html` | `level_selection_screen.png` | `b0be3d567326425d825cd4f60483fafe` |
| 7 | **Settings & Preferences** | `settings_screen.html` | `settings_screen.png` | `683cbd0c2937481dad67338316c4e5ca` |
| 8 | **Collections & Arrow Skins**| `collections_screen.html`| `collections_screen.png` | `4e1152c78f6a4bf89c8794e59e4275de` |
| 9 | **Global Leaderboard** | `leaderboard_screen.html` | `leaderboard_screen.png` | `30ed088de7fa4be1b3049bcc5293ad6a` |
