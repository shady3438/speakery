#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

// The engine requires the first uniform to be a vec2; it carries the size of
// the image being filtered (the backdrop snapshot behind the pane).
uniform vec2 uSize;

// x: corner radius in px
// y: refraction strength in px (how far the rim pulls the backdrop inward)
// z: chromatic dispersion in px
// w: width of the refracting edge band in px
uniform vec4 uConfig;

// Bound automatically by ImageFilter.shader to the backdrop.
uniform sampler2D uTexture;

out vec4 fragColor;

// Signed distance to a rounded rectangle centred on the origin.
// Negative inside, positive outside.
float sdRoundRect(vec2 p, vec2 halfSize, float r) {
  vec2 q = abs(p) - halfSize + r;
  return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 uv = frag / uSize;
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif

  float radius = uConfig.x;
  float refract = uConfig.y;
  float disperse = uConfig.z;
  float band = max(uConfig.w, 1.0);

  vec2 halfSize = uSize * 0.5;
  vec2 p = frag - halfSize;
  float d = sdRoundRect(p, halfSize, radius);

  // Outside the pane nothing is bent.
  if (d >= 0.0) {
    fragColor = texture(uTexture, uv);
    return;
  }

  // 0 through the middle of the pane, 1 right at the rim.
  float k = clamp(1.0 + d / band, 0.0, 1.0);
  k = k * k * (3.0 - 2.0 * k);

  if (k <= 0.0) {
    fragColor = texture(uTexture, uv);
    return;
  }

  // Outward normal from the gradient of the distance field, so corners bend
  // correctly instead of pulling towards the centre.
  float dx = sdRoundRect(p + vec2(1.0, 0.0), halfSize, radius) -
             sdRoundRect(p - vec2(1.0, 0.0), halfSize, radius);
  float dy = sdRoundRect(p + vec2(0.0, 1.0), halfSize, radius) -
             sdRoundRect(p - vec2(0.0, 1.0), halfSize, radius);
  vec2 n = normalize(vec2(dx, dy) + vec2(1e-6));

  // A convex lens edge drags what is behind it inward.
  vec2 shift = -n * k * refract / uSize;
  vec2 split = n * k * disperse / uSize;

#ifdef IMPELLER_TARGET_OPENGLES
  // uv was flipped above to sample the bottom-up texture, but the distance
  // field was built in fragment space. Flip the vertical component of the bend
  // to match, or the top and bottom edges refract the wrong way.
  shift.y = -shift.y;
  split.y = -split.y;
#endif

  // Split the channels so the rim carries a faint magenta/cyan fringe.
  float r = texture(uTexture, uv + shift + split).r;
  float g = texture(uTexture, uv + shift).g;
  float b = texture(uTexture, uv + shift - split).b;
  float a = texture(uTexture, uv + shift).a;

  fragColor = vec4(r, g, b, a);
}
