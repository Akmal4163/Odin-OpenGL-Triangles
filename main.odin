package opengl_app

import "core:fmt"
import "vendor:glfw"
import gl"vendor:OpenGL"
import glm"core:math/linalg/glsl"

GL_MAJOR_VERSION :: 3
GL_MINOR_VERSION :: 3

main :: proc() {

    if !bool(glfw.Init()) {
        fmt.eprintln("cannot initialize GLFW")
        return
    }

    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
    glfw.WindowHint(glfw.OPENGL_ANY_PROFILE, glfw.OPENGL_CORE_PROFILE)
    glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, 1)

    window := glfw.CreateWindow(800, 600, "GLFW Window", nil, nil)
    defer glfw.DestroyWindow(window)
    defer glfw.Terminate();

    if window == nil {
        fmt.eprintln("cannot initialize GLFW Window")
        return
    }

    //create OpenGL context
    glfw.MakeContextCurrent(window)
    gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)

    gl.Viewport(0, 0, 800, 600)


    //shaders
    shader_program, load_success := gl.load_shaders_file("vertex_shader.vert", "fragment_shader.frag")
    if !load_success {
        fmt.eprintln("cannot load GLSL shaders from file")
        return
    }
    defer gl.DeleteProgram(shader_program)

    gl.UseProgram(shader_program)

    //initialization of vao, vbo, and ebo
    vertex::struct {
        pos: glm.vec3,
        col: glm.vec4,
    }

    vertices := []vertex {
        {{ 0.0, +0.5, 0}, {0.0, 1.0, 0.0, 1.0}},
		{{-0.5, -0.5, 0}, {1.0, 0.0, 0.0, 1.0}},
		{{+0.5, -0.5, 0}, {0.0, 0.0, 1.0, 1.0}},
    }

    vao, vbo: u32

    //vao
    gl.GenVertexArrays(1, &vao); defer gl.DeleteVertexArrays(1, &vao)
    gl.BindVertexArray(vao)

    //vbo
    gl.GenBuffers(1, &vbo); defer gl.DeleteBuffers(1, &vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    gl.BufferData(gl.ARRAY_BUFFER, len(vertices)*size_of(vertices[0]), raw_data(vertices), gl.STATIC_DRAW)

    //bind vertices attrib array to shaders layout
    gl.EnableVertexAttribArray(0)
    gl.EnableVertexAttribArray(1)
    gl.VertexAttribPointer(0, 3, gl.FLOAT, false, size_of(vertex), offset_of(vertex, pos))
    gl.VertexAttribPointer(1, 4, gl.FLOAT, false, size_of(vertex), offset_of(vertex, col))

    for !glfw.WindowShouldClose(window) {
        gl.ClearColor(0,0,0,0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        gl.DrawArrays(gl.TRIANGLES, 0, 3)

        glfw.SwapBuffers(window)
        glfw.PollEvents()
    }
}