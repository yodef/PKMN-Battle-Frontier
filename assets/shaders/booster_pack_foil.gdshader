shader_type canvas_item;

// Shader de foil holográfico exclusivo para empaques de sobres (Booster Packs)
// Simula envoltura de mylar/plástico metálico con micro-arrugas, destello especular amplio y dispersión prismática
uniform float shimmer_speed : hint_range(0.1, 4.0) = 0.85;
uniform vec4 foil_tint : source_color = vec4(1.0, 0.88, 0.45, 0.55); // Tonalidad regional metálica
uniform float crinkle_strength : hint_range(0.0, 0.05) = 0.012;
uniform float sheen_width : hint_range(0.1, 0.7) = 0.28;
uniform float sheen_angle : hint_range(0.0, 3.1415) = 0.65;
uniform float holographic_intensity : hint_range(0.0, 2.0) = 1.0;
uniform bool is_active = true;

void fragment() {
	if (!is_active) {
		COLOR = vec4(0.0);
	} else {
		vec2 uv = UV;
		
		// Textura de micro-arrugas y pliegues de envoltura plástica/mylar
		float crinkle = sin(uv.x * 65.0 + uv.y * 12.0) * cos(uv.x * 30.0 - uv.y * 25.0);
		vec2 warped_uv = uv + vec2(crinkle * crinkle_strength, crinkle * crinkle_strength * 0.5);
		
		float t = fract(TIME * shimmer_speed * 0.18);
		float diag = (warped_uv.x * cos(sheen_angle) + warped_uv.y * sin(sheen_angle));
		float max_diag = cos(sheen_angle) + sin(sheen_angle);
		
		float band_pos = mix(-0.35, max_diag + 0.35, t);
		float dist = abs(diag - band_pos);
		
		// Haz primario amplio de brillo metálico sobre el empaque
		float main_beam = smoothstep(sheen_width, 0.0, dist);
		main_beam = pow(main_beam, 1.7);
		
		// Haz secundario nítido (reflejo especular brillante de plástico pulido)
		float dist_sharp = abs(diag - (band_pos + 0.05));
		float sharp_beam = smoothstep(0.045, 0.0, dist_sharp) * 0.65;
		
		// Dispersión prismática arcoíris (iridiscencia holográfica de sobre Pokémon TCG)
		float rainbow_phase = (diag / max_diag) * 6.28 + TIME * 0.65 + crinkle * 2.2;
		vec3 rainbow = vec3(
			sin(rainbow_phase) * 0.5 + 0.5,
			sin(rainbow_phase + 2.094) * 0.5 + 0.5,
			sin(rainbow_phase + 4.188) * 0.5 + 0.5
		);
		
		// Combinación del color metálico del sobre con el arcoíris holográfico
		vec3 foil_color = mix(foil_tint.rgb, rainbow, 0.32);
		
		// Brillo ambiental sutil que delinea las arrugas de la bolsa
		float ambient = (sin(uv.y * 30.0 + TIME * 0.5) * 0.03 + 0.07) * (1.0 + crinkle * 0.4);
		
		float total_sheen = (main_beam * 0.70 + sharp_beam + ambient) * holographic_intensity;
		vec3 final_rgb = foil_color + vec3(sharp_beam * 0.5);
		float final_alpha = clamp(total_sheen * foil_tint.a, 0.0, 0.85);
		
		COLOR = vec4(final_rgb, final_alpha);
	}
}
