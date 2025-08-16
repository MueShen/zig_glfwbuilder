#version 450 core
out vec4 FragColor;
uniform vec4 triColor;
in vec3 ourColor;
void main()
{
    FragColor = vec4(ourColor,1.0);
	    
} 
