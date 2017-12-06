Shader "Custom/LowPolyWater v2" 
{
	Properties
	{
		// Main color
		_Color("Color", Color) = (0, 0.2706, 1, 0.6706)
		_Smoothness("Smoothness", Range(0, 1)) = 0.5

		// Wire vars
		[HDR] _WireColor("Wire color", Color) = (0.149, 0, 1, 1)
		_DepthDistance("Depth distance", Range(0, 1)) = 0
		_Thickness("Thickness", float) = 20

		// Foam vars
		_FoamColor("Foam color", Color) = (1, 1, 1, 1)
		_FoamDistance("Foam distance", Range(0, 25)) = 5
		
		// Noise vars
		_NoiseScale("Noise scale", float) = 0.01
		_Height("Height", float) = 0.1
		_Period("Noise period", float) = 25
		_Distortion("Distortion", Range(1, 5)) = 1

		// Gerstner waves vars
		_Waves("Waves", Range(0.25, 1)) = 1
		_Steepness("Steepness", Range(0, 1)) = 1
		_WaveSpeed("Wave speed", float) = 1
		_WaveLength("Wave length", float) = 1
		_WaveAmplitude("Wave amplitude", Range(0.01, 100)) = 1

		// Waves noise vars
		_WNPeriod("Noise wave period", float) = 1
		_WNoiseScale("Noise wave scale", Vector) = (1, 1, 1, 1)
		_WNHeight("Noise wave height", float) = 1

		// Toggles
		[Toggle] _EnableFoams("Enable foams", float) = 1
		[Toggle] _EnableWires("Enable wires", float) = 1
		[Toggle] _EnableWaves("Enable waves", float) = 1

		// Reflection and refraction textures
		[HideInInspector] _ReflectionTex("ReflectionTex", 2D) = "black" { }
		[HideInInspector] _RefractionTex("RefractionTex", 2D) = "black" { }
	}

	SubShader 
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry" }
		
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			Cull Off

			CGPROGRAM

			#pragma target 3.0

			#define FORWARD_BASE

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile REFLECTIVE REFRACTIVE

			#include "LPWMain.cginc"

			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "ForwardAdd" }

			Blend One One
			ZWrite Off

			CGPROGRAM

			#pragma target 3.0

			#pragma multi_compile_fwdadd

			#pragma vertex vert
			#pragma fragment frag

			#include "LPWMain.cginc"

			ENDCG
		}
	}
}