//vertex shader

attribute vec4 position;
attribute vec2 texcoord;

varying lowp vec2 coord;

uniform mat4 modelViewProjectionMatrix;

void main()
{
    coord = texcoord;
    gl_Position = modelViewProjectionMatrix * position;
}