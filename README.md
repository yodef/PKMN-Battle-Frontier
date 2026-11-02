# Pokémon Battle Frontier (TCG Edition)

![Platform](https://img.shields.io/badge/Platform-PC%20%7C%20Android-blue)
![Engine](https://img.shields.io/badge/Engine-Godot%204.7.2+-478CBF?logo=godotengine&logoColor=white)
![Status](https://img.shields.io/badge/Status-Active%20Development-success)

> **Pokémon Battle Frontier** es un videojuego de estrategia basado en cartas Pokémon TCG desarrollado en el motor **Godot Engine 4**. Diseñado desde cero con interfaz vertical (*portrait*) para una experiencia ágil y táctil tanto en smartphones Android como en computadoras de escritorio.

---

## 🌟 Características Principales

* **Catálogo de 167 Pokémon:** Criaturas completas con tipos elementales, estadísticas base (HP, ATK, DEF, SPD), etapas evolutivas y debilidades/resistencias basadas en la tabla de tipos.
* **Sistema de Combate Dinámico:**
  * Gestión de energía por turnos para ejecutar movimientos.
  * Cartas miniaturas en combate con acabados holográficos (*foil shader*) reactivos y botón de inspección con lupa (🔍).
  * Indicador de velocidad (`SPD: XX`) en tiempo real para Pokémon activos y en banca.
  * Animaciones de evolución durante el combate con curación automática previa al desenlace de victoria/derrota.
  * Reacciones visuales a impactos según el tipo elemental.
* **Modos de Juego:**
  * **Modo Aventura / Campaña:** Recorrido con mapa de nodos visual y peón interactivo (Episodio I: Pewter City Gym vs Bug Catcher, Fisherman, Beautiful Girl y Líder Brock).
  * **Modo Torneo:** 9 combates eliminatorios consecutivos con dificultad creciente y recompensas en Monedas y Diamantes.
  * **Combate Rápido (Quick Battle) y Multijugador Local / Online.**
* **Economía y Progresión:**
  * Tienda, Campamento y Apertura de Sobres (Booster Packs de Kanto).
  * Álbum de Colección con filtros avanzados (*Owned, Stage, Rarity, Tier*).
* **Multiplataforma:**
  * Ejecutable autónomo para **Windows PC** (`.exe` + `.pck`).
  * Paquete instalable para **Android** (`.apk`) con icono adaptativo e inicio vertical nativo a pantalla completa.

---

## 🛠️ Requisitos de Desarrollo

* **Motor:** [Godot Engine 4.7.2+](https://godotengine.org) (Standard Build).
* **Para compilar en Android:**
  * OpenJDK 17.
  * Android SDK (API 34+ / Platform-Tools y Build-Tools).
  * Plantillas de exportación de Godot (*Android Export Templates*).

---

## 🚀 Cómo Ejecutar el Proyecto

1. Clona el repositorio:
   ```bash
   git clone https://github.com/yodef/PKMN-Battle-Frontier.git
   ```
2. Abre **Godot Engine 4**.
3. Haz clic en **Importar** (Import), navega hasta la carpeta del proyecto y selecciona el archivo `project.godot`.
4. Presiona **F5** (o el botón *Play*) para ejecutar la escena principal (`res://scenes/main_menu.tscn`).

---

## ⚖️ Descargo de Responsabilidad (Disclaimer)

Este es un proyecto no comercial creado por y para fanáticos sin fines de lucro. 
Pokémon, sus nombres, marcas registradas e imágenes son propiedad de **Nintendo**, **Creatures Inc.** y **Game Freak**. Este proyecto no está respaldado ni afiliado de ninguna manera con The Pokémon Company.
