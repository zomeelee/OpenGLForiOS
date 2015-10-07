// fragment shader

varying lowp vec2 coord;
uniform sampler2D texture;

void main()
{
    //gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    gl_FragColor = texture2D(texture, coord.st);
}