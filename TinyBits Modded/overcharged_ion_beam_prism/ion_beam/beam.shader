#define USE_DEFAULT_VERT
#include "./Data/base.shader"

float _intensity;
float _length;
float _beamTime;

float _sizePulseFactor;
float _sizePulseInterval;
float _sizePulseUOffsetFactor;

float4 getBaseColor(VERT_OUTPUT input)
{
	float sizePulseT = wave(_beamTime * _intensity + input.uv.x * _length * _sizePulseUOffsetFactor, _sizePulseInterval * _intensity);
	float normalizedV = input.uv.y * 2 - 1;
	normalizedV /= lerp(1, _sizePulseFactor, sizePulseT);
	float endT = clamp(min(input.uv.x, 1 - input.uv.x) * _length / (1.5 * _intensity), 0, 1);
	normalizedV /= lerp(1 / _intensity, 1, sin(endT * HALF_PI));
	float baseV = (normalizedV + 1) / 2;

	return _texture.Sample(_texture_SS, float2(input.uv.x, baseV));
}

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 baseColor = getBaseColor(input);
	baseColor.a *= min(min(input.uv.x, 1 - input.uv.x) * _length / 1.5, 1);
	baseColor *= input.color;
	if(baseColor.a <= 0)
		discard;
	return baseColor;
}
