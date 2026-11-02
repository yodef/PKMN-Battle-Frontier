shader_type canvas_item;

uniform int foil_style : hint_range(0, 2) = 0; // 0 = Rare (Silver Sheen), 1 = Epic (Cosmic Galaxy), 2 = Legendary (Prismatic Gold)
uniform float shimmer_speed : hint_range(0.1, 5.0) = 1.0;
uniform vec4 foil_color_1 : source_color = vec4(0.85, 0.92, 1.0, 0.6);
uniform vec4 foil_color_2 : source_color = vec4(0.70, 0.85, 0.95, 0.4);
uniform float sheen_width : hint_range(0.05, 0.8) = 0.18;
uniform float sheen_angle : hint_range(0.0, 3.1415) = 0.78;
uniform float intensity : hint_range(0.0, 2.0) = 0.85;
uniform float sparkle_strength : hint_range(0.0, 1.0) = 0.0;
uniform float sparkle_density : hint_range(0.5, 0.98) = 0.85;
uniform float ambient_foil : hint_range(0.0, 1.0) = 0.04;
uniform float rainbow_mix : hint_range(0.0, 1.0) = 0.0;
uniform bool is_active = true;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
	if (!is_active) {
		COLOR = vec4(0.0);
	} else {
		vec2 uv = UV;
		float t = fract(TIME * shimmer_speed * 0.22);
		
		float diag = (uv.x * cos(sheen_angle) + uv.y * sin(sheen_angle));
		float max_diag = cos(sheen_angle) + sin(sheen_angle);
		
		float band_pos = mix(-0.25, max_diag + 0.25, t);
		float dist = abs(diag - band_pos);
		
		// Haz de luz primario suave y definido
		float beam = smoothstep(sheen_width, 0.0, dist);
		beam = pow(beam, 2.2);
		float sweep_sheen = beam;
		
		// Estilo 0 (Rare): Haz simple metálico plateado puro, sin estelas ni arcoíris
		// Estilo 1 (Epic): Haz dual cósmico iridiscente
		// Estilo 2 (Legendary): Haz triple radiante supernova
		if (foil_style >= 1) {
			float dist2 = abs(diag - (band_pos - 0.20));
			float beam2 = smoothstep(sheen_width * 0.8, 0.0, dist2) * 0.45;
			sweep_sheen += beam2;
		}
		if (foil_style == 2) {
			float dist3 = abs(diag - (band_pos + 0.15));
			float beam3 = smoothstep(sheen_width * 0.65, 0.0, dist3) * 0.35;
			sweep_sheen += beam3;
		}
		sweep_sheen = clamp(sweep_sheen, 0.0, 1.0);
		
		// Tonalidad base
		vec3 base_foil = mix(foil_color_1.rgb, foil_color_2.rgb, sin(diag * 4.0 + TIME * 0.6) * 0.5 + 0.5);
		vec3 final_color = base_foil;
		
		// Espectro prismático arcoíris (desactivado en Rare, moderado en Epic, vibrante en Legendary)
		if (rainbow_mix > 0.01) {
			float rainbow_phase = (diag / max_diag) * 6.28 + TIME * 0.8;
			vec3 rainbow = vec3(
				sin(rainbow_phase) * 0.5 + 0.5,
				sin(rainbow_phase + 2.094) * 0.5 + 0.5,
				sin(rainbow_phase + 4.188) * 0.5 + 0.5
			);
			final_color = mix(base_foil, rainbow, rainbow_mix);
		}
		
		// Brillo ambiental
		float ambient = ambient_foil * (sin(diag * 3.5 - TIME * 0.4) * 0.3 + 0.7);
		
		// Destellos y estrellas (Desactivado en Rare; estrellas cósmicas en Epic; lluvia dorada en Legendary)
		float sparkle = 0.0;
		if (sparkle_strength > 0.01) {
			float grid_size = (foil_style == 2) ? 36.0 : 48.0;
			vec2 cell_id = floor(uv * grid_size);
			vec2 cell_uv = fract(uv * grid_size) - vec2(0.5);
			float rnd = hash(cell_id);
			
			if (rnd > sparkle_density) {
				float star_dist = length(cell_uv);
				float star = smoothstep(0.38, 0.0, star_dist);
				float sparkle_time = sin(TIME * 7.0 + rnd * 6.28) * 0.5 + 0.5;
				sparkle = star * pow(sparkle_time, 2.0) * sparkle_strength * (sweep_sheen * 1.6 + ambient * 1.5 + 0.15);
			}
		}
		
		vec3 final_rgb = final_color + vec3(sparkle * (foil_style == 2 ? 2.0 : 1.4));
		float final_alpha = (sweep_sheen * 0.85 + ambient + sparkle * 0.6) * foil_color_1.a * intensity;
		
		COLOR = vec4(final_rgb, clamp(final_alpha, 0.0, 0.95));
	}
}
