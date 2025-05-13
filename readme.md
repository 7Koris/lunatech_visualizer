<!-- [![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![Unlicense License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url] -->

<br />
<div align="center">
  <h3 align="center">LunaTech Visualizer</h3>
  <img src="docs/assets/lunatechsmall.png" alt="i"> 
  <p align="center">
    realtime visualizations powered by LunaTech
  </p>
  <p align="center">
    <a href="https://github.com/7Koris/lunatech">The Lunatech project</a>

</div>


<!-- ABOUT THE PROJECT -->
## About The Project

LunaTech Visualizer a front-end enabled by the LunaTech realtime audio analysis server. LunaTech visualizer is designed to facilitate the development of realtime music visualizations quickly and easily for musicians, hobbyists, and Godot developers.

LunaTech Server is provided alongside LunaTech Visualizer as a binary and is started automatically when the visualizer is started.

## Getting Started

LunaTech Visualizer currently only supports Linux. Support for other platforms is planned.

### Installation

1. Clone or download this repository as a zip file.

## Usage
Press F5 or the 'Play' button to start the visualizer.

When you first Open LunaTech Visualizer, you'll be greeted with a running visualization as well as a text hint with some basic controls.
![alt text](/docs/assets/image.png)
You can hide the hint by pressing the 'H' key. If you press 'Esc', you'll be greeted by a settings menu.
![alt text](/docs/assets/image-3.png)
Settings are divided by whether they affect the audio analysis server or the visualization frontend. You can change the port the analysis server broadcasts or toggle the server listening to audio input. LunaTech uses whatever default audio device is set within your system's given audio manager.

Visualizer settings let you change how long it takes for scenes to change alongside randomized change time variance. A scene shuffle toggle is provided alongside a fullscreen toggle. More Settings will be added in the future.
![alt text](/docs/assets/image-4.png)
If you click the 'Scene Select' tab, some colored checkboxes will appear. These options appear based on whatever scene files are in the 'res://assets/scenes/vis_scenes' folder. LunaTech scans this folder during runtime for changes as well, so if you really wanted to, you could drag in or remove scenes while the visualizer is running. You can enable or disable scenes from the scene queue by unselecting the tickbox next to their name.

### Creating a new scene visualization scene

To get started making your own visualization, you'll want to create a new scene in the 'res://assets/scenes/vis_scenes' folder. This scene will automatically be added to the scene queue.

After you've done so, simply attatch a script to a node in the scene and script the behavior for animated elements. For shader controls, you can set their shader parameters using godots built-in getters and setters.
![alt text](/docs/assets/image-1.png)
A global object is provided within LunaTech Visualizer called 'OscClient'. Currently, it's a modified version of the 'GodOSC' plugin with its own recieving thread. It provides a simple global interface for accessing the data sent by the LunaTech analysis server. To access and audio feature, simply type 'OscClient.feature_name'. Supported features are listed below:

### OSC Addresses
- broad_range_rms
- low_range_rms
- mid_range_rms
- high_range_rms
- zcr
- spectral_centroid
- flux

It's suggested to experiment with these features to get a feel for how they affect your visualization. You may want to add coefficients or interactions between them.

## Roadmap
- [X] Interface with LunaTech Server
- [X] Basic Scene Change System
- [ ] More GUI settings
- [ ] Scene State Caching
- [ ] Scene Loading Optimization 
- [ ] More modular scene & queue system 
- [ ] Unit Testing
- [ ] Improved Github page and Developer docs
- [ ] Windows support
- [ ] Visualization Community Download Pages

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

## Acknowledgments
- [GodOSC Plugin](https://github.com/afarra6/godOSC)
- [Godot GPU Trails Plugin](https://github.com/celyk/GPUTrail)
- [Skull Model](https://sketchfab.com/3d-models/vhf-skull-point-cloud-47107f5d88f24cc9b051642501a64a9e#download)
- [Brain Model](https://sketchfab.com/3d-models/brain-point-cloud-c427ea0aee214141a78eba37bf9b76bb#download)
- [Moon Heightmap](https://svs.gsfc.nasa.gov/4720/)
- [2D Glitch Shader](https://godotshaders.com/shader/glitch-effect-shader-for-godot-engine-4/)
- [Protean Clouds Shader](https://godotshaders.com/shader/protean-clouds-2/)
- [Readme Template](https://github.com/othneildrew/Best-README-Template)
