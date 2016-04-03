#version 150

uniform mat4 u_Projection;

in vec2 a_Position;
in vec2 a_Texture;
in vec3 a_NoiseTexture;

out vec2 v_Texture;
out vec3 v_NoiseTexture;

void main(void) {
    vec4 pos = u_Projection * vec4(a_Position, 0.0, 1.0);
    gl_Position = pos;

    /*
     *	For some reason, the interpolation causes these
     *	to end up at half their actual values! I have no
     *	idea why, but for now, I just double their values.
     */
    v_Texture = a_Texture;
    v_NoiseTexture = a_NoiseTexture;
}//main