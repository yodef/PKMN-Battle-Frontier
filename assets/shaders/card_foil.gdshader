shader_type canvas_item;

uniform int foil_style : hint_range(0, 4) = 0; // 0 = Rare (Silver Sheen), 1 = Epic (Cosmic Galaxy), 2 = Legendary (Prismatic Gold), 3 = Gym Leader Ace (Emblem Badge Cross-Beam), 4 = Elite Four Ace (Royal Dragon Crown)
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
		// Estilo 3 (Gym Leader Ace): Haz en cruz diagonal (Emblema de Medalla de Gimnasio)
		// Estilo 4 (Elite Four Ace): Haz cuádruple hiper-radiante con aura de campeón imperial
		if (foil_style == 1) {
			float dist2 = abs(diag - (band_pos - 0.20));
			float beam2 = smoothstep(sheen_width * 0.8, 0.0, dist2) * 0.45;
			sweep_sheen += beam2;
		} else if (foil_style == 2) {
			float dist2 = abs(diag - (band_pos - 0.20));
			float beam2 = smoothstep(sheen_width * 0.8, 0.0, dist2) * 0.45;
			float dist3 = abs(diag - (band_pos + 0.15));
			float beam3 = smoothstep(sheen_width * 0.65, 0.0, dist3) * 0.35;
			sweep_sheen += beam2 + beam3;
		} else if (foil_style == 3) {
			// Gym Leader Ace: Haz en cruz (diag principal + contra-diagonal simétrica de insignia/medalla)
			float cross_diag = (uv.x * cos(-sheen_angle) + uv.y * sin(-sheen_angle));
			float cross_max = cos(-sheen_angle) + sin(-sheen_angle);
			float cross_pos = mix(-0.25, cross_max + 0.25, t);
			float dist_cross = abs(cross_diag - cross_pos);
			float cross_beam = smoothstep(sheen_width * 0.85, 0.0, dist_cross) * 0.55;
			
			float dist_crest = abs(diag - (band_pos - 0.18));
			float crest_beam = smoothstep(sheen_width * 0.70, 0.0, dist_crest) * 0.35;
			sweep_sheen += cross_beam + crest_beam;
		} else if (foil_style == 4) {
			// Elite Four Ace: Haz cuádruple ultra-radiante con pulsación de poder de dragón/élite
			float dist_e1 = abs(diag - (band_pos - 0.22));
			float dist_e2 = abs(diag - (band_pos + 0.18));
			float dist_e3 = abs(diag - (band_pos - 0.38));
			float b1 = smoothstep(sheen_width * 0.85, 0.0, dist_e1) * 0.50;
			float b2 = smoothstep(sheen_width * 0.70, 0.0, dist_e2) * 0.40;
			float b3 = smoothstep(sheen_width * 0.55, 0.0, dist_e3) * 0.30;
			sweep_sheen += b1 + b2 + b3;
		}
		sweep_sheen = clamp(sweep_sheen, 0.0, 1.0);
		
		// Tonalidad base
		vec3 base_foil = mix(foil_color_1.rgb, foil_color_2.rgb, sin(diag * 4.0 + TIME * 0.6) * 0.5 + 0.5);
		vec3 final_color = base_foil;
		
		// Espectro prismático arcoíris
		if (rainbow_mix > 0.01) {
			float rainbow_phase = (diag / max_diag) * 6.28 + TIME * (foil_style == 4 ? 1.2 : 0.8);
			vec3 rainbow = vec3(
				sin(rainbow_phase) * 0.5 + 0.5,
				sin(rainbow_phase + 2.094) * 0.5 + 0.5,
				sin(rainbow_phase + 4.188) * 0.5 + 0.5
			);
			final_color = mix(base_foil, rainbow, rainbow_mix);
		}
		
		// Brillo ambiental
		float ambient = ambient_foil * (sin(diag * 3.5 - TIME * 0.4) * 0.3 + 0.7);
		
		// Destellos y estrellas
		float sparkle = 0.0;
		if (sparkle_strength > 0.01) {
			float grid_size = 48.0;
			if (foil_style == 2) {
				grid_size = 36.0;
			} else if (foil_style == 3) {
				grid_size = 32.0; // Gemas de medalla
			} else if (foil_style == 4) {
				grid_size = 28.0; // Grandes destellos de corona de Campeón
			}
			vec2 cell_id = floor(uv * grid_size);
			vec2 cell_uv = fract(uv * grid_size) - vec2(0.5);
			float rnd = hash(cell_id);
			
			if (rnd > sparkle_density) {
				float star_dist = length(cell_uv);
				float star_radius = (foil_style == 4) ? 0.44 : ((foil_style == 3) ? 0.40 : 0.38);
				float star = smoothstep(star_radius, 0.0, star_dist);
				float sparkle_time = sin(TIME * (foil_style == 4 ? 8.5 : 7.0) + rnd * 6.28) * 0.5 + 0.5;
				sparkle = star * pow(sparkle_time, 2.0) * sparkle_strength * (sweep_sheen * 1.6 + ambient * 1.5 + 0.15);
			}
		}
		
		float mult = 1.4;
		if (foil_style == 2) mult = 2.0;
		else if (foil_style == 3) mult = 2.2;
		else if (foil_style == 4) mult = 2.6;
		
		vec3 final_rgb = final_color + vec3(sparkle * mult);
		float final_alpha = (sweep_sheen * 0.85 + ambient + sparkle * 0.6) * foil_color_1.a * intensity;
		
		COLOR = vec4(final_rgb, clamp(final_alpha, 0.0, 0.95));
	}
}
