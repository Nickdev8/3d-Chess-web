[![Live Demo](https://img.shields.io/badge/Live-Demo-blue?style=for-the-badge&logo=firefox)](https://chess.nickesselman.nl)
[![Godot Engine](https://img.shields.io/badge/Engine-Godot%204.0-blue?style=for-the-badge&logo=godot-engine)](https://godotengine.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge)]()

# 3D Browser Chess

A fully interactive, 3D chess game running entirely in the browser, built with Godot Engine

## Live Demo

Try it now: [chess.nickesselman.nl](https://chess.nickesselman.nl)

## Controls
Left mouse for rotating, scroll for zooming and right mouse button for panning around the 3d scene.
Click on any piece and move it.

## Technologies

- **Godot Engine 4.0**  
  Scene‑driven architecture, GDScript logic.
- **HTML5 & CSS3**  
  <s>UI overlay.</s> _Revoked,_ This broke me :')
  
- **Nginx**  
  Most of my time was spend setting up nginx with the subdomain chess. and making it easy to add more subdomains in the future

## Getting Started

* **Clone the repo**  
   ```bash
   git clone https://github.com/Nickdev8/3d-Chess-web.git
   cd 3d-Chess-web
   godot .


