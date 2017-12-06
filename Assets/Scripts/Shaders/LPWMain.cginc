#ifndef LPW_MAIN
#define LPW_MAIN

#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

#include "SimplexNoise2D.cginc"
#include "LPWFunctions.cginc"

v2f vert(appdata v)
{
	v2f o;

	UNITY_INITIALIZE_OUTPUT(v2f, o);

	// Calculate vertex and screen distortion
	CalculateDistortion(v, o);

	o.pos = UnityObjectToClipPos(v.vertex);

	#ifdef FORWARD_BASE
		o.screenPos = ComputeScreenPos(o.pos);
	#endif

	o.worldPos.xyz = mul((float3x3)unity_ObjectToWorld, v.vertex);

	return o;
}

float4 frag(v2f i) : SV_Target
{
	float3 mc = _Color; // Main color
	float4 fc = 0; // Foam color
	float3 wc = 0; // Wire color
	float3 rrc = 0; // Reflected and refracted color

	// Get main and wire colors
	CalculateFoamAndWire(fc, wc, i);

	float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos.xyz);

	float3 normalTangent =
		cross(normalize(ddx(i.worldPos.xyz)), normalize(ddy(i.worldPos.xyz)));

	float3 normalWorld = 
		float3(normalTangent.x, -normalTangent.y, normalTangent.z);

	// Get reflected and refracted colors
	CalculateReflAndRefr(viewDir, normalWorld, rrc, i);

	// Diffuse color
	float3 diffColor = 0;

	#if defined(REFLECTIVE) || defined(REFRACTIVE)
		diffColor = saturate(mc + rrc.rgb);
	#else
		diffColor = mc;
	#endif

	if (_EnableFoams > 0.1)
		diffColor *= fc.a;
	
	float3 specColor;
	float oneMinusReflectivity;

	diffColor = DiffuseAndSpecularFromMetallic(
		diffColor, 0, specColor, oneMinusReflectivity);

	// PBR
	float3 color = UNITY_BRDF_PBS(
		diffColor, specColor, oneMinusReflectivity,
		_Smoothness, normalWorld, viewDir,
		GetDirect(i), GetIndirect(normalWorld));

	// Emissive colors
	color += fc.rgb + wc;

	return float4(color, 1);
}

#endif