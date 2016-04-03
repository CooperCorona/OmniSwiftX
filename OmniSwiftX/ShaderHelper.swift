//
//  ShaderHelper.swift
//  InverseKinematicsTest
//
//  Created by Cooper Knaak on 10/13/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import GLKit

public class ShaderHelper : NSObject {

    // MARK: - Shared Instance
    public class var sharedInstance : ShaderHelper {
        struct Static {
            static let instance:ShaderHelper = ShaderHelper()
        }//static instance
        return Static.instance
    }//shared instance class
    
    // MARK: - Properties
    
    public var programs:[String:GLuint] = [:]
    private(set) public var programDictionaries:[String:GLProgramDictionary] = [:]
    private(set) public var isLoaded = false
    
    // MARK: - Setup
    
    override init() {

    }
    
    // MARK: - Logic
    
    public func loadPrograms(dict:[String:String]) {
        
        for (key, file) in dict {
            if let vshURL = NSBundle.mainBundle().URLForResource(file, withExtension: "vsh"),
            fshURL = NSBundle.mainBundle().URLForResource(file, withExtension: "fsh") {
                let program = self.buildProgramVertexURL(vshURL, fragmentURL: fshURL)
                programs[key] = program
                
                self.programDictionaries[key] = self.createProgramDictionary(program, vertexURL: vshURL, fragmentURL: fshURL)
            }
        }//create shaders
        
        self.isLoaded = true
    }//load programs
    
    ///Gets all *.vsh* and *.fsh* files from the OmniSwiftX bundle and main bundle and loads them.
    public func loadProgramsFromBundle() {
        let frames = NSBundle.allFrameworks().filter() { $0.bundlePath.hasSuffix(("OmniSwiftX.framework")) }
        for frame in [frames[0], NSBundle.mainBundle()] {
            var basePaths:[String:String] = [:]
            guard let resourcePath = frame.resourcePath else {
                return
            }
            if let enumerator = NSFileManager.defaultManager().enumeratorAtPath(resourcePath) {
                while let currentPath = enumerator.nextObject() as? String {
                    if let (key, path) = self.keyAndPathForPath(currentPath) {
                        basePaths[key] = path
                    }
                }
                
            }
            for (key, path) in basePaths {
                let vshURL = NSURL(fileURLWithPath: resourcePath + "/\(path).vsh")
                let fshURL = NSURL(fileURLWithPath: resourcePath + "/\(path).fsh")
                let program = self.buildProgramVertexURL(vshURL, fragmentURL: fshURL)
                self.programs[key] = program
                
                self.programDictionaries[key] = self.createProgramDictionary(program, vertexURL: vshURL, fragmentURL: fshURL)
            }
        }
    }
    
    private func keyAndPathForPath(path:String) -> (key:String, path:String)? {
        let baseFilePaths = path.componentsSeparatedByString("/").last!.componentsSeparatedByString(".")
        guard baseFilePaths.count >= 2 && (baseFilePaths[1] == "vsh" || baseFilePaths[1] == "fsh") else {
            return nil
        }
        let filePath = baseFilePaths[0]
        let key = filePath.convertCamelCaseToSpaces()
        return (key, filePath)
    }
    
    public func buildProgramVertexURL(vshURL:NSURL, fragmentURL fshURL:NSURL) -> GLuint {
        let program = glCreateProgram()

        let vertexShader = self.buildShader(vshURL, shaderType: GLenum(GL_VERTEX_SHADER))
        let fragmentShader = self.buildShader(fshURL, shaderType: GLenum(GL_FRAGMENT_SHADER))
        
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        
        glLinkProgram(program)
    
        return program
    }//create program
    
    public func buildShader(url:NSURL, shaderType:GLenum) -> GLuint {
        
//        let path = NSBundle.mainBundle().pathForResource(file, ofType: nil)
//        let data = try? String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        let data = try? String(contentsOfURL: url, encoding: NSASCIIStringEncoding)
        let cSource = data!.cStringUsingEncoding(NSASCIIStringEncoding)
        var text = UnsafePointer<GLchar> (cSource!)
        
        /*
        let source = withUnsafePointer(&text) { (pointer:UnsafePointer<UnsafePointer<GLchar>>) -> GLuint in
            let sourceValue = glCreateShader(shaderType)
            glShaderSource(sourceValue, 1, pointer, nil)
            glCompileShader(sourceValue)
            return sourceValue
        }
        */
        let shader = glCreateShader(shaderType)
        var length = GLint(data!.characters.count)
        glShaderSource(shader, 1, &text, &length)
        glCompileShader(shader)
        
        var logLength:GLint = 0
        glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if (logLength > 0)
        {//valid log
            var ump = Array<GLchar>(count: Int(logLength), repeatedValue: 0)
            glGetShaderInfoLog(shader, logLength, &logLength, &ump)
            let str = String(UTF8String: ump)
            print("Shader Log:\(str!)")
        }//valid log
        
        var status:GLint = 0
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status)
        if (status != GL_TRUE)
        {//invalid
            let error = glGetError()
            print("\(url)--Error:\(error)--Status:\(status)")
        }//invalid
        
        return shader
    }//create shader
    
    private func createProgramDictionary(program:GLuint, vertexURL vshURL:NSURL, fragmentURL fshURL:NSURL) -> GLProgramDictionary? {
        guard let vshData = try? String(contentsOfURL: vshURL, encoding: NSASCIIStringEncoding),
            let fshData = try? String(contentsOfURL: fshURL, encoding: NSASCIIStringEncoding) else {
                return nil
        }
        return GLProgramDictionary(program: program, vertexShader: vshData, fragmentShader: fshData)
    }
    
    
    public subscript(index:String) -> GLuint? {
        if let program = self.programs[index] {
            return program
        } else {
            print("ShaderHelper: \(index) does not exist!")
            return nil
        }
    }//get program for string
    
    public class func programForString(key:String) -> GLuint? {
        return ShaderHelper.sharedInstance[key]
    }//get program for string
    
    public class func programDictionaryForString(key:String) -> GLProgramDictionary? {
        return ShaderHelper.sharedInstance.programDictionaries[key]
    }
    
//Logic
    
    
}//shader helper
