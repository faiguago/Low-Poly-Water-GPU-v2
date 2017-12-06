#ifndef LPW_VARS
#define LPW_VARS

struct appdata {
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
	float4 color : COLOR;
};

struct v2f {
	float4 pos : SV_POSITION;
	float3 worldPos : TEXCOORD0;

	#if defined(FORWARD_BASE)
		float4 screenPos : TEXCOORD1;
		float3 color : TEXCOORD2; // Barycentric coordinates
		float4 dScreenPos : TEXCOORD3; // Distorted screen pos
	#endif
};

// General vars
float _Smoothness;
float _Period;
float _Height;
float _NoiseScale;
float _Thickness;
float _FoamDistance;
float _DepthDistance;
float _Distortion;

// Gerstner waves vars
float _Steepness;
float _Waves;
float _WaveSpeed;
float _WaveLength;
float _WaveAmplitude;

// Waves noise vars
float _WNPeriod;
float2 _WNoiseScale;
float _WNHeight;

// Colors
float3 _Color, 
_WireColor, _FoamColor;

// Textures
sampler2D _CameraDepthTexture,
_ReflectionTex, _RefractionTex;

// Const
static const float eps = 1E-5;

// Toggles
float _EnableFoams;
float _EnableWires;
float _EnableWaves;

#endif