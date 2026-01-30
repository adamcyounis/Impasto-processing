#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 resolution;
uniform vec2 mousePos;
uniform float brushRadius;
uniform sampler2D bufferTexture;

void main() {
    vec2 uv = gl_FragCoord.xy / resolution;
    vec2 pixelPos = gl_FragCoord.xy;
    
    float dist = distance(pixelPos, mousePos);
    
    // Get current pixel color from buffer
    vec4 currentColor = texture2D(bufferTexture, uv);
    
    // Add black circle at mouse position
    if (dist <= brushRadius) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0); // Black
    } else {
        gl_FragColor = currentColor; // Keep existing color
    }
}