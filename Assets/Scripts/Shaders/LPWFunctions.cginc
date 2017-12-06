#ifndef LPW_FUNCTIONS
#define LPW_FUNCTIONS

#include "LPWVars.cginc"

float3 CalculateWaves(float3 vertex, float uvx)
{
	float3 waves = 0;

	if (_EnableWaves > 0.1)
	{
		float A = _WaveAmplitude;
		float2 D = float2(1, 0);
		float L = _WaveLength;
		float phase = _WaveSpeed * 2 / L;
		float W = 2 / L;
		float angle = W * dot(D, vertex.xz) + _Time.y * phase;

		float Q = _Steepness / (W * A * _Waves);
		float QA = Q * A;

		float cosWave;
		float sinWave;

		sincos(angle, sinWave, cosWave);

		waves = float3(vertex.x + (QA * D.x * cosWave),
			A * sinWave,
			vertex.y + (QA * D.y * cosWave));

		float attenuation = pow(uvx, 2) + 0.1;

		waves.y += (snoise(float2(
			(vertex.x + _Time.y / (_WNPeriod + eps)) / (_WNoiseScale.x * L),
			(vertex.z + _Time.y / (_WNPeriod + eps)) / _WNoiseScale.y)) * 2 - 1)
			* _WNHeight * (1 - attenuation);

		waves.y *= attenuation;
	}

	return waves;
}

void CalculateDistortion(inout appdata v, inout v2f o)
{
	float noise =
		(snoise((v.vertex.xz + _Time.x / (_Period + eps))
			/ (_NoiseScale / 100 + eps)) * 2 - 1) * _Height;

	float3 waves = CalculateWaves(v.vertex.xyz, v.uv.x);

	#ifdef FORWARD_BASE
		if (_EnableWaves > 0.1)
		{
			// Distorted screen space
			o.dScreenPos = ComputeScreenPos(
				UnityObjectToClipPos(v.vertex
					+ float3(waves.x, noise, waves.z)
					+ float3(noise, 0, noise) * _Distortion));
		}
		else
		{
			// Distorted screen space
			o.dScreenPos = ComputeScreenPos(
				UnityObjectToClipPos(v.vertex
					+ float3(noise, 0, noise) * _Distortion));
		}

		// Barycentric coordinates
		o.color = v.color;
	#endif

	v.vertex.y = noise;
	v.vertex.xyz += waves;
}

float edgeFactor(float3 color, float depth)
{
	float3 d = abs(ddx(color)) + abs(ddy(color));
	float3 a3 = smoothstep(0,
		d * _Thickness / (depth + eps),
		color);

	return min(min(a3.x, a3.y), a3.z);
}

UnityLight GetDirect(v2f i)
{
	UnityLight light;

	#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
		light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
	#else
		light.dir = _WorldSpaceLightPos0.xyz;
	#endif

	UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos.xyz);
	light.color = _LightColor0.rgb * attenuation;

	return light;
}

UnityIndirect GetIndirect(float3 normal)
{
	UnityIndirect indirect;

	indirect.diffuse = 0;
	indirect.specular = 0;

	#if defined(FORWARD_BASE)
		indirect.diffuse = max(0, ShadeSH9(float4(normal, 1)));
		indirect.specular = unity_IndirectSpecColor.rgb;
	#endif

	return indirect;
}

void CalculateFoamAndWire(inout float4 fc, inout float3 wc, v2f i)
{
	#ifdef FORWARD_BASE
		if (_EnableFoams > 0.1)
		{
			float screenDepth = LinearEyeDepth(
				SAMPLE_DEPTH_TEXTURE_PROJ(
					_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));

			float foam =
				saturate(abs(screenDepth - i.screenPos.w) / (_FoamDistance + eps));

			fc.a = foam;
			fc.rgb = _FoamColor * (1 - fc.a);
		}

		if (_EnableWires > 0.1)
		{
			float factor = saturate(i.screenPos.w / 30) * (1 - _DepthDistance);
			float wire = edgeFactor(i.color.xyz, i.screenPos.w);

			wc = _WireColor * (1 - saturate(wire + factor));
		}
	#endif
}

void CalculateReflAndRefr(float3 viewDir,
	float3 normal, out float3 rrc, v2f i)
{
	rrc = 0;

	#ifdef FORWARD_BASE
		float3 reflectionColor = 0;
		float3 refractionColor = 0;

		#if defined(REFLECTIVE) || defined(REFRACTIVE)
			reflectionColor =
				tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(i.dScreenPos));
		#endif

		#ifdef REFRACTIVE
			refractionColor =
				tex2Dproj(_RefractionTex, UNITY_PROJ_COORD(i.dScreenPos));
		#endif

		#if defined(REFLECTIVE) || defined(REFRACTIVE)
			float fresnel = DotClamped(viewDir, float3(0, 1, 0));
			rrc = lerp(reflectionColor, refractionColor, fresnel);
		#endif

	#endif
}

#endif