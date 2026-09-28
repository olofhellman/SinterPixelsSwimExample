SinterPixelsSwimExample is an example project to demonstrate using swift as a scripting language for the scriptable app SinterPixels. You can use SinterPixels to programmatically generate shapes, circles, paths, polygons, text shapes and bitmaps.

See the [SinterPixels support files repo](https://github.com/olofhellman/SinterpixelsSupportFiles) for details about scripting SinterPixels. SinterPixels is entirely controllable by AppleScript.

The SinterPixelsSwim package supports swift code like this, which makes a new SinterPixels document:

```
	if let spApp = SPApp() {
		let props = SAERecord()
		props.setParam(.height, int:1000)
		props.setParam(.width, int:1000)
		
		let madeObject = await spApp.make(new: SPDocument.self, props: props)
	}
```

which is the analogous swift version of the AppleScript

```
    tell application "SinterPixels"
        make new document with properties { height: 1000, width: 1000 }
    end tell
```
