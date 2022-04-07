//
//  ViewController.swift
//  HelloTriangleSwift
//
//  Created by qe on 3/30/22.
//

import Cocoa
import Metal
import MetalKit

class ViewController: NSViewController {
    var mtkView: MTKView!
    var renderer: Renderer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let mtkViewTemp = self.view as? MTKView else {
            print("View attached to ViewController is not an MTKView!")
            return
        }
        mtkView = mtkViewTemp
        
        let devices = MTLCopyAllDevices()
        for device in devices {
            if device.isRemovable {
                mtkView.device = device
            }
        }
        print(mtkView.device!.name)
        
//        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
//            print("Metal is not supported on this device")
//            return
//        }
//        print("My GPU is: \(defaultDevice)")
//        mtkView.device = defaultDevice
        
        guard let tempRenderer = Renderer(mtkView: mtkView) else {
            print("Renderer failed to initialize")
            return
        }
        renderer = tempRenderer
        
        mtkView.delegate = renderer
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

