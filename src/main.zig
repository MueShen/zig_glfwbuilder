const std= @import("std");
const glad= @import ("glad");
const gl= @import ("glfw");

const c= @cImport({
    @cInclude("glad.h");
    @cInclude("glfw.h");
});

var wireframemode: bool= false;

pub fn main ()!void {
    _= c.glfwInit();
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR,4);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR,5);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
    const window= c.glfwCreateWindow(800,600, "LearnOpenGL",null,null);
    if (window == null){
        c.glfwTerminate();
        return error.WindowCreationFailed;
    }
    c.glfwMakeContextCurrent(window);
    _=c.glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    if(c.gladLoadGLLoader(@ptrCast(&c.glfwGetProcAddress))==c.GL_FALSE){
        return error.FailedToInitGlad;
    }
    
    const verts= [_]f32{
        0.5,  0.5, 0.0,  // top right
        0.5, -0.5, 0.0,  // bottom right
        -0.5, -0.5, 0.0,  // bottom left
        -0.5,  0.5, 0.0,  
    };

    const indicies=[_]i32{
        0,1,3,
        1,2,3,
    };
    const vertShaderCode: []const u8= @embedFile("shader/shader.vert");
    const fragShaderCode: []const u8= @embedFile("shader/shader.frag");

    const vertexShader: c_uint= c.glCreateShader(c.GL_VERTEX_SHADER);
    const fragmentShader: c_uint= c.glCreateShader(c.GL_FRAGMENT_SHADER);

    c.glShaderSource(vertexShader, 1, @ptrCast(&vertShaderCode),null);
    c.glShaderSource(fragmentShader,1,@ptrCast(&fragShaderCode),null);

    c.glCompileShader(fragmentShader);
    c.glCompileShader(vertexShader);
    var success: c_int= undefined;
    var infolog: [512]u8= undefined;
    c.glGetShaderiv(vertexShader, c.GL_COMPILE_STATUS, &success);
    if(success!=c.GL_TRUE){
        c.glGetShaderInfoLog(vertexShader, 512, null, @ptrCast(infolog[0..].ptr));
        return error.VertexShaderCompilationFailed;
    }
    c.glGetShaderiv(fragmentShader, c.GL_COMPILE_STATUS, &success);
    if(success!=c.GL_TRUE){
        c.glGetShaderInfoLog(fragmentShader,512, null, @ptrCast(infolog[0..].ptr));
        return error.FragmentShaderCompilationFailed;
    }

    const shaderProgram: c_uint= c.glCreateProgram();
    c.glAttachShader(shaderProgram,vertexShader);
    c.glAttachShader(shaderProgram,fragmentShader);
    c.glLinkProgram(shaderProgram);
    
    c.glGetProgramiv(shaderProgram,c.GL_LINK_STATUS, &success);
    if(success!=c.GL_TRUE){
        c.glGetShaderInfoLog(fragmentShader,512, null, @ptrCast(infolog[0..].ptr));
        return error.ShaderProgramLinkingFailed;
    }
    

    _= c.glCompileShader(vertexShader);
    var VBO: c_uint = undefined;
    var VAO: c_uint = undefined;
    var EBO: c_uint = undefined;

    c.glGenVertexArrays(1, &VAO);
    c.glGenBuffers(1,&VBO);   
    c.glGenBuffers(1,&EBO);

    c.glBindVertexArray(VAO);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, VBO);
    c.glBufferData(c.GL_ARRAY_BUFFER, @sizeOf(f32)*verts.len, @ptrCast(&verts), c.GL_STATIC_DRAW);

    c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER,EBO);
    c.glBufferData(c.GL_ELEMENT_ARRAY_BUFFER, @sizeOf(i32)*indicies.len, @ptrCast(&indicies), c.GL_STATIC_DRAW);

        //vertex attribues go here
    const  vdptr: ?*c.GLvoid =@ptrFromInt(0x0);
    c.glVertexAttribPointer(0,3, c.GL_FLOAT, c.GL_FALSE, 3 * @sizeOf(f32), @ptrCast(vdptr));
    c.glEnableVertexAttribArray(0);

    c.glBindBuffer(c.GL_ARRAY_BUFFER,0);
    c.glBindVertexArray(0);


    c.glDeleteShader(vertexShader);
    c.glDeleteShader(fragmentShader);
    

    while (c.glfwWindowShouldClose(window)==c.GL_FALSE){
        processInput(window);
        
        c.glClearColor(0.1, 0.1, 0.1,1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);
        
        c.glUseProgram(shaderProgram);
        c.glBindVertexArray(VAO);
        if(wireframemode){
            c.glPolygonMode(c.GL_FRONT_AND_BACK, c.GL_LINE);
        } else {
            c.glPolygonMode(c.GL_FRONT_AND_BACK, c.GL_FILL);
        }
        c.glDrawElements(c.GL_TRIANGLES,6, c.GL_UNSIGNED_INT, @ptrCast(vdptr));

        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }
    c.glfwTerminate();
    return;
}

pub fn processInput(window: ?*c.GLFWwindow) void {
    if(c.glfwGetKey(window, c.GLFW_KEY_ESCAPE) == c.GLFW_PRESS){
        c.glfwSetWindowShouldClose(window, c.GL_TRUE);
    }
    
    if(c.glfwGetKey(window, c.GLFW_KEY_R) == c.GLFW_PRESS){
        wireframemode=true;
    }
    if(c.glfwGetKey(window, c.GLFW_KEY_R) == c.GLFW_RELEASE){
        wireframemode=false;
    }


}

pub fn framebuffer_size_callback(window: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.c) void{
    _=window;
    c.glViewport(0,0,width,height);
}


