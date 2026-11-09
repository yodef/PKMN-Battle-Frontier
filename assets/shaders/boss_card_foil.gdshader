shader_type canvas_item;

// Boss Card Holographic Foil Shader with Crystal Star Pattern
// Exclusively designed for Boss cards (e.g. Crystal Onix)

uniform float star_scale : hint_range(8.0, 40.0) = 16.0;
uniform float star_intensity : hint_range(0.0, 3.0) = 1.35;
uniform float star_density : hint_range(0.1, 1.0) = 0.70;
uniform float shimmer_speed : hint_range(0.1, 4.0) = 0.95;
uniform float sheen_width : hint_range(0.05, 0.6) = 0.24;
uniform float sheen_angle : hint_range(0.0, 3.1415) = 0.65;
uniform vec4 boss_primary_color : source_color = vec4(0.45, 0.85, 1.0, 0.85); // Crystal Ice Cyan
uniform vec4 boss_accent_color : source_color = vec4(0.78, 0.55, 1.0, 0.75); // Amethyst Violet
uniform vec4 star_glow_color : source_color = vec4(0.95, 1.0, 1.0, 1.0); // Pure Diamond White
uniform float ambient_glow : hint_range(0.0, 1.0) = 0.12;
uniform float rainbow_prismatic : hint_range(0.0, 1.0) = 0.55;
uniform bool is_active = true;

// Pseudo-random hash
float hash21(vec2 p) {
	p = fract(p * vec2(234.34, 435.345));
	p += dot(p, p + 34.23);
	return fract(p.x * p.y);
}

// 4-pointed radiant star shape
float radiant_star(vec2 p, float flare_sharpness, float size) {
	float d = length(p);
	if (d > size * 2.2) return 0.0;
	
	// Circular core
	float core = smoothstep(size * 0.45, 0.0, d);
	
	// Cross spikes (horizontal and vertical flares)
	float h_spike = smoothstep(flare_sharpness, 0.0, abs(p.y)) * smoothstep(size * 2.0, 0.0, abs(p.x));
	float v_spike = smoothstep(flare_sharpness, 0.0, abs(p.x)) * smoothstep(size * 2.0, 0.0, abs(p.y));
	
	// Diagonal sub-spikes for 8-point crystal brilliance
	vec2 diag = vec2(p.x + p.y, p.x - p.y) * 0.7071;
	float d_spike1 = smoothstep(flare_sharpness * 1.5, 0.0, abs(diag.y)) * smoothstep(size * 1.2, 0.0, abs(diag.x)) * 0.55;
	float d_spike2 = smoothstep(flare_sharpness * 1.5, 0.0, abs(diag.x)) * smoothstep(size * 1.2, 0.0, abs(diag.y)) * 0.55;
	
	return clamp(core * 0.8 + (h_spike + v_spike) * 0.85 + (d_spike1 + d_spike2), 0.0, 2.5);
}

void fragment() {
	if (!is_active) {
		COLOR = vec4(0.0);
	} else {
		vec2 uv = UV;
		float time = TIME * shimmer_speed;
		
		// 1. Barrido de luz diagonal iridiscente
		float diag = (uv.x * cos(sheen_angle) + uv.y * sin(sheen_angle));
		float max_diag = cos(sheen_angle) + sin(sheen_angle);
		float sweep_cycle = fract(time * 0.20);
		float sweep_pos = mix(-0.25, max_diag + 0.25, sweep_cycle);
		
		float dist = abs(diag - sweep_pos);
		float main_beam = smoothstep(sheen_width, 0.0, dist);
		main_beam = pow(main_beam, 2.4);
		
		// Haz secundario cristalino desfasado
		float dist_sec = abs(diag - (sweep_pos - 0.16));
		float sec_beam = smoothstep(sheen_width * 0.75, 0.0, dist_sec) * 0.45;
		float total_sheen = clamp(main_beam + sec_beam, 0.0, 1.0);
		
		// 2. Patrón de estrellas celestiales en cuadrícula diamantina
		vec2 star_uv = uv * star_scale;
		// Desfase en filas impares para crear un patrón de estrellas escalonado y orgánico
		if (mod(floor(star_uv.y), 2.0) == 1.0) {
			star_uv.x += 0.5;
		}
		
		vec2 cell_id = floor(star_uv);
		vec2 cell_uv = fract(star_uv) - vec2(0.5);
		
		float rnd = hash21(cell_id);
		float star_val = 0.0;
		
		if (rnd < star_density) {
			// Centrado con leve variación natural de posición
			vec2 star_center = vec2(sin(rnd * 6.28) * 0.12, cos(rnd * 6.28) * 0.12);
			vec2 p = cell_uv - star_center;
			
			// Pulsación y centelleo temporal individual por estrella
			float twinkle = sin(time * 3.5 + rnd * 6.28) * 0.5 + 0.5;
			twinkle = pow(twinkle, 1.8);
			
			// La estrella brilla con muchísima más intensidad cuando el haz diagonal pasa sobre ella
			float star_diag = (cell_id.x / star_scale * cos(sheen_angle) + cell_id.y / star_scale * sin(sheen_angle));
			float dist_to_sweep = abs(star_diag - sweep_pos);
			float sweep_boost = smoothstep(sheen_width * 1.5, 0.0, dist_to_sweep) * 2.2;
			
			float star_size = mix(0.18, 0.32, rnd);
			float flare = mix(0.045, 0.075, rnd);
			
			float base_star = radiant_star(p, flare, star_size);
			star_val = base_star * (twinkle * 0.7 + sweep_boost + 0.25) * star_intensity;
		}
		
		// 3. Mini estrellas de fondo (micro-constelación diamantina)
		vec2 micro_uv = uv * (star_scale * 2.0);
		vec2 micro_id = floor(micro_uv);
		vec2 micro_f = fract(micro_uv) - vec2(0.5);
		float micro_rnd = hash21(micro_id + vec2(7.3, 11.2));
		if (micro_rnd > 0.88) {
			float m_dist = length(micro_f);
			float m_twinkle = sin(time * 5.0 + micro_rnd * 6.28) * 0.5 + 0.5;
			star_val += smoothstep(0.15, 0.0, m_dist) * m_twinkle * 0.65;
		}
		
		// 4. Coloración prismática y cósmica de Boss
		vec3 base_color = mix(boss_primary_color.rgb, boss_accent_color.rgb, sin(diag * 4.5 + time * 0.7) * 0.5 + 0.5);
		
		if (rainbow_prismatic > 0.01) {
			float rainbow_phase = (diag / max_diag) * 6.28 + time * 0.9;
			vec3 rainbow = vec3(
				sin(rainbow_phase) * 0.5 + 0.5,
				sin(rainbow_phase + 2.094) * 0.5 + 0.5,
				sin(rainbow_phase + 4.188) * 0.5 + 0.5
			);
			base_color = mix(base_color, rainbow, rainbow_prismatic * total_sheen);
		}
		
		// Fusión final con estrellas resplandecientes
		vec3 star_color = star_glow_color.rgb * star_val;
		vec3 final_rgb = base_color * (total_sheen * 0.9 + ambient_glow) + star_color;
		
		// Alpha compuesto suave para no tapar el arte ni los textos de la carta
		float final_alpha = (total_sheen * 0.45 + ambient_glow * 0.5 + star_val * 0.75) * boss_primary_color.a;
		
		COLOR = vec4(final_rgb, clamp(final_alpha, 0.0, 0.92));
	}
}
