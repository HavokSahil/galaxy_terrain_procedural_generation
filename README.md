# 🌌 Procedural Galaxy Generator (CSP-based)

This project is a galaxy generator that uses **Constraint Satisfaction Problems (CSP)** to build smooth, realistic galaxies on a 2D grid. Instead of random noise, it uses constraints and heuristics to control how galactic regions like deep space, mid-zones, and glowing cores are placed and connected.

---

## Content

- A **Processing sketch** (`.pde` code) that draws and refines a galaxy in real time.

---

## How it works

- Each grid cell represents a galactic region (space, edge, core, etc.).
- Initial assignments are based on radial heuristics.
- A **Min-Conflicts** algorithm resolves any invalid neighbor placements.
- Constraint rules are enforced using a `notAllowed[][]` matrix.

---

##  Themes

Try different palettes by changing the `shades[]` array in code:
- `shades1`: Purple–lavender vibe
- `shade2`: Spooky/dark aesthetic
- `shades`: Soft calming blues

---

## Run it

1. Install [Processing](https://processing.org/)
2. Open the `.pde` file
3. Run — watch the galaxy evolve!

---

## Files

- `galaxy_generator.pde`: main code
- `images/`: example outputs

---

## Author

**Sahil Raj**  
CS2203 - Artificial Intelligence  
Roll No: 2301CS41

---


